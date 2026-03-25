import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'admin_employee_attendance_page.dart';
import 'employee_documents_screen.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
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
      users = data;
      filteredUsers = data;
      loading = false;
    });
  }

  void searchUser(String value) {
    setState(() {
      filteredUsers = users.where((user) =>
      user['name']
          .toLowerCase()
          .contains(value.toLowerCase()) ||
          user['email']
              .toLowerCase()
              .contains(value.toLowerCase())).toList();
    });
  }

  Future<void> deleteUser(String id) async {
    await ApiService.deleteUser(id);

    setState(() {
      users.removeWhere((u) => u['_id'] == id);
      filteredUsers.removeWhere((u) => u['_id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User Deleted")),
    );
  }

  Future<bool> confirmDelete() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text("Delete User"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Employees",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          /// 🔍 Search
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: searchUser,
              decoration: InputDecoration(
                hintText: "Search Employee",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 👥 List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];

                return Dismissible(
                  key: Key(user['_id']),
                  direction: DismissDirection.endToStart,

                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),

                  /// 🔥 CONFIRM DELETE
                  confirmDismiss: (direction) async {
                    final confirm = await confirmDelete();

                    if (confirm) {
                      await deleteUser(user['_id']);
                      return true;
                    }
                    return false;
                  },

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(

                      /// 🔥 Attendance Page
                      onTap: () async {
                        final prefs =
                        await SharedPreferences.getInstance();
                        final token =
                            prefs.getString("token") ?? "";

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminEmployeeAttendancePage(
                                  userId: user['_id'],
                                  name: user['name'],
                                  token: token,
                                ),
                          ),
                        );
                      },

                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),

                      title: Text(
                        user['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Text(user['email']),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          /// 📁 Documents
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.folder,
                                color: Colors.orange,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EmployeeDocumentsScreen(
                                          employeeId: user['_id'],
                                          employeeName: user['name'],
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 8),

                          /// 👤 Role
                          Text(
                            user['role'],
                            style: TextStyle(
                              color: user['role'] == "ADMIN"
                                  ? Colors.deepPurple
                                  : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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