import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class AdminAttendancePage extends StatefulWidget {
  final String token;
  const AdminAttendancePage({super.key, required this.token});

  @override
  State<AdminAttendancePage> createState() =>
      _AdminAttendancePageState();
}

class _AdminAttendancePageState
    extends State<AdminAttendancePage> {

  List attendance = [];
  bool loading = true;

  int total = 0;
  int lateCount = 0;
  int presentCount = 0;
  int absentCount = 0;

  String selectedFilter = "All";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  // 🔥 TIME FORMAT (hrs → min/hr min)
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

  Future<void> loadAttendance() async {
    try {
      final token = widget.token;

      String today = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      ).toIso8601String().split("T")[0];

      final data = await ApiService.getAttendance(
        date: today,
        token: token,
      );

      int late = 0;
      int present = 0;
      int absent = 0;

      for (var item in data) {
        final status = item['status']?.toString() ?? "";

        if (status == "Present") {
          present++;
        }
        else if (status == "Late") {
          late++;
          present++;
        }
        else {
          absent++;
        }
      }

      setState(() {
        attendance = data;
        total = data.length;
        lateCount = late;
        presentCount = present;
        absentCount = absent;
        loading = false;
      });

    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

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
        loading = true;
      });

      await loadAttendance();
    }
  }

  String monthName(int month) {
    const months = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    return months[month - 1];
  }

  Color statusColor(String status) {
    if (status == "Late") return Colors.orange;
    if (status == "Present") return Colors.green;
    return Colors.red;
  }

  // 🔥 TIME FORMAT (clock)
  String formatTime(String? time) {
    if (time == null || time.isEmpty) return "--";
    try {
      final parsed = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("h:mm a").format(parsed);
    } catch (e) {
      return time;
    }
  }

  Widget summaryBox(String title, int value, Color color) {
    bool isSelected = selectedFilter == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter =
            selectedFilter == title ? "All" : title;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : color.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 5),
              Text("$value",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    List filteredAttendance = selectedFilter == "All"
        ? attendance
        : attendance.where((e) {
      if (selectedFilter == "Present") {
        return e['status'] == "Present" || e['status'] == "Late";
      }
      return e['status'] == selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text("Attendance"),
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

          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              "${selectedDate.day} ${monthName(selectedDate.month)} ${selectedDate.year}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                summaryBox("Present", presentCount, Colors.green),
                summaryBox("Late", lateCount, Colors.orange),
                summaryBox("Absent", absentCount, Colors.red),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: filteredAttendance.length,
              itemBuilder: (context, index) {

                final item = filteredAttendance[index];
                final sessions = item['sessions'] ?? [];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Text(
                              item['user']['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 5),

                            if (sessions.isEmpty)
                              const Text("No attendance"),

                            ...List.generate(sessions.length, (i) {
                              final s = sessions[i];
                              return Text(
                                "S${i + 1}: ${formatTime(s['checkIn'])} - ${formatTime(s['checkOut'])} (${formatDuration(s['workingHours'])})",
                              );
                            }),

                            const SizedBox(height: 5),

                            Text(
                              "Total: ${formatDuration(item['totalWorkingHours'])}",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),

                            Text(
                              "Break: ${formatDuration(item['totalBreakHours'])}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor(item['status']),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Text(
                          item['status'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fade().slideX(begin: 0.2);
              },
            ),
          ),
        ],
      ),
    );
  }
}