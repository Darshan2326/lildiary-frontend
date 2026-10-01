import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/screens/login.dart';
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

  Future<void>? _fetchUserFuture;
  bool _isHandlingSessionExpiry = false;

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
    } on NetworkException catch (error) {
      debugPrint('[AUTH ERROR] Network error during login: ${error.message}');
      errorMessage.value = error.message;

      Get.snackbar(
        'Connection Error',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    } catch (error, stackTrace) {
      debugPrint('[AUTH ERROR] Login failed: $error');
      debugPrint('[AUTH ERROR] Stack trace: $stackTrace');
      final friendlyMsg = _formatErrorMessage(error.toString());
      errorMessage.value = friendlyMsg;

      Get.snackbar(
        'Login Failed',
        friendlyMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _formatErrorMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('socketexception') ||
        lower.contains('connection refused') ||
        lower.contains('clientexception') ||
        lower.contains('network is unreachable') ||
        lower.contains('failed host lookup')) {
      return 'Unable to connect to server. Please check your internet connection or server IP address.';
    }
    if (lower.contains('timeoutexception') || lower.contains('timed out')) {
      return 'Connection timed out. The server took too long to respond.';
    }
    return raw.replaceAll('Exception: ', '').trim();
  }

  Future<void> loginUser() async {
    await loginAPI(
      identifier: identifierController.text.trim(),
      password: passwordController.text,
    );
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }
      var payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> data = jsonDecode(decoded);
      if (data.containsKey('exp')) {
        final exp = data['exp'];
        final expSeconds = exp is int ? exp : int.tryParse(exp.toString());
        if (expSeconds != null) {
          final expDate = DateTime.fromMillisecondsSinceEpoch(
            expSeconds * 1000,
          );
          return DateTime.now().isAfter(expDate);
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadUserData() async {
    isLoggedIn.value = StorageService.isLoggedIn();
    token.value = StorageService.getToken();

    final currentToken = token.value;

    if (isLoggedIn.value && currentToken != null && currentToken.isNotEmpty) {
      if (_isTokenExpired(currentToken)) {
        debugPrint('[AUTH] Stored token has expired according to exp claim');
        await handleSessionExpired('Session expired. Please log in again.');
        return;
      }

      await fetchCurrentUser();
    }
  }

  Future<void> fetchCurrentUser() async {
    if (_fetchUserFuture != null) {
      return _fetchUserFuture;
    }

    _fetchUserFuture = _performFetchCurrentUser();
    try {
      await _fetchUserFuture;
    } finally {
      _fetchUserFuture = null;
    }
  }

  Future<void> _performFetchCurrentUser() async {
    final currentToken = token.value;

    if (currentToken == null || currentToken.isEmpty) {
      return;
    }

    try {
      currentUser.value = await _authApi.getCurrentUser(token: currentToken);
    } on SessionExpiredException catch (e) {
      debugPrint('[AUTH] Session expired: ${e.message}');
      await handleSessionExpired('Session expired. Please log in again.');
    } on NetworkException catch (e) {
      debugPrint('[AUTH] Network error while fetching user: ${e.message}');
      errorMessage.value = e.message;
      showNetworkErrorSnackbar(e.message);
    } catch (error, stackTrace) {
      debugPrint('[AUTH ERROR] Fetch current user failed: $error');
      debugPrint('[AUTH ERROR] Stack trace: $stackTrace');

      final errorMsg = error.toString().toLowerCase();
      final isSessionExpired = errorMsg.contains('session expired') ||
          errorMsg.contains('invalid token') ||
          errorMsg.contains('unauthorized') ||
          errorMsg.contains('401');

      if (isSessionExpired) {
        await handleSessionExpired('Session expired. Please log in again.');
      } else if (errorMsg.contains('socketexception') ||
          errorMsg.contains('connection refused') ||
          errorMsg.contains('clientexception') ||
          errorMsg.contains('network') ||
          errorMsg.contains('timed out')) {
        const friendlyMsg =
            'Unable to connect to server. Please check your internet connection or server IP address.';
        errorMessage.value = friendlyMsg;
        showNetworkErrorSnackbar(friendlyMsg);
      } else {
        errorMessage.value = error.toString();
      }
    }
  }

  void showNetworkErrorSnackbar([String? message]) {
    final displayMessage = (message != null && message.isNotEmpty)
        ? message
        : 'Unable to connect to server. Please check your internet connection or server IP address.';

    void show() {
      if (Get.context == null) return;
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        'Connection Error',
        displayMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        icon: const Icon(
          Icons.wifi_off_rounded,
          color: Colors.white,
        ),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        show();
      });
    });
  }

  Future<void> handleSessionExpired([String? message]) async {
    if (_isHandlingSessionExpiry) return;
    _isHandlingSessionExpiry = true;

    try {
      debugPrint('[AUTH] Session expired or invalid token. Redirecting to login.');

      await StorageService.clear();

      token.value = null;
      isLoggedIn.value = false;
      currentUser.value = null;

      final displayMessage = (message != null && message.isNotEmpty)
          ? message
          : 'Session expired. Please log in again.';

      errorMessage.value = displayMessage;

      Get.offAll(() => LoginScreen());

      showSessionExpiredSnackbar(displayMessage);
    } catch (e) {
      debugPrint('[AUTH ERROR] Error during handleSessionExpired: $e');
    } finally {
      _isHandlingSessionExpiry = false;
    }
  }

  void showSessionExpiredSnackbar(String message) {
    void show() {
      if (Get.context == null) return;
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        'Session Expired',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,
        ),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 250), () {
        show();
      });
    });
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

    Get.offAll(() => LoginScreen());
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

      await logout();
      Get.snackbar('Logout Failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
