import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/api/auth_api.dart';
import 'package:lildairy/controllers/login_controller.dart';
import 'package:lildairy/screens/HomeScreen.dart';

class SignupController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final opacity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        opacity.value = 1.0;
      },
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.onClose();
  }

  Future<void> RegisterAPI({
    required String name,
    required String username,
    required String email,
    required String password,
    required String confirm_password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1. Register the user
      await _authApi.RegisterAPI(
        name: name,
        username: username,
        email: email,
        password: password,
        confirm_password: confirm_password,
      );

      // 2. Automatically log in the user
      final AuthController authController = Get.find<AuthController>();

      final loginResponse = await _authApi.login(
        identifier: username,
        password: password,
      );

      await authController.login(loginResponse.accessToken);
      await authController.fetchCurrentUser();

      // 3. Redirect to Home Screen
      Get.offAll(() => NotesHomeScreen());

      Get.snackbar(
        'Welcome!',
        'Account created successfully. Welcome to LilDairy!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (error, stackTrace) {
      debugPrint('[AUTH ERROR] Registration failed: $error');
      debugPrint('[AUTH ERROR] Stack trace: $stackTrace');

      final errorMsg = error.toString().replaceAll('Exception: ', '').trim();
      errorMessage.value = errorMsg;

      Get.snackbar(
        'Registration Failed',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void signupUser() async {
    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmpasswordController.text;

    if (name.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    if (username.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your username',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    if (username.length < 3) {
      Get.snackbar(
        'Invalid Username',
        'Username must be at least 3 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Weak Password',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Password Mismatch',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    await RegisterAPI(
      name: name,
      username: username,
      email: email,
      password: password,
      confirm_password: confirmPassword,
    );
  }
}
