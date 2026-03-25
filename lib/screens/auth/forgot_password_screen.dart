import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final emailController = TextEditingController();
  bool loading = false;

  void sendOtp() async {

    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter email")),
      );
      return;
    }

    setState(() => loading = true);

    final response =
    await ApiService.sendOtp(emailController.text.trim());

    setState(() => loading = false);

    if (response['message'] ==
        "OTP sent to email successfully") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OTPScreen(email: emailController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
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

          /// 🔵 Corporate Background
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

          /// Blur Circles
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

          /// 🔙 Glass Back Arrow
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter:
                  ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius:
                      BorderRadius.circular(16),
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
            ).animate().fade().slideX(begin: -0.4),
          ),

          /// 🔥 CARD (SHIFTED UP)
          SafeArea(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(
                left: 25,
                right: 25,
                top: 80, // 🔥 SHIFT CARD UP
                bottom: bottomInset > 0 ? 20 : 0,
              ),
              child: Align(
                alignment: Alignment.topCenter,
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
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset,
                  size: 34,
                  color: Colors.blue.shade700,
                ),
              ).animate().fade().scale(),

              const SizedBox(height: 20),

              Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Enter your registered email to receive OTP",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 25),

              TextField(
                controller: emailController,
                style:
                const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.blue.shade700,
                  ),
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.blue.shade100,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.blue.shade600,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

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
                  onPressed: sendOtp,
                  child: const Text(
                    "SEND OTP",
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
            ],
          ),
        ),
      ),
    );
  }
}