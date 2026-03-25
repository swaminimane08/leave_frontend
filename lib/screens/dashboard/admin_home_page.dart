import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {

  int totalEmployees = 0;
  int presentToday = 0;
  int lateToday = 0;
  int absentToday = 0;

  int pendingLeaves = 0;

  int totalTasks = 0;
  int pendingTasks = 0;
  int completedTasks = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  // 🔥 FIX (ONLY CHANGE)
  Future<void> loadDashboardData() async {
    try {

      final users = await ApiService.getUsers();
      totalEmployees =
          users.where((u) => u['role'] != "ADMIN").length;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      String today =
      DateTime.now().toIso8601String().split("T")[0];

      final attendance = await ApiService.getAttendance(
        date: today,
        token: token,
      );

      presentToday = 0;
      lateToday = 0;

      for (var item in attendance) {
        final status = item['status']?.toString() ?? "";

        if (status == "Present") {
          presentToday++;
        }
        else if (status == "Late") {
          lateToday++;
          presentToday++;
        }
      }

      absentToday = totalEmployees - presentToday;

      final leaves = await ApiService.getAllLeaves();
      pendingLeaves =
          leaves.where((l) => l['status'] == "Pending").length;

      final taskData = await ApiService.getTaskAnalytics();

      totalTasks = taskData['total'] ?? 0;
      pendingTasks = taskData['pending'] ?? 0;
      completedTasks = taskData['completed'] ?? 0;

      setState(() {
        loading = false;
      });

    } catch (e) {
      print("Dashboard Error: $e");
      setState(() {
        loading = false;
      });
    }
  }

  Widget buildCard(
      String title,
      int value,
      Color color,
      IconData icon, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: color),
            const SizedBox(height: 10),
            Text(
              "$value",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    );
  }

  void showEmployeeTaskPopup() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
        const Center(child: CircularProgressIndicator()),
      );

      final data =
      await ApiService.getEmployeeTaskSummary();

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Employee Task Summary"),
          content: SizedBox(
            width: double.maxFinite,
            child: data.isEmpty
                ? const Text("No task data available")
                : ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];

                return Card(
                  elevation: 3,
                  margin:
                  const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      item['employeeName'] ?? "",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding:
                      const EdgeInsets.only(top: 6),
                      child: Text(
                        "Total: ${item['total']}   |   "
                            "Pending: ${item['pending']}   |   "
                            "Completed: ${item['completed']}",
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Close"),
            )
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load summary"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          setState(() => loading = true);
          await loadDashboardData();
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.95,
            children: [

              buildCard(
                  "Employees",
                  totalEmployees,
                  Colors.blue,
                  Icons.people),

              buildCard(
                  "Present Today",
                  presentToday,
                  Colors.green,
                  Icons.check_circle),

              buildCard(
                  "Late Today",
                  lateToday,
                  Colors.orange,
                  Icons.access_time),

              buildCard(
                  "Absent Today",
                  absentToday,
                  Colors.red,
                  Icons.close),

              buildCard(
                  "Pending Leaves",
                  pendingLeaves,
                  Colors.red,
                  Icons.event),

              buildCard(
                  "Total Tasks",
                  totalTasks,
                  Colors.indigo,
                  Icons.assignment,
                  onTap: showEmployeeTaskPopup),

              buildCard(
                  "Pending Tasks",
                  pendingTasks,
                  Colors.deepOrange,
                  Icons.pending_actions,
                  onTap: showEmployeeTaskPopup),

              buildCard(
                  "Completed Tasks",
                  completedTasks,
                  Colors.teal,
                  Icons.task_alt,
                  onTap: showEmployeeTaskPopup),
            ],
          ),
        ),
      ),
    );
  }
}