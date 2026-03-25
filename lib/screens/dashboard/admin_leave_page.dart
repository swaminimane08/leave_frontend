import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';

class AdminLeavePage extends StatefulWidget {
  const AdminLeavePage({super.key});

  @override
  State<AdminLeavePage> createState() => _AdminLeavePageState();
}

class _AdminLeavePageState extends State<AdminLeavePage> {

  List leaves = [];
  List filteredLeaves = [];
  bool loading = true;

  DateTime selectedDate = DateTime.now();
  String searchText = "";

  @override
  void initState() {
    super.initState();
    loadLeaves();
  }

  // ✅ FIXED: NO DATE ON LOAD
  void loadLeaves() async {
    setState(() => loading = true);

    final data = await ApiService.getAllLeaves(); // 🔥 FIX

    setState(() {
      leaves = data;
      filteredLeaves = data;
      loading = false;
    });
  }

  void searchLeave(String value) {
    setState(() {
      searchText = value;

      filteredLeaves = leaves.where((leave) =>
          (leave['user']?['name'] ??
              leave['employeeName'] ??
              "")
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  // ✅ FIXED: DATE FILTER ONLY HERE
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });

      String date = picked.toIso8601String().split("T")[0];

      setState(() => loading = true);

      final data = await ApiService.getAllLeaves(date: date);

      setState(() {
        leaves = data;
        filteredLeaves = data;
        loading = false;
      });
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void showDecisionDialog(String id, String status) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$status Leave"),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(
              hintText: "Enter comment (optional)",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {

                await ApiService.updateLeave(id, {
                  "status": status,
                  "adminComment":
                  commentController.text,
                });

                Navigator.pop(context);
                loadLeaves();
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void deleteLeave(String id) async {
    await ApiService.deleteLeave(id);
    loadLeaves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text("Leave Requests"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: pickDate,
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          /// DATE BOX
          Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade400],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.date_range, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  selectedDate.toString().split(" ")[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ).animate().fade().slideY(),

          /// SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Employee...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: searchLeave,
            ),
          ),

          const SizedBox(height: 15),

          /// LIST
          Expanded(
            child: filteredLeaves.isEmpty
                ? const Center(child: Text("No Leave Found"))
                : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: filteredLeaves.length,
              itemBuilder: (context, index) {

                final item = filteredLeaves[index];
                final status = item['status'];
                final isDeleted = item['user'] == null;

                final name =
                    item['user']?['name'] ??
                        item['employeeName'] ??
                        "Deleted User";

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Center(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDeleted ? Colors.red : Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor(status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text("Type: ${item['leaveType']}"),
                      Text("From: ${item['fromDate'].substring(0, 10)}"),
                      Text("To: ${item['toDate'].substring(0, 10)}"),
                      Text("Total Days: ${item['totalDays']}"),

                      const SizedBox(height: 8),

                      if (item['adminComment'] != null)
                        Text(
                          "Admin Reply: ${item['adminComment']}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [

                          if (status == "Pending") ...[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () {
                                showDecisionDialog(item['_id'], "Approved");
                              },
                              child: const Text("Approve"),
                            ),

                            const SizedBox(width: 10),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                showDecisionDialog(item['_id'], "Rejected");
                              },
                              child: const Text("Reject"),
                            ),

                            const SizedBox(width: 10),
                          ],

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Delete Leave"),
                                  content: const Text("Are you sure?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        deleteLeave(item['_id']);
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fade()
                    .slideX(begin: 0.2, delay: (100 * index).ms);
              },
            ),
          ),
        ],
      ),
    );
  }
}