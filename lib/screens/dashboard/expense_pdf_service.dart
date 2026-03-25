import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ExpensePdfService {

  // ================= MAIN FUNCTION =================
  static Future<void> generateProfessionalInvoice({
    required List expenses,
  }) async {

    final pdf = pw.Document();

    // ===== LOAD IMAGES =====
    pw.MemoryImage? logo;
    pw.MemoryImage? signature;

    try {
      final logoBytes = await rootBundle.load("assets/logo.png");
      logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {}

    try {
      final signBytes = await rootBundle.load("assets/signature.png");
      signature = pw.MemoryImage(signBytes.buffer.asUint8List());
    } catch (e) {}

    // ===== TOTAL =====
    double total = expenses.fold(
      0.0,
          (sum, e) =>
      sum + (double.tryParse(e['amount'].toString()) ?? 0),
    );

    final date = DateFormat("dd MMM yyyy").format(DateTime.now());

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(25),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              // ===== HEADER =====
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (logo != null)
                    pw.Image(logo, width: 70),

                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("MJT Solution",
                          style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold)),
                      pw.Text("Professional Invoice"),
                      pw.Text("Date: $date"),
                    ],
                  )
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),

              // ===== CUSTOMER INFO =====
              pw.Text("Bill To:",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold)),
              pw.Text("Company Expense Department"),

              pw.SizedBox(height: 20),

              // ===== TABLE =====
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(2),
                },
                children: [

                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300),
                    children: [
                      _cell("Description", bold: true),
                      _cell("Amount", bold: true),
                    ],
                  ),

                  ...expenses.map((e) {
                    double amt =
                        double.tryParse(e['amount'].toString()) ?? 0;

                    return pw.TableRow(
                      children: [
                        _cell(e['title'] ?? ""),
                        _cell("Rs $amt"),
                      ],
                    );
                  }),

                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200),
                    children: [
                      _cell("TOTAL", bold: true),
                      _cell("Rs ${total.toStringAsFixed(0)}",
                          bold: true),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // ===== QR CODE =====
              pw.Row(
                mainAxisAlignment:
                pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Scan for details"),
                      pw.SizedBox(height: 10),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data:
                        "Invoice Total: Rs ${total.toStringAsFixed(0)}",
                        width: 80,
                        height: 80,
                      ),
                    ],
                  ),

                  // ===== SIGNATURE =====
                  pw.Column(
                    children: [
                      if (signature != null)
                        pw.Image(signature, width: 80),
                      pw.Text("Authorized Signature"),
                    ],
                  )
                ],
              ),

              pw.Spacer(),

              // ===== FOOTER =====
              pw.Center(
                child: pw.Text(
                  "Thank you for your business!",
                  style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic),
                ),
              )
            ],
          );
        },
      ),
    );

    await _saveAndShare(pdf);
  }

  // ================= COMMON CELL =================
  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight:
          bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // ================= SAVE + SHARE =================
  static Future<void> _saveAndShare(pw.Document pdf) async {
    final dir = await getApplicationDocumentsDirectory();

    final file = File(
        "${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: file.path.split('/').last,
    );
  }
}