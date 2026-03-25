// 🔥 SAME IMPORTS (unchanged)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class EmployeeAttendanceHisPage extends StatefulWidget {
  const EmployeeAttendanceHisPage({super.key});

  @override
  State<EmployeeAttendanceHisPage> createState() =>
      _EmployeeAttendanceHisPageState();
}

class _EmployeeAttendanceHisPageState
    extends State<EmployeeAttendanceHisPage> {

  List presentList = [];
  List lateList = [];
  List absentList = [];

  // 🔥 NEW SALARY LIST
  List salaryList = [];

  bool loading = true;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  String token = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";

    await loadAttendance();
    await loadSalary(); // 🔥 NEW

    setState(() {
      loading = false;
    });
  }

  // 🔥 SALARY API CALL
  Future<void> loadSalary() async {
    final data = await ApiService.getMySalary(token: token);

    setState(() {
      salaryList = data;
    });
  }

  // 🔥 TIME FORMAT
  String formatDuration(dynamic value) {
    if (value == null) return "0 min";

    double hours = value is int
        ? value.toDouble()
        : value is double
        ? value
        : double.tryParse(value.toString()) ?? 0;

    int totalMinutes = (hours * 60).round();

    if (totalMinutes < 60) {
      return "$totalMinutes min";
    } else {
      int h = totalMinutes ~/ 60;
      int m = totalMinutes % 60;
      return m == 0 ? "$h hr" : "$h hr $m min";
    }
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return "--";
    try {
      final parsed = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("h:mm a").format(parsed);
    } catch (e) {
      return time;
    }
  }

  Future<void> loadAttendance() async {

    final data = await ApiService.getMyAttendance(
      token: token,
      month: selectedMonth.toString().padLeft(2, '0'),
      year: selectedYear.toString(),
    );

    List pList = [];
    List lList = [];
    List aList = [];

    for (var item in data) {
      final status = item['status']?.toString() ?? "";

      if (status == "Present") {
        pList.add(item);
      } else if (status == "Late") {
        lList.add(item);
        pList.add(item);
      } else {
        aList.add(item);
      }
    }

    setState(() {
      presentList = pList;
      lateList = lList;
      absentList = aList;
    });
  }

  // 🔥 SALARY UI
  Widget buildSalarySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Salary History",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),

          const SizedBox(height: 10),

          ...salaryList.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 6)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "${item["month"]}/${item["year"]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text("Salary: ₹${item["salary"] ?? 0}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  Text("Paid: ₹${item["paid"] ?? 0}"),
                  Text("Remaining: ₹${item["remaining"] ?? 0}"),

                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // 🔥 SUMMARY CARDS
  Widget summaryCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              title == "Present"
                  ? Icons.check_circle
                  : title == "Late"
                  ? Icons.access_time
                  : Icons.cancel,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 ATTENDANCE UI (UNCHANGED)
  Widget buildAttendanceSection(String title, Color color, List list) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "$title (${list.length})",
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ...list.map((item) {

            final sessions = item['sessions'] ?? [];

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    DateFormat("dd MMM yyyy")
                        .format(DateTime.parse(item["date"])),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ...List.generate(sessions.length, (i) {
                    final s = sessions[i];
                    return Text(
                      "S${i + 1}: ${formatTime(s["checkIn"])} - ${formatTime(s["checkOut"])}",
                    );
                  }),

                  const SizedBox(height: 10),

                  Text(
                    "Total: ${formatDuration(item["totalWorkingHours"])}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),

                  Text(
                    "Break: ${formatDuration(item["totalBreakHours"])}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          })
        ],
      ),
    );
  }

  Future<void> pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(selectedYear, selectedMonth),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      selectedMonth = picked.month;
      selectedYear = picked.year;
      loadAttendance();
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0D47A1),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month,color: Colors.white),
            onPressed: pickMonth,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 10),

            Row(
              children: [
                summaryCard("Present", presentList.length, Colors.green),
                summaryCard("Late", lateList.length, Colors.orange),
                summaryCard("Absent", absentList.length, Colors.red),
              ],
            ),

            const SizedBox(height: 10),

            // 🔥 NEW SALARY SECTION
            buildSalarySection(),

            buildAttendanceSection("Present", Colors.green, presentList),
            buildAttendanceSection("Late", Colors.orange, lateList),
            buildAttendanceSection("Absent", Colors.red, absentList),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}