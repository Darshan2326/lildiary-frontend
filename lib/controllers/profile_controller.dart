import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lildairy/controllers/login_controller.dart';

class ProfileController extends GetxController {
  // ============================================
  // USER ID
  // ============================================

  final String userId;

  ProfileController({
    required this.userId,
  });

  // ============================================
  // AUTH CONTROLLER
  // ============================================

  final AuthController authController =
      Get.find<AuthController>();

  // ============================================
  // IMAGE PICKER
  // ============================================

  final ImagePicker imagePicker = ImagePicker();

  // ============================================
  // USER DATA
  // ============================================

  final Rxn<File> profileImage = Rxn<File>();

  final RxString userName = ''.obs;

  final RxString userEmail = ''.obs;

  // ============================================
  // LOADING
  // ============================================

  final RxBool isLoading = false.obs;

  final RxBool isUploadingImage = false.obs;

  // ============================================
  // INIT
  // ============================================

  @override
  void onInit() {
    super.onInit();

    loadUserEmail();
    loadUserDetails();
    loadProfileImage();
  }

  // ============================================
  // LOAD PROFILE IMAGE
  // ============================================

  Future<void> loadProfileImage() async {
    try {
      // TODO:
      // Add your API profile image loading here.

      // Example:
      //
      // profileImageUrl.value = response['profile_image'];
    } catch (e) {
      print('Profile image loading error: $e');
    }
  }

  // ============================================
  // LOAD USER EMAIL
  // ============================================

  Future<void> loadUserEmail() async {
    try {
      // TODO:
      // Replace with your API response.

      userEmail.value = 'API email';
    } catch (e) {
      print('User email loading error: $e');
    }
  }

  // ============================================
  // LOAD USER DETAILS
  // ============================================

  Future<void> loadUserDetails() async {
    try {
      isLoading.value = true;

      // TODO:
      // Replace these with your API response.

      userName.value = 'API user';
      userEmail.value = 'API email';
    } catch (e) {
      print('User details loading error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // PICK PROFILE IMAGE
  // ============================================

  Future<void> pickAndSaveImage() async {
    try {
      isUploadingImage.value = true;

      final XFile? pickedFile =
          await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        return;
      }

      profileImage.value = File(
        pickedFile.path,
      );

      Get.snackbar(
        'Success',
        'Profile image updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // TODO:
      // Upload image to your API here.
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  // ============================================
  // PASSWORD RESET
  // ============================================

  Future<void> sendPasswordResetEmail() async {
    Get.snackbar(
      'Password Reset',
      'Password reset is unavailable in offline mode',
      snackPosition: SnackPosition.BOTTOM,
    );

    // TODO:
    // Connect your password reset API here.
  }

  // ============================================
  // DELETE ACCOUNT
  // ============================================

  Future<void> deleteAccount() async {
    try {
      Get.snackbar(
        'Delete Account',
        'Delete action is ready for API integration',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Your existing AuthController logout
      await authController.logout();
    } catch (e) {
      print('Error deleting account: $e');

      Get.snackbar(
        'Error',
        'Failed to delete account',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // LOGOUT
  // ============================================

  Future<void> logout() async {
    try {
      await authController.logoutAPI();
    } catch (e) {
      print('Logout error: $e');

      Get.snackbar(
        'Error',
        'Failed to logout',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}