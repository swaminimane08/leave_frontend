import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'employee_home_page.dart';
import 'employee_attendance_page.dart';
import 'employee_leave_apply_page.dart';
import 'notification_page.dart';
import '../auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'employee_tasks_page.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() =>
      _EmployeeDashboardState();
}

class _EmployeeDashboardState
    extends State<EmployeeDashboard> {

  int selectedIndex = 0;

  final List<Widget> pages = [
    const EmployeeHomePage(),
    const EmployeeAttendancePage(),
    const EmployeeLeaveApplyPage(),
    const EmployeeTasksPage(),
  ];

  final List<String> titles = [
    "Employee Dashboard",
    "My Attendance",
    "Apply Leave",
    "My Tasks",
  ];

  void logout() async {
    SharedPreferences prefs =
    await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) =>
          const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// 🔥 Gradient AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // 🔥 icons white
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF1976D2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(
            color: Colors.white, // 🔥 TITLE WHITE
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [

          /// 🔔 NOTIFICATION ICON
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationPage(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: const Icon(
                Icons.notifications_active,
                size: 26,
                color: Colors.white, // 🔥 WHITE
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                duration: 2000.ms,
                color: Colors.white70,
              )
                  .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1200.ms,
              ),
               ),
          ),

          /// 🔓 LOGOUT ICON
          IconButton(
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
              color: Colors.white, // 🔥 WHITE
            ),
          ),
        ],
      ),

      /// 🔥 Animated Page Transition
      body: AnimatedSwitcher(
        duration:
        const Duration(milliseconds: 400),
        transitionBuilder:
            (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: pages[selectedIndex],
      ),

      /// 🔥 Modern Bottom Navigation
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: selectedIndex,
          selectedItemColor:
          Colors.blue[800],
          unselectedItemColor:
          Colors.grey,
          showUnselectedLabels: true,
          type:
          BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: selectedIndex == 0 ? 1.2 : 1,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.home_rounded),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: selectedIndex == 1 ? 1.2 : 1,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.access_time_rounded),
              ),
              label: "Attendance",
            ),
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: selectedIndex == 2 ? 1.2 : 1,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.event_available_rounded),
              ),
              label: "Leave",
            ),
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: selectedIndex == 3 ? 1.2 : 1,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.task_alt_rounded),
              ),
              label: "Tasks",
            ),
          ],
        ),
      ),
    );
  }
}
