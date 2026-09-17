import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/signup_controller.dart';
import 'package:lildairy/widget/button.dart';
import '../widget/text_field.dart';
import 'login.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  // GetX Signup Controller
  final SignupController controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Obx(
              () => AnimatedOpacity(
                duration: const Duration(seconds: 1),
                curve: Curves.easeIn,
                opacity: controller.opacity.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    SizedBox(
                      height: height / 7,
                      child: Image.asset(
                        'assets/logos/Logo_trans.png',
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Register Title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Subtitle
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Text(
                          "To continue please register your account",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    // Name
                    TextFieldInput(
                      icon: Icons.person,
                      textEditingController: controller.nameController,
                      hintText: 'Enter your name',
                      textInputType: TextInputType.text,
                    ),

                    // Username
                    TextFieldInput(
                      icon: Icons.person,
                      textEditingController: controller.usernameController,
                      hintText: 'Enter your username',
                      textInputType: TextInputType.text,
                    ),

                    // Email
                    TextFieldInput(
                      icon: Icons.email,
                      textEditingController: controller.emailController,
                      hintText: 'Enter your email',
                      textInputType: TextInputType.emailAddress,
                    ),

                    // Password
                    TextFieldInput(
                      icon: Icons.lock,
                      textEditingController: controller.passwordController,
                      hintText: 'Enter your password',
                      textInputType: TextInputType.visiblePassword,
                      isPass: true,
                    ),

                    // Confirm Password
                    TextFieldInput(
                      icon: Icons.lock,
                      textEditingController:
                          controller.confirmpasswordController,
                      hintText: 'Enter your confirm password',
                      textInputType: TextInputType.visiblePassword,
                      isPass: true,
                    ),

                    const SizedBox(height: 50),

                    // Signup Button
                    Obx(
                      () => IgnorePointer(
                        ignoring: controller.isLoading.value,
                        child: MyButtons(
                          onTap: controller.signupUser,
                          text: controller.isLoading.value
                              ? "Signing Up..."
                              : "Sign Up",
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.off(() => LoginScreen());
                          },
                          child: const Text(
                            " Log in",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
