import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../services/api_service.dart';
import '../dashboard/admin_dashboard.dart';
import '../dashboard/employee_dashboard.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  // 🔥 DEVICE ID FUNCTION ADDED
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;

      // ✅ STABLE FIELD
      return androidInfo.id ?? androidInfo.fingerprint ?? "";
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "";
    }

    return "";
  }
  void loginUser() async {

    setState(() => loading = true);

    // 🔥 GET DEVICE ID
    String deviceId = await getDeviceId();

    final response = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
      deviceId, // 🔥 SEND DEVICE ID
    );

    setState(() => loading = false);

    if (response['token'] != null) {

      SharedPreferences prefs =
      await SharedPreferences.getInstance();

      await prefs.setString("token", response['token']);
      await prefs.setString("role", response['role']);
      await prefs.setString("name", response['name'] ?? "");

      if (response['role'] == "ADMIN") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const EmployeeDashboard()),
        );
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(response['message'] ?? "Login Failed"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE3F2FD),
                  Color(0xFFBBDEFB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Positioned(
            right: -70,
            top: 120,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            left: -90,
            top: 200,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.only(
                  left: 25,
                  right: 25,
                  bottom: bottomInset > 0 ? 20 : 0,
                ),
                child: ConstrainedBox(
                  constraints:
                  const BoxConstraints(maxWidth: 420),
                  child: buildGlassCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.08),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.business_rounded,
                  size: 36,
                  color: Colors.blue.shade700,
                ),
              ).animate().fade().scale(),

              const SizedBox(height: 20),

              Text(
                "MJIT Solutions",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ).animate().fade().slideY(begin: -0.2),

              const SizedBox(height: 30),

              buildTextField(
                controller: emailController,
                hint: "Email",
                icon: Icons.email_outlined,
                obscure: false,
              ),

              const SizedBox(height: 16),

              buildTextField(
                controller: passwordController,
                hint: "Password",
                icon: Icons.lock_outline,
                obscure: true,
              ),

              const SizedBox(height: 25),

              loading
                  ? CircularProgressIndicator(
                color: Colors.blue.shade700,
              )
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.blue.shade700,
                    elevation: 6,
                    shadowColor:
                    Colors.blue.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    padding:
                    const EdgeInsets.symmetric(
                        vertical: 15),
                  ),
                  onPressed: loginUser,
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ).animate().fade().slideY(begin: 0.3),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                        const SignupScreen()),
                  );
                },
                child: Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.blue.shade700,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                        const ForgotPasswordScreen()),
                  );
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          size: 20,
          color: Colors.blue.shade700,
        ),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.blue.shade100,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.blue.shade600,
            width: 1.5,
          ),
        ),
      ),
    ).animate().fade().slideX(begin: -0.2);
  }
}