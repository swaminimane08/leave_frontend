import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SalaryHistoryPage extends StatefulWidget {
  final String userId;

  const SalaryHistoryPage({
    super.key,
    required this.userId,
  });

  @override
  State<SalaryHistoryPage> createState() =>
      _SalaryHistoryPageState();
}

class _SalaryHistoryPageState
    extends State<SalaryHistoryPage> {

  List salaryList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final data =
    await ApiService.getSalaryHistory(widget.userId);

    setState(() {
      salaryList = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Salary History",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : salaryList.isEmpty
          ? const Center(
        child: Text(
          "No Salary Records",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: salaryList.length,
        itemBuilder: (context, index) {

          final item = salaryList[index];

          /// 🔥 FIXED STATUS LOGIC (100% SAFE)
          final rawStatus =
              item["status"]?.toString() ?? "";

          final status =
          rawStatus.toUpperCase().trim();

          final isPaid =
          status.contains("PAID");

          return Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                /// 🔥 TOP ROW
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      "Month: ${item["month"] ?? "-"}",
                      style: const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 16),
                    ),

                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPaid
                            ? "PAID"
                            : "PENDING",
                        style: TextStyle(
                          color: isPaid
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 25),

                /// DETAILS
                infoRow(
                  "Salary Period",
                  "${item["periodFrom"] ?? "-"} to ${item["periodTo"] ?? "-"}",
                ),

                infoRow(
                    "Net Salary",
                    "₹${item["netSalary"] ?? 0}"),

                infoRow(
                    "Present Days",
                    item["presentDays"] ?? 0),

                infoRow(
                    "Absent Days",
                    item["absentDays"] ?? 0),

                infoRow(
                    "Late Count",
                    item["lateCount"] ?? 0),

                const SizedBox(height: 10),

                /// 🔥 PAYMENT MODE (ONLY IF PAID)
                if (isPaid)
                  Text(
                    "Payment Mode: ${item["paymentMode"] ?? "-"}",
                    style: const TextStyle(
                        fontWeight:
                        FontWeight.w600),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget infoRow(String title, dynamic value) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value.toString(),
            style: const TextStyle(
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}