import 'package:flutter/material.dart';
import 'package:lildairy/screens/HomeScreen.dart';
import 'package:lildairy/screens/forgot_password.dart';
import 'package:lildairy/widget/button.dart';
import 'package:lildairy/widget/snackbar.dart';
import 'package:lildairy/widget/text_field.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void loginUser() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const NotesHomeScreen()),
    );
  }

  // void loginUser() {
  //   Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (context) => const NotesHomeScreen()));
  // }

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
                    SizedBox(
                      height: height / 7,
                      child: Image.asset('assets/logos/Logo_trans.png'),
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      "Welcome Back!",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Let's login into your account to get started",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38),
                    ),
                    TextFieldInput(
                        icon: Icons.person,
                        textEditingController: emailController,
                        hintText: 'Enter your email',
                        textInputType: TextInputType.text),
                    TextFieldInput(
                      icon: Icons.lock,
                      textEditingController: passwordController,
                      hintText: 'Enter your password',
                      textInputType: TextInputType.text,
                      isPass: true,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4FC3F7),
                            fontSize: 15),
                      ),
                    ),
                    MyButtons(onTap: loginUser, text: "Log In"),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
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
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
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
