import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mjit_solution/screens/dashboard/salary_history_page.dart';
import 'package:mjit_solution/screens/dashboard/salary_slip_generator.dart';
import '../../services/api_service.dart';

class SalaryScreen extends StatefulWidget {
  final String userId;
  final String name;

  const SalaryScreen({
    super.key,
    required this.userId,
    required this.name,
  });

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {

  Map<String, dynamic>? salaryData;

  final TextEditingController basicController = TextEditingController();
  final TextEditingController hraController = TextEditingController();
  final TextEditingController conveyanceController = TextEditingController();
  final TextEditingController specialController = TextEditingController();

  final TextEditingController pfController = TextEditingController();
  final TextEditingController esiController = TextEditingController();
  final TextEditingController loanController = TextEditingController();
  final TextEditingController ptController = TextEditingController();
  final TextEditingController tdsController = TextEditingController();

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  Future<void> generateSalary() async {

    if (basicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter Basic Salary")),
      );
      return;
    }

    final data = await ApiService.generateSalary(
      employeeId: widget.userId,
      month: "$selectedYear-${selectedMonth.toString().padLeft(2, '0')}",
      basicSalary: double.parse(basicController.text),
      hra: double.tryParse(hraController.text) ?? 0,
      conveyance: double.tryParse(conveyanceController.text) ?? 0,
      specialAllowance: double.tryParse(specialController.text) ?? 0,
      providentFund: double.tryParse(pfController.text) ?? 0,
      esi: double.tryParse(esiController.text) ?? 0,
      loan: double.tryParse(loanController.text) ?? 0,
      professionTax: double.tryParse(ptController.text) ?? 0,
      tds: double.tryParse(tdsController.text) ?? 0,
    );

    setState(() {
      salaryData = data;
    });
  }

  /// ✅ FIXED UPI (App chooser open)
  Future<void> openUPI() async {

    final upiId = "swaminimane08@oksbi"; // 🔥 तुझा UPI
    final name = widget.name;

    // ❗ IMPORTANT: amount 0 नसावा
    final amount =
    (salaryData?["netSalary"] ?? 1) == 0 ? 1 : salaryData!["netSalary"];

    final uri = Uri(
      scheme: "upi",
      host: "pay",
      queryParameters: {
        "pa": upiId,
        "pn": name,
        "am": amount.toString(),
        "cu": "INR",
        "tn": "Salary Payment"
      },
    );

    print("UPI URI: $uri");

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  /// ✅ FIXED WORKING HOURS
  String formatHours(dynamic minutes) {
    int total = int.tryParse(minutes.toString()) ?? 0;
    int hrs = total ~/ 60;
    int mins = total % 60;
    return "${hrs}h ${mins}m";
  }

  Future<void> markPaid(String mode) async {
    await ApiService.markSalaryPaid(salaryData!["_id"], mode);

    setState(() {
      salaryData!["status"] = "PAID";
      salaryData!["paymentMode"] = mode;
    });
  }

  @override
  Widget build(BuildContext context) {

    final isPaid =
        salaryData?["status"]?.toString().toUpperCase() == "PAID";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.name,
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SalaryHistoryPage(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            sectionTitle("Earnings"),

            buildCard([
              buildField("Basic Salary", basicController),
              buildField("HRA", hraController),
              buildField("Conveyance", conveyanceController),
              buildField("Special Allowance", specialController),
            ]),

            const SizedBox(height: 20),

            sectionTitle("Deductions"),

            buildCard([
              buildField("Provident Fund", pfController),
              buildField("ESI", esiController),
              buildField("Loan", loanController),
              buildField("Professional Tax", ptController),
              buildField("TDS", tdsController),
            ]),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: generateSalary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Generate Salary",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (salaryData != null)
              salaryCard(isPaid),
          ],
        ),
      ),
    );
  }

  Widget salaryCard(bool isPaid) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPaid
              ? [Colors.green.shade100, Colors.green.shade50]
              : [Colors.red.shade100, Colors.red.shade50],
        ),
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

          Text("Net Salary",
              style: TextStyle(color: Colors.grey.shade700)),

          const SizedBox(height: 5),

          Text("₹${salaryData!["netSalary"]}",
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),

          const Divider(height: 30),

          infoRow(
            "Salary Period",
            "${salaryData!["periodFrom"] ?? '-'} to ${salaryData!["periodTo"] ?? '-'}",
          ),

          infoRow("Total Earnings", "₹${salaryData!["totalEarnings"]}"),
          infoRow("Total Deduction", "₹${salaryData!["totalDeduction"]}"),

          infoRow("Working Days", salaryData!["workingDays"]),
          infoRow(
            "Total Working Hours",
            formatHours(salaryData!["totalWorkingHours"]), // ✅ FIX
          ),
          infoRow("Per Hour Salary", "₹${salaryData!["perHourSalary"]}"),
          infoRow("Absent Days", salaryData!["absentDays"]),

          const SizedBox(height: 15),

          Text(
            salaryData!["status"],
            style: TextStyle(
                color: isPaid ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),

          const SizedBox(height: 15),

          if (!isPaid)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => markPaid("CASH"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cash",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await openUPI(); // ✅ FIX
                      await markPaid("ONLINE");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Online",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),

          if (isPaid)
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf,
                  color: Colors.white),
              label: const Text("Download Payslip",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final fullData =
                await ApiService.getPayslip(salaryData!["_id"]);

                if (fullData == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to load payslip")),
                  );
                  return;
                }

                await SalarySlipGenerator.generatePayslip(
                  salaryData: fullData,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value.toString(),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}