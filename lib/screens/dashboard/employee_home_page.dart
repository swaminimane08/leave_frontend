import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import 'EmployeeAttendanceHisPage.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  State<EmployeeHomePage> createState() =>
      _EmployeeHomePageState();
}

class _EmployeeHomePageState
    extends State<EmployeeHomePage> {

  Map<String, dynamic>? todayAttendance;
  String name = "";

  Timer? timer;
  Duration workingDuration = const Duration();

  bool loading = true;

  File? selectedImage;
  String? profileImageName;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  // ✅ hrs → min / hr min
  String formatDuration(double hours) {
    int totalMinutes = (hours * 60).round();

    if (totalMinutes < 60) {
      return "$totalMinutes min";
    } else {
      int h = totalMinutes ~/ 60;
      int m = totalMinutes % 60;

      return m == 0 ? "$h hr" : "$h hr $m min";
    }
  }

  Future<void> loadDashboard() async {

    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString("name") ?? "";

    final profile = await ApiService.getProfile();
    if (profile != null) {
      profileImageName = profile["profileImage"];
    }

    final token = prefs.getString("token") ?? "";

    todayAttendance =
    await ApiService.getTodayAttendance(token: token);

    if (todayAttendance != null &&
        todayAttendance!["sessions"] != null &&
        todayAttendance!["sessions"].isNotEmpty) {

      final sessions = todayAttendance!["sessions"];
      final lastSession = sessions.last;

      if (lastSession["checkIn"] != null &&
          lastSession["checkOut"] == null) {
        startTimer(lastSession["checkIn"]);
      }
    }

    setState(() {
      loading = false;
    });
  }

  void startTimer(String checkInTime) {
    try {
      final now = DateTime.now();
      final parts = checkInTime.split(":");

      final checkInDate = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      timer?.cancel();

      timer = Timer.periodic(
        const Duration(seconds: 1),
            (_) {
          final diff =
          DateTime.now().difference(checkInDate);

          setState(() {
            workingDuration = diff;
          });
        },
      );
    } catch (e) {
      print("TIMER ERROR: $e");
    }
  }

  Future<void> handleCheckIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      LocationPermission permission =
      await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission required ❌")),
        );
        return;
      }

      Position position =
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final res = await ApiService.checkIn(
        token: token,
        lat: position.latitude,
        lon: position.longitude,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["msg"] ?? "Done")),
      );

      await loadDashboard();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong ❌")),
      );
    }
  }

  Future<void> handleCheckOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final res = await ApiService.checkOut(
        token: token,
      );

      timer?.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["msg"] ?? "Check-Out Done")),
      );

      await loadDashboard();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check-Out Failed")),
      );
    }
  }

  // ✅ FIXED (pickImage error solved)
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked =
    await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      File file = File(picked.path);

      final imageName =
      await ApiService.uploadProfileImage(file);

      if (imageName != null) {
        setState(() {
          selectedImage = file;
          profileImageName = imageName;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated")),
        );
      }
    }
  }

  Future<void> deleteImage() async {
    final success =
    await ApiService.deleteProfilePhoto();

    if (success) {
      setState(() {
        selectedImage = null;
        profileImageName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Removed")),
      );
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good Morning ☀️";
    if (hour < 17) return "Good Afternoon 🌤";
    return "Good Evening 🌙";
  }

  Widget buildWorkingTime() {

    double totalHours = 0;

    if (todayAttendance != null &&
        todayAttendance!["totalWorkingHours"] != null) {

      var val = todayAttendance!["totalWorkingHours"];

      if (val is int) {
        totalHours = val.toDouble();
      } else if (val is double) {
        totalHours = val;
      }
    }

    final runningHours =
        workingDuration.inMinutes / 60;

    final finalHours =
        totalHours + runningHours;

    Color badgeColor = Colors.blue;

    if (finalHours >= 9) {
      badgeColor = Colors.purple;
    } else if (finalHours >= 8) {
      badgeColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Working Time",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            formatDuration(finalHours),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Center(
          child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                ],
              ),
              borderRadius:
              BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return Container(
                          padding:
                          const EdgeInsets.all(20),
                          height: 160,
                          child: Column(
                            children: [
                              ListTile(
                                leading:
                                const Icon(Icons.edit),
                                title: const Text("Edit Profile Photo"),
                                onTap: () {
                                  Navigator.pop(context);
                                  pickImage();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete, color: Colors.red),
                                title: const Text("Delete Photo"),
                                onTap: () {
                                  Navigator.pop(context);
                                  deleteImage();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage:
                    selectedImage != null
                        ? FileImage(selectedImage!)
                        : profileImageName != null
                        ? NetworkImage(
                        "${ApiService.serverUrl}/uploads/$profileImageName")
                        : null,
                    child: selectedImage == null &&
                        profileImageName == null
                        ? Text(
                      name.isNotEmpty
                          ? name[0].toUpperCase()
                          : "A",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    )
                        : null,
                  ),
                ),

                const SizedBox(width: 15),

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      getGreeting(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Office Time: 10:00 AM - 6:00 PM",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  todayAttendance?["status"] ?? "Absent",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                buildWorkingTime(),

                const SizedBox(height: 20),

                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton(
                        onPressed: handleCheckIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          "Check In",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: handleCheckOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          "Check Out",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmployeeAttendanceHisPage(),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      "View Attendance History",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}