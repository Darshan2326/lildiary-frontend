import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/forgotpassword_controller.dart';



class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordController>(
      init: ForgotPasswordController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),

          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [

                  // =========================
                  // LOGO
                  // =========================

                  Center(
                    child: Image.asset(
                      'assets/logos/Logo_trans.png',
                      height: 100,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // TITLE
                  // =========================

                  const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // =========================
                  // DESCRIPTION
                  // =========================

                  const Text(
                    'Please enter the email address you’d like your password reset information sent to.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========================
                  // EMAIL
                  // =========================

                  TextField(
                    controller: controller.emailController,

                    keyboardType: TextInputType.emailAddress,

                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFFF48FB1),
                      ),

                      hintText: 'Email Address',

                      hintStyle: const TextStyle(
                        color: Colors.black38,
                      ),

                      filled: true,

                      fillColor: Colors.grey[100],

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // RESET BUTTON
                  // =========================

                  controller.isLoading
                      ? const CircularProgressIndicator()

                      : ElevatedButton(
                          onPressed: controller.resetPassword,

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF4FC3F7),

                            padding: const EdgeInsets.only(
                              right: 80,
                              left: 80,
                              top: 12,
                              bottom: 12,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),

                          child: const Text(
                            'Send Reset Code',

                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                  const SizedBox(height: 20),

                  // =========================
                  // BACK TO LOGIN
                  // =========================

                  GestureDetector(
                    onTap: controller.goBack,

                    child: const Text(
                      'Back to Log In',

                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}