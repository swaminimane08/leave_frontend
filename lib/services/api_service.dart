import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = "http://192.168.0.110:6004/api";
  static const String serverUrl = "http://192.168.0.110:6004";
  static Future login(
      String email,
      String password,
      String deviceId,
      ) async {

    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "deviceId": deviceId,
      }),
    );
    print("STATUS CODE: ${res.statusCode}");

    return jsonDecode(res.body);
  }

  static Future register(data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    print("REGISTER STATUS: ${res.statusCode}");
    print("REGISTER BODY: ${res.body}");
    return jsonDecode(res.body);
  }
  static Future sendOtp(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/send-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return jsonDecode(res.body);
  }

  static Future resetPassword(data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }
  static Future getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/users"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(res.body);
  }
  static Future deleteUser(String id) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final res = await http.delete(
      Uri.parse("$baseUrl/users/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(res.body);
  }
  static Future applyLeave(data) async {
    final prefs =
    await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("$baseUrl/leave/apply"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }
  static Future getAllLeaves({String? date}) async {
    final prefs =
    await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    String url = "$baseUrl/leave/all";

    if (date != null) {
      url = "$url?date=$date";
    }

    final res = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token"
      },
    );

    return jsonDecode(res.body);
  }
  static Future<bool> deleteLeave(String leaveId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.delete(
        Uri.parse("$baseUrl/leave/$leaveId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Delete Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }
  static Future updateLeave(id, data) async {
    final prefs =
    await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.put(
      Uri.parse("$baseUrl/leave/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }
// ================= GET MY NOTIFICATIONS =================
  static Future getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/leave/notifications"),
      headers: {
        "Authorization": "Bearer $token"
      },
    );

    return jsonDecode(res.body);
  }
// ================================
  // 💰 GENERATE SALARY
  // ================================
  static Future<Map<String, dynamic>?> generateSalary({
    required String employeeId,
    required String month,
    required double basicSalary,
    double hra = 0,
    double conveyance = 0,
    double specialAllowance = 0,
    double providentFund = 0,
    double esi = 0,
    double loan = 0,
    double professionTax = 0,
    double tds = 0,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.post(
        Uri.parse("$baseUrl/salary/generate"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "employeeId": employeeId,
          "month": month,
          "basicSalary": basicSalary,
          "hra": hra,
          "conveyance": conveyance,
          "specialAllowance": specialAllowance,
          "providentFund": providentFund,
          "esi": esi,
          "loan": loan,
          "professionTax": professionTax,
          "tds": tds,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Generate Salary Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  // ================================
  // 📄 GET EMPLOYEE SALARY
  // ================================
  static Future<List<dynamic>> getEmployeeSalary(String employeeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.get(
        Uri.parse("$baseUrl/employee/$employeeId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Get Salary Error: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Exception: $e");
      return [];
    }
  }

// ================= MARK SALARY PAID =================
  // ================= MARK SALARY PAID =================
  // ================================
  // ✅ MARK SALARY PAID
  // ================================
  static Future<bool> markSalaryPaid(
      String salaryId, String paymentMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.patch(
        Uri.parse("$baseUrl/mark-paid/$salaryId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "paymentMode": paymentMode,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }
  // ================= SALARY HISTORY =================
  static Future getSalaryHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final res = await http.get(
      Uri.parse("$baseUrl/salary/employee/$userId"),
      headers: {
        "Authorization": "Bearer $token"
      },
    );
    return jsonDecode(res.body);
  }
  static Future getMyAttendance({
    required String token,
    required String month,
    required String year,
  }) async {

    final response = await http.get(
      Uri.parse("$baseUrl/attendance/my?month=$month&year=$year"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("MY ATTENDANCE STATUS: ${response.statusCode}");
    print("MY ATTENDANCE BODY: ${response.body}");

    return jsonDecode(response.body);
  }
  static Future<List<dynamic>> getMySalary({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/salary/my"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("MY SALARY STATUS: ${response.statusCode}");
    print("MY SALARY BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }
  static Future<void> markSalarySeen({
    required String salaryId,
    required String token,
  }) async {
    await http.put(
      Uri.parse("$baseUrl/salary/seen/$salaryId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }
  // ===============================
// GET SINGLE PAYSLIP
// ===============================
  // ================================
  // 🧾 GET PAYSLIP
  // ================================
  static Future<Map<String, dynamic>?> getPayslip(String salaryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.get(
        Uri.parse("$baseUrl/salary/payslip/$salaryId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Payslip Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
  // ================= GET PROFILE =================
  static Future<Map<String, dynamic>?> getProfile() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("$baseUrl/profile/me"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return null;
  }

  // ================= UPLOAD PHOTO =================
  static Future<String?> uploadProfileImage(
      File imageFile) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/profile/upload"));

    request.headers["Authorization"] =
    "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath(
        "image",
        imageFile.path,
      ),
    );

    var response = await request.send();
    var responseData =
    await response.stream.bytesToString();

    var decoded = jsonDecode(responseData);

    if (response.statusCode == 200) {
      return decoded["image"];
    }

    return null;
  }

  // ================= DELETE PHOTO =================
  static Future<bool> deleteProfilePhoto() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.delete(
      Uri.parse("$baseUrl/profile/delete-photo"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return res.statusCode == 200;
  }
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      throw Exception("No token found");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }
  // ===============================
// 📁 DOCUMENT APIs
// ===============================

  static Future<List<dynamic>> getEmployeeDocuments(String employeeId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/documents/$employeeId"),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load documents");
    }
  }

  static Future<void> deleteEmployeeDocument(String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/documents/$id"),
      headers: await _getHeaders(),
    );

    print("DELETE STATUS: ${response.statusCode}");
    print("DELETE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Delete failed");
    }
  }
  static Future<void> uploadEmployeeDocument({
    required String employeeId,
    required String title,
    required String filePath,
  }) async {

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/documents"),
    );

    final headers = await _getHeaders();
    request.headers.addAll(headers);

    request.fields["employeeId"] = employeeId;
    request.fields["title"] = title;

    request.files.add(
      await http.MultipartFile.fromPath("file", filePath),
    );

    final response = await request.send();

    print("STATUS CODE: ${response.statusCode}");

    final respStr = await response.stream.bytesToString();
    print("RESPONSE BODY: $respStr");

    if (response.statusCode != 201) {
      throw Exception("Upload failed");
    }
  }
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    return {
      "Authorization": "Bearer $token",
    };
  }
  static Future<Map<String, dynamic>> getTasksByEmployee(String id) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/tasks/employee/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load tasks");
    }
  }
  static Future<void> createTask(Map<String, dynamic> data) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/tasks/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Task creation failed");
    }
  }
  static Future<bool> deleteTask(String id) async {
    final token = await getToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/tasks/delete/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    return response.statusCode == 200;
  }
  static Future<void> updateTaskStatus(
      String id, String status) async {
    final token = await getToken();

    final response = await http.put(
      Uri.parse("$baseUrl/tasks/update-status/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"status": status}),
    );

    if (response.statusCode != 200) {
      throw Exception("Update failed");
    }
  }
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("Token not found. Please login again.");
    }

    return token;
  }
  static Future<Map<String, dynamic>> getTaskAnalytics() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/tasks/analytics"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load task analytics");
    }
  }
  static Future<List> getMyTasks() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/tasks/my"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 🔥 If backend returns { tasks: [] }
      if (data is Map && data.containsKey('tasks')) {
        return data['tasks'];
      }

      // 🔥 If backend returns direct list
      if (data is List) {
        return data;
      }

      return [];
    } else {
      throw Exception("Failed to load tasks");
    }
  }
  static Future<List> getEmployeeTaskSummary() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/tasks/employee-summary"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load summary");
    }
  }
  static Future<List> getMyTaskHistory() async {
    final response = await http.get(
      Uri.parse("$baseUrl/tasks/history"),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load history");
    }
  }
  static Future<Map<String, String>> _headers() async {
    final token = await getToken();

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }
  static Future<List> getCompanyExpenses() async {
    final res = await http.get(
      Uri.parse("$baseUrl/company-expense/all"),
    );
    return jsonDecode(res.body);
  }
  static Future<void> addCompanyExpense(
      Map<String, dynamic> data) async {
    await http.post(
      Uri.parse("$baseUrl/company-expense/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }
  static Future<void> deleteCompanyExpense(
      String id) async {
    await http.delete(
      Uri.parse("$baseUrl/company-expense/$id"),
    );
  }
  static Future<void> updateCompanyExpense(
      String id, Map<String, dynamic> data) async {
    await http.put(
      Uri.parse("$baseUrl/company-expense/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  // ---------------------Attendance-----------------------------//
  static Future checkIn({
    required String token,
    required double lat,
    required double lon,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/attendance/check-in"), // ✅ FIX
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "latitude": lat,
        "longitude": lon,
      }),
    );

    print("CHECKIN BODY: ${response.body}");

    return jsonDecode(response.body);
  }

  // ✅ CHECK-OUT
  static Future checkOut({required String token}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/attendance/check-out"), // ✅ FIX
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("CHECKOUT BODY: ${response.body}");

    return jsonDecode(response.body);
  }

  // ✅ MONTHLY
  static Future getMonthly({
    required String token,
    required String month,
    required String year,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/monthly?month=$month&year=$year"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }
  static Future<List> getAttendance({
    required String date,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/attendance/admin/date?date=$date"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );



    if (response.body.startsWith("<!DOCTYPE")) {
      print("Wrong API ❌");
      return [];
    }

    final decoded = jsonDecode(response.body);
    print("Total records: ${decoded.length}");
    print("Employee records: ${decoded.length}");
    if (decoded is List) {
      return decoded;
    } else {
      return [];
    }
  }
  static Future<List> getEmployeeAttendance(
      String userId,
      String month,
      String year,
      String token,
      ) async {
    final response = await http.get(
      Uri.parse(
          "$baseUrl/attendance/admin/employee?userId=$userId&month=$month&year=$year"
      ),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    // ❗ HTML error handle
    if (response.body.startsWith("<!DOCTYPE")) {
      print("Wrong API ❌");
      return [];
    }

    final decoded = jsonDecode(response.body);

    // ✅ CORRECT
    if (decoded is List) {
      return decoded;
    } else {
      return [];
    }
  }
  static Future<Map<String, dynamic>?> getTodayAttendance({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/attendance/today"), // ✅ FIX
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200 &&
        response.body.isNotEmpty) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
  //----------------------------------------------------------------------------//
}

