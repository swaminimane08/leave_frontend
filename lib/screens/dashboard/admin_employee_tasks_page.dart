import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class AdminEmployeeTasksPage extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const AdminEmployeeTasksPage({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  State<AdminEmployeeTasksPage> createState() =>
      _AdminEmployeeTasksPageState();
}

class _AdminEmployeeTasksPageState
    extends State<AdminEmployeeTasksPage> {

  List tasks = [];
  List filteredTasks = [];
  bool loading = true;

  int total = 0;
  int pending = 0;
  int completed = 0;

  DateTime selectedMonth = DateTime.now();

  final titleController = TextEditingController();
  final descController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  String formatDueDate(String dateString) {
    final date = DateTime.parse(dateString).toLocal();
    return DateFormat("dd MMM yyyy • hh:mm a").format(date);
  }

  void loadTasks() async {
    final data =
    await ApiService.getTasksByEmployee(widget.employeeId);

    tasks = data['tasks'];

    total = tasks.length;
    pending =
        tasks.where((t) => t['status'] == "Pending").length;
    completed =
        tasks.where((t) => t['status'] == "Completed").length;

    filterTasksByMonth();

    setState(() {
      loading = false;
    });
  }

  // 🔥 Month Wise Filter
  void filterTasksByMonth() {
    filteredTasks = tasks.where((task) {
      if (task['dueDate'] == null) return false;

      final due =
      DateTime.parse(task['dueDate']).toLocal();

      return due.year == selectedMonth.year &&
          due.month == selectedMonth.month;
    }).toList();

    setState(() {});
  }

  // 🔥 Month Picker (Simple)
  void _openMonthPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: "Select Month",
    );

    if (picked != null) {
      selectedMonth =
          DateTime(picked.year, picked.month);
      filterTasksByMonth();
    }
  }

  Future pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  void addTask() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Select Due Date & Time")),
      );
      return;
    }

    final combinedDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    await ApiService.createTask({
      "title": titleController.text,
      "description": descController.text,
      "assignedTo": widget.employeeId,
      "priority": "Medium",
      "dueDate": combinedDate.toIso8601String(),
    });

    Navigator.pop(context);

    titleController.clear();
    descController.clear();
    selectedDate = null;
    selectedTime = null;

    loadTasks();
  }
  void updateStatus(String id, String status) async {
    await ApiService.updateTaskStatus(id, status);
    loadTasks();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "In Progress":
        return Colors.orange;
      case "Overdue":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.employeeName,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat("MMMM yyyy")
                  .format(selectedMonth),
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14),
            ),
          ],
        ),
        iconTheme:
        const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _openMonthPicker,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A237E),
        onPressed: _showAddDialog,
        child: const Icon(Icons.add,
            color: Colors.white),
      ),

      body: loading
          ? const Center(
          child: CircularProgressIndicator())
          : filteredTasks.isEmpty
          ? const Center(
        child: Text(
          "No tasks for selected month",
          style: TextStyle(
              fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        padding:
        const EdgeInsets.all(15),
        itemCount:
        filteredTasks.length,
        itemBuilder:
            (context, index) {

          final task =
          filteredTasks[index];

          return Container(
            margin:
            const EdgeInsets.only(
                bottom: 15),
            padding:
            const EdgeInsets.all(15),
            decoration:
            BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(
                  20),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [

                Text(
                  task['title'],
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  task['description'],
                  style: TextStyle(
                      color: Colors
                          .grey.shade600),
                ),

                if (task['createdAt'] != null)
                  Text(
                    "Assigned: ${DateFormat("dd MMM yyyy • hh:mm a").format(
                      DateTime.parse(task['createdAt']).toLocal(),
                    )}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                const SizedBox(height: 4),

                if (task['dueDate'] != null)
                  Text(
                    "Due: ${formatDueDate(task['dueDate'])}",
                    style: TextStyle(
                      color: getStatusColor(task['status']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
                  children: [

                    DropdownButton<String>(
                      value:
                      task['status'],
                      items: [
                        "Pending",
                        "In Progress",
                        "Completed",
                        "Overdue"
                      ]
                          .map((status) =>
                          DropdownMenuItem(
                            value:
                            status,
                            child:
                            Text(
                                status),
                          ))
                          .toList(),
                      onChanged:
                          (value) {
                        if (value !=
                            null) {
                          updateStatus(
                              task['_id'],
                              value);
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          )
              .animate()
              .fade(
              duration: 400.ms)
              .slideY(begin: 0.2);
        },
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(20),
        ),
        title: const Text("Add Task"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [

              TextField(
                controller:
                titleController,
                decoration:
                const InputDecoration(
                    labelText:
                    "Title"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller:
                descController,
                decoration:
                const InputDecoration(
                    labelText:
                    "Description"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: pickDate,
                child: Text(selectedDate ==
                    null
                    ? "Select Due Date"
                    : DateFormat(
                    "dd MMM yyyy")
                    .format(
                    selectedDate!)),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: pickTime,
                child: Text(selectedTime ==
                    null
                    ? "Select Time"
                    : selectedTime!
                    .format(context)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child:
            const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: addTask,
            child:
            const Text("Add"),
          ),
        ],
      ),
    );
  }
}