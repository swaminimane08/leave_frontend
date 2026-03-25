import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_home_page.dart';
import 'admin_users_page.dart';
import 'admin_attendance_page.dart';
import 'admin_leave_page.dart';
import 'admin_tasks_page.dart';
import '../auth/login_screen.dart';
import 'expenses_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  String adminName = "Admin";
  String token = ""; // ✅ FIX

  int pendingLeaves = 0;
  int pendingTasks = 0;

  final List<String> titles = [
    "Dashboard",
    "Employees",
    "Attendance",
    "Leave Requests",
    "Task Management",
    "Company Expenses"
  ];

  @override
  void initState() {
    super.initState();
    loadAdminName();
    loadToken(); // ✅ FIX
  }

  void loadToken() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      token = prefs.getString("token") ?? "";
    });
  }

  void loadAdminName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString("name") ?? "Admin";
    });
  }

  void logout() async {
    SharedPreferences prefs =
    await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    // ✅ FIX: token load होईपर्यंत loader
    if (token.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ FIX: pages build() मध्ये
    final List<Widget> pages = [
      const AdminHomePage(),
      const AdminUsersPage(),
      AdminAttendancePage(token: token),
      const AdminLeavePage(),
      const AdminTasksPage(),
      const ExpensesPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E),
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme:
        const IconThemeData(color: Colors.white),
      ),

      drawer: Drawer(
        child: Container(
          color: const Color(0xFF1A237E),
          child: Column(
            children: [

              /// HEADER
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF283593),
                ),
                accountName: Text(
                  adminName,
                  style:
                  const TextStyle(color: Colors.white),
                ),
                accountEmail: const Text(
                  "Admin Panel",
                  style:
                  TextStyle(color: Colors.white70),
                ),
                currentAccountPicture:
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.indigo,
                  ),
                ),
              ),

              buildDrawerItem(
                  Icons.dashboard, "Dashboard", 0),
              buildDrawerItem(
                  Icons.people, "Employees", 1),
              buildDrawerItem(Icons.access_time,
                  "Attendance", 2),
              buildDrawerItem(
                  Icons.event, "Leave Request", 3),
              buildDrawerItem(
                  Icons.task_alt, "Task Management", 4),
              buildDrawerItem(
                  Icons.account_balance_wallet,
                  "Company Expenses",
                  5),

              const Spacer(),

              ListTile(
                leading: const Icon(Icons.logout,
                    color: Colors.white),
                title: const Text(
                  "Logout",
                  style:
                  TextStyle(color: Colors.white),
                ),
                onTap: logout,
              ),
            ],
          ),
        ),
      ),

      body: AnimatedSwitcher(
        duration:
        const Duration(milliseconds: 400),
        child: KeyedSubtree(
          key: ValueKey(selectedIndex),
          child: pages[selectedIndex]
              .animate()
              .fade(duration: 400.ms)
              .slideY(begin: 0.1),
        ),
      ),
    );
  }

  Widget buildDrawerItem(
      IconData icon, String title, int index) {
    bool isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Colors.amber
            : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Colors.amber
              : Colors.white,
          fontWeight: isSelected
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget buildDrawerItemWithBadge(
      IconData icon,
      String title,
      int index,
      int badgeCount) {
    bool isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Colors.amber
            : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Colors.amber
              : Colors.white,
          fontWeight: isSelected
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
      trailing: badgeCount > 0
          ? Container(
        padding:
        const EdgeInsets.all(6),
        decoration:
        const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          "$badgeCount",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      )
          : null,
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }
}