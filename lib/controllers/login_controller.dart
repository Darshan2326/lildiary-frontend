import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/services/storage_service.dart';
import 'package:lildairy/screens/HomeScreen.dart';

import '../api/auth_api.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  final AuthApi _authApi = AuthApi();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final isLoggedIn = false.obs;
  final token = RxnString();
  final currentUser = Rxn<User>();

  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  final opacity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    loadUserData();

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        opacity.value = 1.0;
      },
    );
  }

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
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
      await fetchCurrentUser();

      Get.offAll(() => NotesHomeScreen());

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

  Future<void> loginUser() async {
    await loginAPI(
      identifier: identifierController.text.trim(),
      password: passwordController.text,
    );
  }

  void loadUserData() {
    isLoggedIn.value = StorageService.isLoggedIn();
    token.value = StorageService.getToken();

    if (isLoggedIn.value && token.value != null) {
      fetchCurrentUser();
    }
  }

  Future<void> fetchCurrentUser() async {
    final currentToken = token.value;

    if (currentToken == null || currentToken.isEmpty) {
      return;
    }

    currentUser.value = await _authApi.getCurrentUser(token: currentToken);
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
    currentUser.value = null;
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
