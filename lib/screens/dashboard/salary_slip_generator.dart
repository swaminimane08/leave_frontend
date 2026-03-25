import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SalarySlipGenerator {

  static Future<void> generatePayslip({
    required Map<String, dynamic> salaryData,
  }) async {

    final pdf = pw.Document();

    final logoBytes = await rootBundle.load("assets/logo.png");
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final employee = salaryData["employeeId"] ?? {};

    // ✅ ADDED PERIOD
    final periodFrom = salaryData["periodFrom"] ?? "-";
    final periodTo = salaryData["periodTo"] ?? "-";

    final basic = (salaryData["basicSalary"] ?? 0).toDouble();
    final hra = (salaryData["hra"] ?? 0).toDouble();
    final conveyance = (salaryData["conveyance"] ?? 0).toDouble();
    final special = (salaryData["specialAllowance"] ?? 0).toDouble();

    final pf = (salaryData["providentFund"] ?? 0).toDouble();
    final esi = (salaryData["esi"] ?? 0).toDouble();
    final loan = (salaryData["loan"] ?? 0).toDouble();
    final pt = (salaryData["professionTax"] ?? 0).toDouble();
    final tds = (salaryData["tds"] ?? 0).toDouble();
    final late = (salaryData["lateDeduction"] ?? 0).toDouble();
    final absent = (salaryData["absentDeduction"] ?? 0).toDouble();

    final totalEarnings = (salaryData["totalEarnings"] ?? 0).toDouble();
    final totalDeduction = (salaryData["totalDeduction"] ?? 0).toDouble();
    final netSalary = (salaryData["netSalary"] ?? 0).toDouble();
    final totalWorkingHours = (salaryData["totalWorkingHours"] ?? 0).toDouble();
    final perHourSalary = (salaryData["perHourSalary"] ?? 0).toDouble();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              /// HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("MJIT SOLUTIONS",
                          style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text("Monthly Payslip",
                          style: pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                  pw.Image(logoImage, height: 60),
                ],
              ),
              pw.SizedBox(height: 25),
              /// EMPLOYEE DETAILS
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1.2),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    detailRow("Employee Name", employee["name"] ?? "-"),
                    detailRow("Designation", employee["designation"] ?? "-"),
                    detailRow("Month", salaryData["month"] ?? "-"),

                    // ✅ SALARY PERIOD ADDED
                    detailRow("Salary Period", "$periodFrom to $periodTo"),
                    detailRow("Salary Period", "$periodFrom to $periodTo"),
                    detailRow("Total Working Hours", totalWorkingHours.toString()),
                    detailRow("Per Hour Salary", "Rs. ${perHourSalary.toStringAsFixed(2)}"),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              /// SALARY TABLE
              pw.Table(
                border: pw.TableBorder.all(width: 0.8),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(3),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [

                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300),
                    children: [
                      tableCell("Earnings", true),
                      tableCell("Amount", true),
                      tableCell("Deductions", true),
                      tableCell("Amount", true),
                    ],
                  ),

                  tableRow("Basic Salary", basic, "Provident Fund", pf),
                  tableRow("HRA", hra, "ESI", esi),
                  tableRow("Conveyance", conveyance, "Loan", loan),
                  tableRow("Special Allowance", special, "Professional Tax", pt),
                  tableRow("", 0, "TDS", tds),
                  tableRow("", 0, "Late Deduction", late),
                  tableRow("", 0, "Absent Deduction", absent),

                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200),
                    children: [
                      tableCell("Total Earnings", true),
                      tableCell("Rs. ${totalEarnings.toStringAsFixed(2)}", true),
                      tableCell("Total Deduction", true),
                      tableCell("Rs. ${totalDeduction.toStringAsFixed(2)}", true),
                    ],
                  ),

                  pw.TableRow(children: [
                    tableCell("", false),
                    tableCell("", false),
                    tableCell("Net Salary", true),
                    tableCell("Rs. ${netSalary.toStringAsFixed(2)}", true),
                  ]),
                ],
              ),

              pw.SizedBox(height: 30),

              pw.Text(
                "Rupees ${numberToWords(netSalary.toInt())} Only",
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 50),

              pw.Row(
                mainAxisAlignment:
                pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text("Employee Signature"),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text("Authorized Signature"),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
  static pw.TableRow tableRow(
      String eTitle,
      double eValue,
      String dTitle,
      double dValue) {
    return pw.TableRow(
      children: [
        tableCell(eTitle, false),
        tableCell(eValue > 0 ? "Rs. ${eValue.toStringAsFixed(2)}" : "", false),
        tableCell(dTitle, false),
        tableCell(dValue > 0 ? "Rs. ${dValue.toStringAsFixed(2)}" : "", false),
      ],
    );
  }

  static pw.Widget tableCell(String text, bool bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight:
          bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
  static pw.Widget detailRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text("$title : ",
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }
  static String numberToWords(int number) {
    if (number == 0) return "Zero";
    return number.toString();
  }
}