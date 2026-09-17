import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNewNoteController extends GetxController {
  // ============================================
  // TEXT CONTROLLERS
  // ============================================

  final TextEditingController noteController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

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
  // SAVE NOTE
  // ============================================

  Future<void> saveNote() async {
    if (noteController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        "Required",
        "Please enter title and description",
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      isLoading.value = true;

      // ========================================
      // TODO:
      // Add your API call here
      // ========================================

      // Example:
      //
      // await apiClient.post(
      //   "/notes",
      //   {
      //     "title": noteController.text.trim(),
      //     "description": descriptionController.text.trim(),
      //   },
      // );

      // Clear fields
      noteController.clear();
      descriptionController.clear();

      // Clear selected media
      selectedMedia.clear();

      Get.snackbar(
        "Success",
        "Memories added",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to save memory: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // PICK MEDIA
  // ============================================

  Future<void> pickMedia() async {
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

        final fileExtension =
            file.extension?.toLowerCase();

        final bool isVideo =
            fileExtension == 'mp4' ||
            fileExtension == 'mov' ||
            fileExtension == 'avi';

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
  // REMOVE MEDIA
  // ============================================

  void removeMedia(int index) {
    if (index >= 0 &&
        index < selectedMedia.length) {
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