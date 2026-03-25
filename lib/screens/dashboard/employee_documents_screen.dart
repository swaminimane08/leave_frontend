import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';

class EmployeeDocumentsScreen extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const EmployeeDocumentsScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  State<EmployeeDocumentsScreen> createState() =>
      _EmployeeDocumentsScreenState();
}

class _EmployeeDocumentsScreenState
    extends State<EmployeeDocumentsScreen> {

  List documents = [];
  bool loading = true;

  final String baseUrl =
  ApiService.baseUrl.replaceAll("/api", "");

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {
      final data = await ApiService
          .getEmployeeDocuments(widget.employeeId);

      setState(() {
        documents = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> uploadFile() async {
    FilePickerResult? result =
    await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:
      ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() => loading = true);

      await ApiService.uploadEmployeeDocument(
        employeeId: widget.employeeId,
        title: result.files.single.name,
        filePath: result.files.single.path!,
      );

      fetchDocuments();
    }
  }

  Future<void> deleteDocument(String id) async {
    await ApiService.deleteEmployeeDocument(id);
    fetchDocuments();
  }

  Future<void> openDocument(String filePath) async {
    final Uri url =
    Uri.parse("$baseUrl$filePath");

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F5),

      /// 🔵 DARK BLUE APPBAR WITH WHITE ICONS
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A78),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // 🔥 Back Arrow White
        ),
        title: Text(
          "${widget.employeeName} Documents",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // 🔥 Title White
          ),
        ),
      ),

      /// ➕ WHITE ICON FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E2A78),
        onPressed: uploadFile,
        child: const Icon(
          Icons.add,
          color: Colors.white, // 🔥 PLUS ICON WHITE
        ),
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1E2A78),
        ),
      )
          : documents.isEmpty
          ? const Center(
        child: Text(
          "No Documents Found",
          style: TextStyle(
            fontSize: 16,
            fontWeight:
            FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      )
          : ListView.builder(
        padding:
        const EdgeInsets.all(16),
        itemCount: documents.length,
        itemBuilder:
            (context, index) {

          final doc =
          documents[index];

          final isPdf =
          doc["fileType"]
              .toString()
              .contains("pdf");

          return Container(
            margin:
            const EdgeInsets.only(
                bottom: 16),
            decoration:
            BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius
                  .circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors
                      .grey.shade300,
                  blurRadius: 8,
                  offset:
                  const Offset(
                      0, 4),
                ),
              ],
            ),
            child: ListTile(
              onTap: () =>
                  openDocument(
                      doc["filePath"]),

              contentPadding:
              const EdgeInsets
                  .all(16),

              leading: CircleAvatar(
                radius: 26,
                backgroundColor:
                isPdf
                    ? Colors
                    .red
                    .shade100
                    : Colors
                    .blue
                    .shade100,
                child: isPdf
                    ? const Icon(
                  Icons
                      .picture_as_pdf,
                  color:
                  Colors
                      .red,
                )
                    : const Icon(
                  Icons.image,
                  color:
                  Colors
                      .blue,
                ),
              ),

              title: Text(
                doc["title"],
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight
                      .bold,
                ),
              ),

              subtitle: Text(
                doc["createdAt"]
                    .toString()
                    .substring(
                    0, 10),
              ),

              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color:
                  Colors.red,
                ),
                onPressed: () =>
                    deleteDocument(
                        doc["_id"]),
              ),
            ),
          )
              .animate()
              .fade(
              duration:
              400.ms)
              .slideY(
              begin: 0.2);
        },
      ),
    );
  }
}