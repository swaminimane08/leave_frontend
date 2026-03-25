import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class EmployeeLeaveApplyPage extends StatefulWidget {
  const EmployeeLeaveApplyPage({super.key});

  @override
  State<EmployeeLeaveApplyPage> createState() =>
      _EmployeeLeaveApplyPageState();
}

class _EmployeeLeaveApplyPageState
    extends State<EmployeeLeaveApplyPage> {

  String leaveType = "Casual";
  DateTime? fromDate;
  DateTime? toDate;
  final reasonController = TextEditingController();

  bool loading = false;
  int totalDays = 0;

  final leaveTypes = [
    "Casual",
    "Sick",
    "Earned",
    "Half Day",
    "Work From Home"
  ];

  // ================= CALCULATE DAYS =================
  void calculateDays() {
    if (fromDate != null && toDate != null) {

      if (toDate!.isBefore(fromDate!)) {
        totalDays = 0;
        return;
      }

      // 🔥 WFH always 1 day
      if (leaveType == "Work From Home") {
        totalDays = 1;
        return;
      }

      // 🔥 Half day always 1
      if (leaveType == "Half Day") {
        totalDays = 1;
        return;
      }

      totalDays =
          toDate!.difference(fromDate!).inDays + 1;

      setState(() {});
    }
  }

  // ================= DATE PICKER =================
  Future<void> pickDate(bool isFrom) async {

    DateTime today = DateTime.now();
    DateTime normalizedToday =
    DateTime(today.year, today.month, today.day);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: normalizedToday,
      firstDate: normalizedToday,
      lastDate: DateTime(2030),
    );

    if (picked != null) {

      if (isFrom) {
        fromDate = picked;

        if (leaveType == "Work From Home" ||
            leaveType == "Half Day") {
          toDate = picked;
        }

        if (toDate != null &&
            toDate!.isBefore(fromDate!)) {
          toDate = null;
        }

      } else {
        toDate = picked;
      }

      calculateDays();
      setState(() {});
    }
  }

  // ================= APPLY =================
  Future<void> applyLeave() async {

    DateTime today = DateTime.now();
    DateTime normalizedToday =
    DateTime(today.year, today.month, today.day);

    if (fromDate == null ||
        toDate == null ||
        reasonController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text("Please fill all fields")),
      );
      return;
    }

    if (fromDate!.isBefore(normalizedToday)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Cannot apply for past dates")),
      );
      return;
    }

    if (toDate!.isBefore(fromDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "To Date cannot be before From Date")),
      );
      return;
    }

    // Half Day validation
    if (leaveType == "Half Day" &&
        fromDate != toDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Half Day must be same date")),
      );
      return;
    }

    // WFH validation
    if (leaveType == "Work From Home" &&
        fromDate != toDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "WFH must be single day")),
      );
      return;
    }

    setState(() => loading = true);

    final res = await ApiService.applyLeave({
      "leaveType": leaveType,
      "fromDate":
      DateFormat("yyyy-MM-dd")
          .format(fromDate!),
      "toDate":
      DateFormat("yyyy-MM-dd")
          .format(toDate!),
      "reason": reasonController.text,
    });

    setState(() => loading = false);

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(content: Text(res['message'])),
    );

    if (res['message'] ==
        "Leave Applied Successfully") {
      fromDate = null;
      toDate = null;
      totalDays = 0;
      reasonController.clear();
      setState(() {});
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FA),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 70, bottom: 50),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1A237E),
                    Color(0xFF3949AB),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.home_work,
                      color: Colors.white,
                      size: 50)
                      .animate()
                      .scale(),
                  const SizedBox(height: 12),
                  const Text(
                    "Apply Leave / WFH",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ).animate().fade(),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding:
              const EdgeInsets.symmetric(
                  horizontal: 20),
              child: Container(
                padding:
                const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue
                          .withOpacity(0.15),
                      blurRadius: 20,
                      offset:
                      const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    buildDropdown(),
                    const SizedBox(height: 20),
                    buildDateInput(
                        "From Date",
                        fromDate,
                            () => pickDate(true),
                        Icons.date_range,
                        Colors.blue),
                    const SizedBox(height: 20),
                    buildDateInput(
                        "To Date",
                        toDate,
                            () => pickDate(false),
                        Icons.calendar_month,
                        Colors.indigo),
                    const SizedBox(height: 20),
                    if (totalDays > 0)
                      Container(
                        padding:
                        const EdgeInsets.all(12),
                        decoration:
                        BoxDecoration(
                          color: leaveType ==
                              "Work From Home"
                              ? Colors.green
                              : Colors.indigo,
                          borderRadius:
                          BorderRadius
                              .circular(15),
                        ),
                        child: Text(
                          leaveType ==
                              "Work From Home"
                              ? "1 Day (WFH)"
                              : "$totalDays Days Selected",
                          style:
                          const TextStyle(
                            color:
                            Colors.white,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextField(
                      controller:
                      reasonController,
                      maxLines: 3,
                      decoration:
                      InputDecoration(
                        labelText: leaveType ==
                            "Work From Home"
                            ? "WFH Reason"
                            : "Reason",
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    loading
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                      onTap:
                      applyLeave,
                      child: Container(
                        width:
                        double.infinity,
                        padding:
                        const EdgeInsets
                            .symmetric(
                            vertical:
                            16),
                        decoration:
                        BoxDecoration(
                          gradient:
                          const LinearGradient(
                            colors: [
                              Color(
                                  0xFF1A237E),
                              Color(
                                  0xFF3949AB),
                            ],
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                              18),
                        ),
                        child:
                        const Center(
                          child: Text(
                            "Submit Request",
                            style:
                            TextStyle(
                              color:
                              Colors
                                  .white,
                              fontSize:
                              16,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fade()
                        .slideY(begin: 0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdown() {
    return DropdownButtonFormField(
      value: leaveType,
      decoration: InputDecoration(
        labelText: "Type",
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
      ),
      items: leaveTypes
          .map((e) =>
          DropdownMenuItem(
            value: e,
            child: Text(e),
          ))
          .toList(),
      onChanged: (val) {
        setState(() {
          leaveType = val.toString();
          totalDays = 0;
          calculateDays();
        });
      },
    );
  }

  Widget buildDateInput(
      String label,
      DateTime? date,
      VoidCallback onTap,
      IconData icon,
      Color iconColor) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon:
        Icon(icon, color: iconColor),
        labelText: date == null
            ? label
            : DateFormat("dd MMM yyyy")
            .format(date),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
      ),
      onTap: onTap,
    );
  }
}