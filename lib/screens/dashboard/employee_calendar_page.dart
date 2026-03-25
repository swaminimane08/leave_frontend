import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/api_service.dart';

class EmployeeCalendarPage extends StatefulWidget {
  final String userId;

  const EmployeeCalendarPage({super.key, required this.userId});
  @override
  State<EmployeeCalendarPage> createState() =>
      _EmployeeCalendarPageState();
}

class _EmployeeCalendarPageState
    extends State<EmployeeCalendarPage> {

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  Map<String, String> attendanceMap = {}; // 🔥 date → status

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  // ✅ LOAD MONTH DATA
  Future<void> loadAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final data = await ApiService.getEmployeeAttendance(
        "self",
        focusedDay.month.toString().padLeft(2, '0'), // ✅ FIX
        focusedDay.year.toString(),                  // ✅ FIX
        token,                                       // ✅ FIX
      );

      Map<String, String> temp = {};

      for (var item in data) {
        temp[item['date']] = item['status'];
      }

      setState(() {
        attendanceMap = temp;
      });

    } catch (e) {
      print("Calendar Error: $e");
    }
  }

  Color getColor(String? status) {
    if (status == "Present") return Colors.green;
    if (status == "Late") return Colors.orange;
    if (status == "Absent") return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title:
      const Text("Attendance Calendar")),

      body: Column(
        children: [

          TableCalendar(
            firstDay:
            DateTime.utc(2023, 1, 1),
            lastDay:
            DateTime.utc(2030, 12, 31),
            focusedDay:
            focusedDay,

            selectedDayPredicate:
                (day) =>
                isSameDay(selectedDay, day),

            onDaySelected:
                (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },

            // 🔥 MARK ATTENDANCE
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                String date =
                day.toIso8601String().split("T")[0];

                String? status = attendanceMap[date];

                if (status != null) {
                  return Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: getColor(status),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${day.day}",
                      style: const TextStyle(
                          color: Colors.white),
                    ),
                  );
                }

                return null;
              },
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 SELECTED DAY STATUS
          Builder(
            builder: (_) {
              String date = selectedDay
                  .toIso8601String()
                  .split("T")[0];

              String status =
                  attendanceMap[date] ?? "Absent";

              return Text(
                "Status: $status",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: getColor(status),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}