import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/api/auth_api.dart';

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
      errorMessage.value = "";

      final result = await _authApi.RegisterAPI(
        name: name,
        username: username,
        email: email,
        password: password,
        confirm_password: confirm_password,
      );
      Get.snackbar(
        'Success',
        'Rregister successful',
      );
    } catch (error, stackTrace) {
      debugPrint('[AUTH ERROR] Login failed: $error');
      debugPrint('[AUTH ERROR] Stack trace: $stackTrace');
      errorMessage.value = error.toString();

      Get.snackbar(
        'Login Failed',
        error.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void signupUser() async {
    await RegisterAPI(
        name: nameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        confirm_password: confirmpasswordController.text.trim());
  }
}
