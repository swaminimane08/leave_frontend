import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'expense_pdf_service.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {

  List expenses = [];
  List selectedExpenses = [];
  bool loading = true;

  int totalExpenses = 0;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  void loadExpenses() async {
    final data = await ApiService.getCompanyExpenses();

    expenses = data;
    totalExpenses = expenses.length;

    // ✅ FIXED amount issue
    totalAmount = expenses.fold(
      0.0,
          (sum, item) =>
      sum + (double.tryParse(item['amount'].toString()) ?? 0),
    );

    setState(() {
      loading = false;
    });
  }

  double getSelectedTotal() {
    return selectedExpenses.fold(
      0.0,
          (sum, item) =>
      sum + (double.tryParse(item['amount'].toString()) ?? 0),
    );
  }

  String formatDate(String date) {
    final d = DateTime.parse(date).toLocal();
    return DateFormat("dd MMM yyyy").format(d);
  }

  void deleteExpense(String id) async {
    await ApiService.deleteCompanyExpense(id);
    loadExpenses();
  }

  // ================= ADD =================
  void showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text("Add Expense"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount")),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Category")),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await ApiService.addCompanyExpense({
                "title": titleController.text,
                "amount": double.parse(amountController.text),
                "category": categoryController.text,
                "description": descriptionController.text,
              });

              Navigator.pop(context);
              loadExpenses();
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // ================= EDIT =================
  void showEditExpenseDialog(Map expense) {
    final titleController = TextEditingController(text: expense['title']);
    final amountController = TextEditingController(text: expense['amount'].toString());
    final categoryController = TextEditingController(text: expense['category']);
    final descriptionController = TextEditingController(text: expense['description']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Expense"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount")),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Category")),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateCompanyExpense(
                expense['_id'],
                {
                  "title": titleController.text,
                  "amount": double.parse(amountController.text),
                  "category": categoryController.text,
                  "description": descriptionController.text,
                },
              );

              Navigator.pop(context);
              loadExpenses();
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [

            /// SUMMARY
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1A237E),
                    Color(0xFF3949AB),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statBox("Total", totalExpenses.toString()),
                  _statBox("Amount", "Rs${totalAmount.toStringAsFixed(0)}"),
                ],
              ),
            ).animate().fade().slideY(begin: 0.2),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: expenses.length,
                itemBuilder: (context, index) {

                  final expense = expenses[index];

                  // ✅ FIXED selection
                  final isSelected = selectedExpenses
                      .any((e) => e['_id'] == expense['_id']);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedExpenses.add(expense);
                                  } else {
                                    selectedExpenses.removeWhere(
                                            (e) => e['_id'] == expense['_id']);
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                expense['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Text("Rs${expense['amount']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo)),

                        Text(expense['category'],
                            style: TextStyle(color: Colors.grey.shade600)),

                        Text(formatDate(expense['date']),
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => showEditExpenseDialog(expense),
                            ),

                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  await ExpensePdfService.generateProfessionalInvoice(
                                    expenses: [expense], // single साठी list मध्ये टाक
                                  );
                                } catch (e) {
                                  print("PDF ERROR: $e");
                                }
                              },
                              icon: const Icon(Icons.picture_as_pdf,
                                  color: Colors.white, size: 18),
                              label: const Text("PDF",
                                  style: TextStyle(color: Colors.white)),
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteExpense(expense['_id']),
                            ),
                          ],
                        )
                      ],
                    ),
                  ).animate().fade(duration: 400.ms).slideY(begin: 0.2);
                },
              ),
            ),

            if (selectedExpenses.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(15),
                color: Colors.white,
                child: Column(
                  children: [
                    Text(
                      "Selected Total: ₹${getSelectedTotal().toStringAsFixed(0)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: () async {
                        try {
                          await ExpensePdfService.generateProfessionalInvoice(
                            expenses: selectedExpenses,
                          );
                        } catch (e) {
                          print("PDF ERROR: $e");
                        }
                      },
                      child: const Text("Generate Combined Bill",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _statBox(String title, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}