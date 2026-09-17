import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class LendingHomeController extends GetxController {
  // Search
  final TextEditingController searchController = TextEditingController();

  final RxString searchQuery = ''.obs;

  // Video playing state
  final RxBool isVideoPlaying = false.obs;

  // Profile data
  final Rxn<File> profileImage = Rxn<File>();
  final RxString userName = ''.obs;

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
