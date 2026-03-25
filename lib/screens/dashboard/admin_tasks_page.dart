import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import 'admin_employee_tasks_page.dart';

class AdminTasksPage extends StatefulWidget {
  const AdminTasksPage({super.key});

  @override
  State<AdminTasksPage> createState() => _AdminTasksPageState();
}

class _AdminTasksPageState extends State<AdminTasksPage> {
  List users = [];
  List filteredUsers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() async {
    final data = await ApiService.getUsers();
    setState(() {
      users =
          data.where((u) => u['role'] == "EMPLOYEE").toList();
      filteredUsers = users;
      loading = false;
    });
  }

  void searchUser(String value) {
    setState(() {
      filteredUsers = users
          .where((user) =>
      user['name']
          .toLowerCase()
          .contains(value.toLowerCase()) ||
          user['email']
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Task Management",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        iconTheme:
        const IconThemeData(color: Colors.black),
      ),
      body: loading
          ? const Center(
          child: CircularProgressIndicator())
          : Column(
        children: [

          /// Search
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: searchUser,
              decoration: InputDecoration(
                hintText: "Search Employee",
                prefixIcon:
                const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 15),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user =
                filteredUsers[index];

                return Container(
                  margin:
                  const EdgeInsets.only(
                      bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                        15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .grey.shade300,
                        blurRadius: 6,
                        offset:
                        const Offset(0, 3),
                      )
                    ],
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminEmployeeTasksPage(
                                employeeId:
                                user['_id'],
                                employeeName:
                                user['name'],
                              ),
                        ),
                      );
                    },
                    leading:
                    const CircleAvatar(
                      backgroundColor:
                      Colors.blue,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      user['name'],
                      style:
                      const TextStyle(
                          fontWeight:
                          FontWeight
                              .bold),
                    ),
                    subtitle:
                    Text(user['email']),
                    trailing:
                    const Icon(Icons
                        .arrow_forward_ios),
                  ),
                )
                    .animate()
                    .fade(duration: 400.ms)
                    .slideY(begin: 0.2);
              },
            ),
          ),
        ],
      ),
    );
  }
}