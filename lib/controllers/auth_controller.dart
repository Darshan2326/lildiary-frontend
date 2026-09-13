import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../api/auth_api.dart';

class AuthController extends GetxController {
  final AuthApi _authApi = AuthApi();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('[AUTH] Starting login for identifier: $identifier');

      final result = await _authApi.login(
        identifier: identifier,
        password: password,
      );

      debugPrint('[AUTH] Login successful');
      debugPrint('[AUTH] Token type: ${result.tokenType}');
      debugPrint(
          '[AUTH] Access token received: ${result.accessToken.isNotEmpty}');

      // Login successful
      // Save token here later
      // Navigate to home here later

      Get.snackbar(
        'Success',
        'Login successful',
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
}
