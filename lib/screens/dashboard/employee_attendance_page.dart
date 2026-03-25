import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // 🔥 ADD
import '../../services/api_service.dart';

class EmployeeAttendancePage extends StatefulWidget {
  const EmployeeAttendancePage({super.key});

  @override
  State<EmployeeAttendancePage> createState() =>
      _EmployeeAttendancePageState();
}

class _EmployeeAttendancePageState
    extends State<EmployeeAttendancePage> {

  bool loading = false;
  String statusMessage = "";

  Map<String, dynamic>? todayData;

  // 🔥 CLEAN TIME FORMAT (ONLY HOURS → MIN/HR MIN)
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

  // 🔥 INDIA TIME FORMAT (AM/PM)
  String formatClock(String? time) {
    if (time == null || time.isEmpty) return "--";
    try {
      final parsed = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh:mm a").format(parsed); // 👉 03:15 PM
    } catch (e) {
      return time;
    }
  }

  Future<bool> handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() {
        statusMessage =
        "Enable Location from Phone Settings";
      });
      return false;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
      await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        statusMessage =
        "Location Permission Required";
      });
      return false;
    }

    return true;
  }

  Future<void> loadToday() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final res = await ApiService.getTodayAttendance(token: token);

    setState(() {
      todayData = res;
    });
  }

  Future<void> checkIn() async {
    setState(() {
      loading = true;
      statusMessage = "";
    });

    try {
      bool allowed = await handlePermission();

      if (!allowed) {
        setState(() => loading = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final res = await ApiService.checkIn(
        token: token,
        lat: position.latitude,
        lon: position.longitude,
      );

      await loadToday();

      setState(() {
        loading = false;
        statusMessage = res['msg'] ?? "";
      });

    } catch (e) {
      setState(() {
        loading = false;
        statusMessage = "Check-In Failed";
      });
    }
  }

  Future<void> checkOut() async {
    setState(() {
      loading = true;
      statusMessage = "";
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final res = await ApiService.checkOut(
        token: token,
      );

      await loadToday();

      setState(() {
        loading = false;
        statusMessage = res['msg'] ?? "Something went wrong";
      });

    } catch (e) {
      setState(() {
        loading = false;
        statusMessage = "Check-Out Failed";
      });
    }
  }

  Widget buildButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.8),
              color,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: Colors.white,
                size: 32),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fade(duration: 500.ms)
        .slideY(begin: 0.2);
  }

  @override
  void initState() {
    super.initState();
    loadToday();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF1976D2),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.access_time,
                      color: Colors.white,
                      size: 40),
                  SizedBox(height: 10),
                  Text(
                    "My Attendance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            if (loading)
              const CircularProgressIndicator()
            else ...[
              buildButton(
                text: "Check In",
                icon: Icons.login,
                color: Colors.green,
                onTap: checkIn,
              ),
              const SizedBox(height: 20),
              buildButton(
                text: "Check Out",
                icon: Icons.logout,
                color: Colors.red,
                onTap: checkOut,
              ),
            ],

            const SizedBox(height: 20),

            if (statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            if (todayData != null) ...[
              Text(
                "Total Working: ${formatDuration(todayData!["totalWorkingHours"])}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Break: ${formatDuration(todayData!["totalBreakHours"])}",
              ),

              const SizedBox(height: 15),

              ...List.generate(
                todayData!["sessions"]?.length ?? 0,
                    (i) {
                  final s = todayData!["sessions"][i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "Session ${i + 1}: ${formatClock(s["checkIn"])} - ${formatClock(s["checkOut"] ?? "")} → ${formatDuration(s["workingHours"])}",
                    ),
                  );
                },
              )
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}