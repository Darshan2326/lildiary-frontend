import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lildairy/services/storage_service.dart';

import '../api/auth_api.dart';

class AuthController extends GetxController {
  final AuthApi _authApi = AuthApi();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final isLoggedIn = false.obs;
  final token = RxnString();

  @override
  void onInit() {
    super.onInit();

    loadUserData();
  }

  Future<void> loginAPI({
    required String identifier,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authApi.login(
        identifier: identifier,
        password: password,
      );

      await login(result.accessToken);

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

  void loadUserData() {
    isLoggedIn.value = StorageService.isLoggedIn();
    token.value = StorageService.getToken();
  }

  Future<void> login(String newToken) async {
    await StorageService.setToken(newToken);
    await StorageService.setLoggedIn(true);

    token.value = newToken;
    isLoggedIn.value = true;
  }

  Future<void> logout() async {
    await StorageService.clear();

    token.value = null;
    isLoggedIn.value = false;
  }

  Future<void> logoutAPI() async {
    final currentToken = token.value;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (currentToken != null && currentToken.isNotEmpty) {
        await _authApi.logout(token: currentToken);
      }

      await logout();
      Get.snackbar('Success', 'Logout successful');
    } catch (error, stackTrace) {
      debugPrint('[AUTH ERROR] Logout failed: $error');
      debugPrint('[AUTH ERROR] Stack trace: $stackTrace');
      errorMessage.value = error.toString();

      Get.snackbar('Logout Failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
