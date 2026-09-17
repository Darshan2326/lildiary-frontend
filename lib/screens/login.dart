import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/login_controller.dart';
import 'package:lildairy/screens/forgot_password.dart';
import 'package:lildairy/widget/button.dart';
import 'package:lildairy/widget/text_field.dart';
import 'signup.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Obx(
              () => AnimatedOpacity(
                duration: const Duration(seconds: 1),
                curve: Curves.easeIn,
                opacity: authController.opacity.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: height / 7,
                      child: Image.asset(
                        'assets/logos/Logo_trans.png',
                      ),
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Let's login into your account to get started",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                      ),
                    ),
                    TextFieldInput(
                      icon: Icons.person,
                      textEditingController:
                          authController.identifierController,
                      hintText: 'Enter your email or username',
                      textInputType: TextInputType.text,
                    ),
                    TextFieldInput(
                      icon: Icons.lock,
                      textEditingController: authController.passwordController,
                      hintText: 'Enter your password',
                      textInputType: TextInputType.text,
                      isPass: true,
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => ForgotPasswordScreen());
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4FC3F7),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Obx(
                      () => IgnorePointer(
                        ignoring: authController.isLoading.value,
                        child: MyButtons(
                          onTap: authController.loginUser,
                          text: authController.isLoading.value
                              ? "Logging in..."
                              : "Log In",
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => SignupScreen());
                            },
                            child: const Text(
                              "SignUp",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
