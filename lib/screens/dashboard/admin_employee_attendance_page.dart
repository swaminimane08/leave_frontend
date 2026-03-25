import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'salary_screen.dart';

class AdminEmployeeAttendancePage extends StatefulWidget {
  final String userId;
  final String name;
  final String token;

  const AdminEmployeeAttendancePage({
    super.key,
    required this.userId,
    required this.name,
    required this.token,
  });

  @override
  State<AdminEmployeeAttendancePage> createState() =>
      _AdminEmployeeAttendancePageState();
}

class _AdminEmployeeAttendancePageState
    extends State<AdminEmployeeAttendancePage> {

  List presentList = [];
  List lateList = [];
  List absentList = [];

  bool loading = true;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  // 🔥 NEW: hrs → min / hr min
  String formatDuration(dynamic value) {
    if (value == null) return "--";

    double hours;

    if (value is int) {
      hours = value.toDouble();
    } else if (value is double) {
      hours = value;
    } else {
      hours = double.tryParse(value.toString()) ?? 0;
    }

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
      return DateFormat("hh:mm a").format(parsed);
    } catch (e) {
      return time;
    }
  }

  void loadAttendance() async {
    setState(() => loading = true);

    final token = widget.token;

    final data = await ApiService.getEmployeeAttendance(
      widget.userId,
      selectedMonth.toString().padLeft(2, '0'),
      selectedYear.toString(),
      token,
    );

    int present = 0;
    int late = 0;
    int absent = 0;

    List pList = [];
    List lList = [];
    List aList = [];

    for (var item in data) {
      final status = item['status']?.toString() ?? "";

      if (status == "Present") {
        present++;
        pList.add(item);
      }
      else if (status == "Late") {
        late++;
        lList.add(item);

        present++;
        pList.add(item);
      }
      else {
        absent++;
        aList.add(item);
      }
    }

    setState(() {
      presentList = pList;
      lateList = lList;
      absentList = aList;
      loading = false;
    });
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

  Widget summaryCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.7),
              color,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ).animate().fade().slideY(begin: 0.2);
  }

  Widget buildSection(String title, Color color, List list) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.only(bottom: 10),
        title: Row(
          children: [
            CircleAvatar(
              radius: 6,
              backgroundColor: color,
            ),
            const SizedBox(width: 10),
            Text(
              "$title (${list.length})",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: list.map((item) {

          final sessions = item['sessions'] ?? [];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat("dd MMM yyyy")
                      .format(DateTime.parse(item['date'])),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    if (sessions.isEmpty)
                      const Text("--"),

                    ...List.generate(sessions.length, (i) {
                      final s = sessions[i];
                      return Text(
                        "S${i + 1}: ${formatTime(s['checkIn'])} - ${formatTime(s['checkOut'])}",
                      );
                    }),

                    const SizedBox(height: 4),

                    Text(
                      "Total: ${formatDuration(item['totalWorkingHours'])}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),

                    Text(
                      "Break: ${formatDuration(item['totalBreakHours'])}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          );
        }).toList(),
      ),
    ).animate().fade().slideX(begin: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.name,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: pickMonth,
          ),
          IconButton(
            icon: const Icon(Icons.currency_rupee),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalaryScreen(
                    userId: widget.userId,
                    name: widget.name,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              DateFormat("MMMM yyyy")
                  .format(DateTime(selectedYear, selectedMonth)),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                summaryCard("Present", presentList.length, Colors.green),
                summaryCard("Late", lateList.length, Colors.orange),
                summaryCard("Absent", absentList.length, Colors.red),
              ],
            ),
            const SizedBox(height: 10),
            buildSection("Present", Colors.green, presentList),
            buildSection("Late", Colors.orange, lateList),
            buildSection("Absent", Colors.red, absentList),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}