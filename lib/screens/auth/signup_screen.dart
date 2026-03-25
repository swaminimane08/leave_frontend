import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  String role = "EMPLOYEE";
  String department = "IT";
  bool loading = false;

  final List<String> roles = ["ADMIN", "EMPLOYEE"];

  final List<String> departments = [
    "IT",
    "HR",
    "SALES",
    "ACCOUNTING",
    "GRAPHIC DESIGNING"
  ];

  void registerUser() async {

    if (name.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields required")),
      );
      return;
    }

    setState(() => loading = true);

    final response = await ApiService.register({
      "name": name.text,
      "email": email.text,
      "password": password.text,
      "role": role,
      "department": department,
    });

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'])),
    );

    if (response['message'] == "Registered Successfully") {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [

          /// 🔵 Soft Corporate Background
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

          /// Decorative Blur Circles
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

          /// 🔙 Animated Glass Back Arrow
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ),
            ).animate().fade(duration: 400.ms).slideX(begin: -0.4),
          ),

          /// 🔥 Glass Signup Card
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
                  constraints: const BoxConstraints(maxWidth: 420),
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

              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ).animate().fade().slideY(begin: -0.2),

              const SizedBox(height: 25),

              buildTextField(name, "Name", Icons.person),
              const SizedBox(height: 16),

              buildTextField(email, "Email", Icons.email_outlined),
              const SizedBox(height: 16),

              buildTextField(password, "Password", Icons.lock_outline,
                  isPassword: true),
              const SizedBox(height: 16),

              buildDropdown(
                value: role,
                items: roles,
                label: "Select Role",
                onChanged: (val) => setState(() => role = val!),
              ),

              const SizedBox(height: 16),

              buildDropdown(
                value: department,
                items: departments,
                label: "Select Department",
                onChanged: (val) => setState(() => department = val!),
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
                    backgroundColor: Colors.blue.shade700,
                    elevation: 6,
                    shadowColor:
                    Colors.blue.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15),
                  ),
                  onPressed: registerUser,
                  child: const Text(
                    "REGISTER",
                    style: TextStyle(
                      color: Colors.white, // WHITE as you asked
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ).animate().fade().slideY(begin: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon, {
        bool isPassword = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
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

  Widget buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
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
      ),
      style: const TextStyle(color: Colors.black87),
      iconEnabledColor: Colors.blue.shade700,
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      ))
          .toList(),
      onChanged: onChanged,
    ).animate().fade().slideX(begin: 0.2);
  }
}