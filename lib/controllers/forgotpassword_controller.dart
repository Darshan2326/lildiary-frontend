import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  Future<void> resetPassword() async {
    isLoading = true;
    update();

    // TODO: Call Forgot Password API here

    // Example:
    // await AuthApi.forgotPassword(
    //   email: emailController.text.trim(),
    // );

    isLoading = false;
    update();

    Get.snackbar(
      'Success',
      'Password reset is ready for API integration.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}