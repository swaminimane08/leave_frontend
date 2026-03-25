// ================= EMPLOYEE TASK PAGE (FIXED) =================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';

class EmployeeTasksPage extends StatefulWidget {
  const EmployeeTasksPage({super.key});

  @override
  State<EmployeeTasksPage> createState() =>
      _EmployeeTasksPageState();
}

class _EmployeeTasksPageState extends State<EmployeeTasksPage> {

  List tasks = [];
  List filteredTasks = [];
  bool loading = true;

  int total = 0;
  int pending = 0;
  int completed = 0;

  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // ✅ SAFE DATE FORMAT
  String formatDateTime(String? dateString) {
    if (dateString == null) return "";
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat("dd MMM yyyy • hh:mm a").format(date);
    } catch (e) {
      return "";
    }
  }

  // ✅ SAFE DAYS CALC
  String daysRemaining(String? dateString) {
    if (dateString == null) return "";
    try {
      final due = DateTime.parse(dateString).toLocal();
      final diff = due.difference(DateTime.now()).inDays;

      if (diff > 0) return "$diff days left";
      if (diff == 0) return "Due Today";
      return "${diff.abs()} days overdue";
    } catch (e) {
      return "";
    }
  }

  // ✅ FIXED LOAD TASKS (NO CRASH)
  void loadTasks() async {
    try {
      setState(() => loading = true);

      final data = await ApiService.getMyTasks();

      setState(() {
        tasks = data ?? [];

        total = tasks.length;
        pending =
            tasks.where((t) => t['status'] == "Pending").length;
        completed =
            tasks.where((t) => t['status'] == "Completed").length;

        filterTasksByMonth();
        loading = false;
      });
    } catch (e) {
      print("TASK ERROR: $e");

      setState(() {
        loading = false;
        tasks = [];
        filteredTasks = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load tasks")),
      );
    }
  }

  // ✅ SAFE FILTER
  void filterTasksByMonth() {
    filteredTasks = tasks.where((task) {
      if (task['dueDate'] == null) return false;

      try {
        final due =
        DateTime.parse(task['dueDate']).toLocal();

        return due.year == selectedMonth.year &&
            due.month == selectedMonth.month;
      } catch (e) {
        return false;
      }
    }).toList();

    setState(() {});
  }

  Future<void> pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedMonth = DateTime(picked.year, picked.month);
      filterTasksByMonth();
    }
  }

  // ✅ SAFE STATUS UPDATE
  void updateStatus(String id, String status) async {
    try {
      await ApiService.updateTaskStatus(id, status);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Status Updated")),
      );

      loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update Failed")),
      );
    }
  }

  // ✅ SAFE WHATSAPP
  Future<void> shareOnWhatsApp(Map task) async {
    try {
      final message = """
Task Issue Report

Title: ${task['title']}
Description: ${task['description']}
Due Date: ${task['dueDate'] != null ? formatDateTime(task['dueDate']) : ''}
Status: ${task['status']}
""";

      final encoded = Uri.encodeComponent(message);
      final uri = Uri.parse("whatsapp://send?text=$encoded");

      await launchUrl(uri,
          mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("WhatsApp not available")),
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "In Progress":
        return Colors.orange;
      case "Overdue":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [

            // 🔵 MONTH PICKER
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 15, vertical: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: pickMonth,
                  child: Text(
                    DateFormat("MMMM yyyy")
                        .format(selectedMonth),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ),
            ),

            // 🔵 STATS
            Container(
              margin:
              const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1A237E),
                    Color(0xFF3949AB),
                  ],
                ),
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceAround,
                children: [
                  _statBox("Total", total),
                  _statBox("Pending", pending),
                  _statBox("Completed", completed),
                ],
              ),
            ).animate().fade().slideY(begin: 0.2),

            const SizedBox(height: 10),

            // 🔵 LIST
            Expanded(
              child: filteredTasks.isEmpty
                  ? const Center(
                child: Text(
                  "No tasks for selected month",
                  style: TextStyle(
                      fontWeight: FontWeight.bold),
                ),
              )
                  : ListView.builder(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 15),
                itemCount: filteredTasks.length,
                itemBuilder:
                    (context, index) {

                  final task =
                  filteredTasks[index];

                  return Container(
                    margin:
                    const EdgeInsets.only(
                        bottom: 15),
                    padding:
                    const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey
                              .shade300,
                          blurRadius: 8,
                          offset:
                          const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        Text(task['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            )),

                        const SizedBox(height: 5),

                        Text(task['description'],
                            style: TextStyle(
                                color: Colors.grey.shade600)),

                        if (task['createdAt'] != null)
                          Text(
                            "Assigned: ${formatDateTime(task['createdAt'])}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                        if (task['dueDate'] != null)
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Due: ${formatDateTime(task['dueDate'])}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              Text(
                                daysRemaining(task['dueDate']),
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [

                            DropdownButton<String>(
                              value: task['status'],
                              underline: const SizedBox(),
                              items: [
                                "Pending",
                                "In Progress",
                                "Completed",
                                "Overdue"
                              ]
                                  .map((s) =>
                                  DropdownMenuItem(
                                      value: s,
                                      child: Text(s)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  updateStatus(task['_id'], v);
                                }
                              },
                            ),

                            ElevatedButton.icon(
                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.green,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () =>
                                  shareOnWhatsApp(task),
                              icon: const FaIcon(
                                FontAwesomeIcons.whatsapp,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Share Issue",
                                style: TextStyle(
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                      .animate()
                      .fade(duration: 400.ms)
                      .slideY(begin: 0.2);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String title, int value) {
    return Column(
      children: [
        Text(value.toString(),
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}