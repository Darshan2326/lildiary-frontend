import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lildairy/api/profile_api.dart';
import 'package:lildairy/controllers/login_controller.dart';
import 'package:lildairy/models/user.dart';

class ProfileController extends GetxController {
  final String userId;

  ProfileController({
    required this.userId,
  });

  // ============================================
  // API & AUTH SERVICES
  // ============================================

  final ProfileApi _profileApi = ProfileApi();

  AuthController get authController {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>();
    }
    return Get.put(AuthController());
  }

  String? get token => authController.token.value;

  // ============================================
  // IMAGE PICKER
  // ============================================

  final ImagePicker imagePicker = ImagePicker();

  // ============================================
  // OBSERVED USER STATE
  // ============================================

  final Rxn<User> user = Rxn<User>();
  final Rxn<File> profileImage = Rxn<File>();

  final RxString userName = ''.obs;
  final RxString userUsername = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString profileImageUrl = ''.obs;

  // ============================================
  // LOADING STATES
  // ============================================

  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isUpdatingProfile = false.obs;
  final RxBool isSendingOtp = false.obs;
  final RxBool isVerifyingOtp = false.obs;
  final RxBool isDeletingAccount = false.obs;

  // ============================================
  // INIT
  // ============================================

  @override
  void onInit() {
    super.onInit();
    loadUserDetails();
  }

  // ============================================
  // LOAD USER DETAILS (GET /me or GET /users/profile)
  // ============================================

  Future<void> loadUserDetails() async {
    final currentToken = token;
    if (currentToken == null || currentToken.isEmpty) {
      debugPrint('[PROFILE] No token available, skipping profile fetch');
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('[PROFILE] Fetching user profile...');

      User fetchedUser;
      try {
        fetchedUser = await _profileApi.getMeProfile(token: currentToken);
      } catch (_) {
        fetchedUser = await _profileApi.getProfile(token: currentToken);
      }

      user.value = fetchedUser;
      userName.value = fetchedUser.name ?? 'User';
      userUsername.value = fetchedUser.username ?? '';
      userEmail.value = fetchedUser.email ?? '';
      profileImageUrl.value = fetchedUser.profileImageUrl ?? '';
    } catch (e) {
      debugPrint('[PROFILE ERROR] Failed to load user details: $e');
      Get.snackbar(
        'Profile Error',
        'Could not load profile details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // UPLOAD PROFILE AVATAR (POST /users/profile/image)
  // ============================================

  Future<void> pickAndSaveImage() async {
    final currentToken = token;
    if (currentToken == null || currentToken.isEmpty) {
      Get.snackbar('Auth Error', 'You must be logged in to update avatar');
      return;
    }

    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      profileImage.value = file;

      isUploadingImage.value = true;

      final updatedUser = await _profileApi.uploadProfileImage(
        token: currentToken,
        image: file,
      );

      user.value = updatedUser;
      if (updatedUser.profileImageUrl != null && updatedUser.profileImageUrl!.isNotEmpty) {
        profileImageUrl.value = updatedUser.profileImageUrl!;
      }

      Get.snackbar(
        'Success',
        'Profile picture updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('[PROFILE ERROR] Image upload failed: $e');
      Get.snackbar(
        'Upload Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  // ============================================
  // UPDATE PROFILE INFO (PATCH /users/profile)
  // ============================================

  Future<bool> updateProfileInfo({
    required String name,
    required String username,
  }) async {
    final currentToken = token;
    if (currentToken == null || currentToken.isEmpty) {
      Get.snackbar('Auth Error', 'You must be logged in to update profile');
      return false;
    }

    try {
      isUpdatingProfile.value = true;

      final updatedUser = await _profileApi.updateProfile(
        token: currentToken,
        name: name,
        username: username,
      );

      user.value = updatedUser;
      userName.value = updatedUser.name ?? name;
      userUsername.value = updatedUser.username ?? username;

      // Ensure full profile details are reloaded from backend
      await loadUserDetails();

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint('[PROFILE ERROR] Update profile failed: $e');
      Get.snackbar(
        'Update Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // ============================================
  // REQUEST EMAIL CHANGE OTP (POST /users/profile/email/request)
  // ============================================

  Future<bool> requestEmailChangeOTP(String newEmail) async {
    final currentToken = token;
    if (currentToken == null || currentToken.isEmpty) {
      Get.snackbar('Auth Error', 'You must be logged in to change email');
      return false;
    }

    try {
      isSendingOtp.value = true;

      final message = await _profileApi.requestEmailChange(
        token: currentToken,
        newEmail: newEmail,
      );

      Get.snackbar(
        'OTP Sent',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade700,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint('[PROFILE ERROR] Email change request failed: $e');
      Get.snackbar(
        'Request Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSendingOtp.value = false;
    }
  }

  // ============================================
  // VERIFY EMAIL CHANGE OTP (POST /users/profile/email/verify)
  // ============================================

  Future<bool> verifyEmailChangeOTP({
    required String newEmail,
    required String otp,
  }) async {
    final currentToken = token;
    if (currentToken == null || currentToken.isEmpty) {
      Get.snackbar('Auth Error', 'You must be logged in to verify email');
      return false;
    }

    try {
      isVerifyingOtp.value = true;

      final updatedUser = await _profileApi.verifyEmailChange(
        token: currentToken,
        newEmail: newEmail,
        otp: otp,
      );

      user.value = updatedUser;
      userEmail.value = updatedUser.email ?? newEmail;

      // Refresh full profile data from backend to ensure Cloudflare/server state is synced
      await loadUserDetails();

      Get.snackbar(
        'Success',
        'Email updated successfully to ${userEmail.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint('[PROFILE ERROR] Email verification failed: $e');
      Get.snackbar(
        'Verification Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  // ============================================
  // DELETE ACCOUNT (DELETE /users/profile)
  // ============================================

  Future<void> deleteAccount(String password) async {
    final currentToken = token;
    if (currentToken == null || currentToken.isEmpty) {
      Get.snackbar('Auth Error', 'You must be logged in to delete account');
      return;
    }

    try {
      isDeletingAccount.value = true;

      await _profileApi.deleteProfile(
        token: currentToken,
        password: password,
      );

      Get.snackbar(
        'Account Deleted',
        'Your account has been deactivated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );

      await authController.logout();
    } catch (e) {
      debugPrint('[PROFILE ERROR] Delete account failed: $e');
      Get.snackbar(
        'Delete Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }

  // ============================================
  // LOGOUT (POST /logout)
  // ============================================

  Future<void> logout() async {
    try {
      final currentToken = token;
      if (currentToken != null && currentToken.isNotEmpty) {
        await _profileApi.logout(token: currentToken);
      }
      await authController.logout();
    } catch (e) {
      debugPrint('[PROFILE ERROR] Logout error: $e');
      await authController.logout();
    }
  }
}