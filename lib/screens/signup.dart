import 'package:flutter/material.dart';
import 'package:lildairy/screens/AppIntroductionScreen.dart';
import 'package:lildairy/widget/button.dart';
import '../widget/snackbar.dart';
import '../widget/text_field.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Trigger fade-in animation when the widget builds
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
    nameController.dispose();
  }

  void signupUser() async {
    // Basic input validation
    if (nameController.text.isEmpty) {
      showSnackBar(context, "Please enter your name.");
      return;
    }
    if (emailController.text.isEmpty) {
      showSnackBar(context, "Please enter your email.");
      return;
    }
    if (passwordController.text.isEmpty) {
      showSnackBar(context, "Please enter your password.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AppIntroductionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Text(
                            "Register",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Text(
                            "To continue please register your account",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ],
                    ),
                    TextFieldInput(
                      icon: Icons.person,
                      textEditingController: nameController,
                      hintText: 'Enter your name',
                      textInputType: TextInputType.text,
                    ),
                    TextFieldInput(
                      icon: Icons.email,
                      textEditingController: emailController,
                      hintText: 'Enter your email',
                      textInputType: TextInputType.emailAddress,
                    ),
                    TextFieldInput(
                      icon: Icons.lock,
                      textEditingController: passwordController,
                      hintText: 'Enter your password',
                      textInputType: TextInputType.visiblePassword,
                      isPass: true,
                    ),
                    const SizedBox(height: 50),
                    isLoading
                        ? const CircularProgressIndicator()
                        : MyButtons(onTap: signupUser, text: "Sign Up"),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            " Log in",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
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
