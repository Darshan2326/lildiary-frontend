import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/login_controller.dart';
import 'package:lildairy/models/user.dart';

class LendingHomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  // Search
  final TextEditingController searchController = TextEditingController();

  final RxString searchQuery = ''.obs;

  // User data from /me
  final Rxn<User> currentUser = Rxn<User>();
  final RxList<Diaries> diaries = <Diaries>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Video playing state
  final RxBool isVideoPlaying = false.obs;

  // Profile data
  final Rxn<File> profileImage = Rxn<File>();
  final RxString userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await authController.fetchCurrentUser();

      final user = authController.currentUser.value;
      currentUser.value = user;
      userName.value = user?.name ?? user?.username ?? '';
      diaries.assignAll(user?.diaries ?? <Diaries>[]);
    } catch (error) {
      errorMessage.value = error.toString();
      diaries.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Search notes
  void searchNotes(String query) {
    searchQuery.value = query.toLowerCase();
  }

  // Toggle video
  void toggleVideo() {
    isVideoPlaying.value = !isVideoPlaying.value;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
