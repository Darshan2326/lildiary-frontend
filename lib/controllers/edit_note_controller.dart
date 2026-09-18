import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class EditNoteController extends GetxController {
  final String noteId;
  final Map<String, dynamic> noteData;

  EditNoteController({
    required this.noteId,
    required this.noteData,
  });

  // Text controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();

  // Image picker
  final ImagePicker picker = ImagePicker();

  // Selected images/videos
  final List<File> selectedMedia = [];

  // Video controllers
  final List<VideoPlayerController?> videoControllers = [];

  @override
  void onInit() {
    super.onInit();

    // Set existing title
    titleController.text = noteData['title'] ?? '';

    // Set existing description
    descriptionController.text = noteData['description'] ?? '';

    // Load existing media
    if (noteData['mediaPaths'] != null) {
      final mediaPaths = noteData['mediaPaths'] as List<dynamic>;

      selectedMedia.addAll(
        mediaPaths.map((path) => File(path.toString())),
      );

      initializeVideos();
    }
  }

  // Initialize videos
  Future<void> initializeVideos() async {
    // Dispose old controllers
    for (final controller in videoControllers) {
      await controller?.dispose();
    }

    videoControllers.clear();

    // Keep same index as selectedMedia
    for (final media in selectedMedia) {
      if (media.path.toLowerCase().endsWith('.mp4')) {
        final controller = VideoPlayerController.file(media);

        await controller.initialize();

        videoControllers.add(controller);
      } else {
        videoControllers.add(null);
      }
    }

    update();
  }

  // Pick image
  Future<void> pickImage() async {
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      selectedMedia.add(
        File(pickedImage.path),
      );

      videoControllers.add(null);

      update();
    }
  }

  // Pick video
  Future<void> pickVideo() async {
    final pickedVideo = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (pickedVideo != null) {
      final videoFile = File(pickedVideo.path);

      selectedMedia.add(videoFile);

      final controller = VideoPlayerController.file(videoFile);

      await controller.initialize();

      videoControllers.add(controller);

      update();
    }
  }

  // Pick media
  //
  // This keeps the same behavior as your current code:
  // first image picker, then video picker if image was cancelled.
  Future<void> pickMedia() async {
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      selectedMedia.add(
        File(pickedImage.path),
      );

      videoControllers.add(null);

      update();
    } else {
      final pickedVideo = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedVideo != null) {
        final videoFile = File(pickedVideo.path);

        selectedMedia.add(videoFile);

        final controller = VideoPlayerController.file(videoFile);

        await controller.initialize();

        videoControllers.add(controller);

        update();
      }
    }
  }

  // Remove media
  Future<void> removeMedia(int index) async {
    if (index < 0 || index >= selectedMedia.length) {
      return;
    }

    // Dispose video controller if this media is a video
    if (index < videoControllers.length) {
      await videoControllers[index]?.dispose();

      videoControllers.removeAt(index);
    }

    selectedMedia.removeAt(index);

    update();
  }

  // Save edited note
  Future<void> saveEditedNote() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    debugPrint(
      'Saving note: $title, $description',
    );

    // Validation
    if (title.isEmpty || description.isEmpty) {
      Get.snackbar(
        'Validation',
        'Title and Description are required',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    // TODO:
    // Call your update-note API here.
    //
    // Example:
    // await updateNoteApi(
    //   noteId: noteId,
    //   title: title,
    //   description: description,
    //   media: selectedMedia,
    // );

    Get.snackbar(
      'Success',
      'Note changes are ready for API integration.',
      snackPosition: SnackPosition.BOTTOM,
    );

    Get.back();
  }

  @override
  void onClose() {
    // Dispose text controllers
    titleController.dispose();
    descriptionController.dispose();

    // Dispose video controllers
    for (final controller in videoControllers) {
      controller?.dispose();
    }

    videoControllers.clear();

    super.onClose();
  }
}