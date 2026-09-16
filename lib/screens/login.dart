import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lildairy/screens/HomeScreen.dart';
import 'package:lildairy/screens/forgot_password.dart';
import 'package:lildairy/widget/button.dart';
import 'package:lildairy/widget/text_field.dart';

import '../controllers/auth_controller.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // --------------------------------------------------
  // Controllers
  // --------------------------------------------------

  final TextEditingController identifierController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // GetX Auth Controller
  final AuthController authController = Get.put(AuthController());

  // --------------------------------------------------
  // UI State
  // --------------------------------------------------

  double opacity = 0.0;

  // --------------------------------------------------
  // Init
  // --------------------------------------------------

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacity = 1.0;
      });
    });
  }

  // --------------------------------------------------
  // Dispose
  // --------------------------------------------------

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // Login
  // --------------------------------------------------

  Future<void> loginUser() async {
    await authController.loginAPI(
      identifier: identifierController.text.trim(),
      password: passwordController.text,
    );
  }

  // --------------------------------------------------
  // Build
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: AnimatedOpacity(
              duration: const Duration(seconds: 1),
              curve: Curves.easeIn,
              opacity: opacity,
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --------------------------------------------------
                    // Logo
                    // --------------------------------------------------

                    SizedBox(
                      height: height / 7,
                      child: Image.asset(
                        'assets/logos/Logo_trans.png',
                      ),
                    ),

                    const SizedBox(height: 50),

                    // --------------------------------------------------
                    // Welcome Text
                    // --------------------------------------------------

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

                    // --------------------------------------------------
                    // Identifier
                    // --------------------------------------------------

                    TextFieldInput(
                      icon: Icons.person,
                      textEditingController: identifierController,
                      hintText: 'Enter your email or username',
                      textInputType: TextInputType.text,
                    ),

                    // --------------------------------------------------
                    // Password
                    // --------------------------------------------------

                    TextFieldInput(
                      icon: Icons.lock,
                      textEditingController: passwordController,
                      hintText: 'Enter your password',
                      textInputType: TextInputType.text,
                      isPass: true,
                    ),

                    // --------------------------------------------------
                    // Forgot Password
                    // --------------------------------------------------

                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
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

                    // --------------------------------------------------
                    // Login Button
                    // --------------------------------------------------

                    Obx(
                      () => IgnorePointer(
                        ignoring: authController.isLoading.value,
                        child: MyButtons(
                          onTap: loginUser,
                          text: authController.isLoading.value
                              ? "Logging in..."
                              : "Log In",
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --------------------------------------------------
                    // Sign Up
                    // --------------------------------------------------

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
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
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
