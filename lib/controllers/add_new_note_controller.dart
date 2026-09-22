import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/api/diary_api.dart';
import 'package:lildairy/controllers/calendarscreen_controller.dart';
import 'package:lildairy/controllers/lendinghome_controller.dart';
import 'package:lildairy/services/storage_service.dart';
import 'package:permission_handler/permission_handler.dart';

class AddNewNoteController extends GetxController {
  final DiaryApi _diaryApi = DiaryApi();

  // ============================================
  // TEXT CONTROLLERS
  // ============================================

  final TextEditingController noteController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // ============================================
  // SELECTED MEDIA
  // ============================================

  final RxList<Map<String, dynamic>> selectedMedia =
      <Map<String, dynamic>>[].obs;

  // ============================================
  // LOADING
  // ============================================

  final RxBool isLoading = false.obs;

  // ============================================
  // PERMISSION MANAGEMENT
  // ============================================

  Future<bool> requestMediaPermission() async {
    if (Platform.isAndroid) {
      // Android 13+ (API 33+) requests photos and videos
      final statuses = await [
        Permission.photos,
        Permission.videos,
      ].request();

      final photosGranted = statuses[Permission.photos]?.isGranted == true ||
          statuses[Permission.photos]?.isLimited == true;
      final videosGranted = statuses[Permission.videos]?.isGranted == true ||
          statuses[Permission.videos]?.isLimited == true;

      if (photosGranted || videosGranted) {
        return true;
      }

      // Fallback for Android 12 and below
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted || storageStatus.isLimited) {
        return true;
      }

      if (storageStatus.isPermanentlyDenied ||
          statuses[Permission.photos]?.isPermanentlyDenied == true ||
          statuses[Permission.videos]?.isPermanentlyDenied == true) {
        _showPermissionDialog(
          "Storage and media permissions are permanently denied. Please enable them in App Settings to select photos or videos.",
        );
      } else {
        Get.snackbar(
          "Permission Denied",
          "Media permission is required to select photos and videos",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
      return false;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        _showPermissionDialog(
          "Photos permission is permanently denied. Please enable it in App Settings to select media.",
        );
      } else {
        Get.snackbar(
          "Permission Denied",
          "Photo Library permission is required to select media",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
      return false;
    }

    return true;
  }

  void _showPermissionDialog(String message) {
    Get.defaultDialog(
      title: "Permission Required",
      middleText: message,
      textConfirm: "Open Settings",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF81D4FA),
      onConfirm: () {
        openAppSettings();
        Get.back();
      },
    );
  }

  // ============================================
  // PICK MEDIA
  // ============================================

  Future<void> pickMedia() async {
    final hasPermission = await requestMediaPermission();
    if (!hasPermission) {
      return;
    }

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      for (final file in result.files) {
        if (file.path == null) {
          continue;
        }

        final fileExtension = file.extension?.toLowerCase();

        final bool isVideo = fileExtension == 'mp4' ||
            fileExtension == 'mov' ||
            fileExtension == 'avi' ||
            fileExtension == 'm4v' ||
            fileExtension == 'mkv' ||
            fileExtension == 'webm';

        selectedMedia.add({
          'file': File(file.path!),
          'isVideo': isVideo,
        });
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick files: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // SAVE NOTE (ADD DIARY API)
  // ============================================

  Future<void> saveNote() async {
    final title = noteController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      Get.snackbar(
        "Required",
        "Please enter title and description",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      return;
    }

    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Error",
        "User not logged in. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final files = selectedMedia
          .map((item) => item['file'] as File)
          .toList();

      await _diaryApi.addDiary(
        title: title,
        description: description,
        files: files,
        token: token,
      );

      // Clear fields and media on success
      noteController.clear();
      descriptionController.clear();
      selectedMedia.clear();

      // Refresh other controllers if active
      if (Get.isRegistered<CalendarController>()) {
        final calCtrl = Get.find<CalendarController>();
        calCtrl.fetchMemoriesForDate(calCtrl.selectedDate.value);
      }
      if (Get.isRegistered<LendingHomeController>()) {
        Get.find<LendingHomeController>().loadUserData();
      }

      Get.snackbar(
        "Success",
        "Memories added successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.85),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint("Add diary error: $e");
      Get.snackbar(
        "Error",
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // REMOVE MEDIA
  // ============================================

  void removeMedia(int index) {
    if (index >= 0 && index < selectedMedia.length) {
      selectedMedia.removeAt(index);
    }
  }

  // ============================================
  // DISPOSE
  // ============================================

  @override
  void onClose() {
    noteController.dispose();
    descriptionController.dispose();

    super.onClose();
  }
}