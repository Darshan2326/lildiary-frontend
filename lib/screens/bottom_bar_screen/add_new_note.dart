import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/add_new_note_controller.dart';
import 'package:lildairy/widget/button.dart';
import 'package:video_player/video_player.dart';

class addNewNote extends StatelessWidget {
  const addNewNote({super.key});

  @override
  Widget build(BuildContext context) {
    final AddNewNoteController controller = Get.put(AddNewNoteController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Diary",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 10.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ============================================
              // TITLE LABEL
              // ============================================

              const Padding(
                padding: EdgeInsets.only(
                  left: 15.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Title",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================
              // TITLE TEXT FIELD
              // ============================================

              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8,
                  bottom: 25,
                ),
                child: TextField(
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  controller: controller.noteController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      CupertinoIcons.paperclip,
                      color: Color(0xFFF48FB1),
                    ),
                    hintText: "Enter Title",
                    hintStyle: const TextStyle(
                      color: Colors.black38,
                      fontSize: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black54,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFedf0f8),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),

              // ============================================
              // DESCRIPTION LABEL
              // ============================================

              const Padding(
                padding: EdgeInsets.only(
                  left: 15.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================
              // DESCRIPTION TEXT FIELD
              // ============================================

              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8,
                  bottom: 8,
                ),
                child: TextField(
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  controller: controller.descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      CupertinoIcons.news,
                      color: Color(0xFFF48FB1),
                    ),
                    hintText: "Enter Description",
                    hintStyle: const TextStyle(
                      color: Colors.black38,
                      fontSize: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black54,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFedf0f8),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),

              // ============================================
              // ADD MEDIA BUTTON
              // ============================================

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8.0,
                        ),
                        side: const BorderSide(
                          color: Color(0xFF4FC3F7),
                        ),
                      ),
                    ),
                  ),
                  onPressed: controller.pickMedia,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Image.asset(
                          "assets/logos/plus.png",
                          height: 35,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        "Add Pictures or Videos",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ============================================
              // SELECTED MEDIA
              // ============================================

              SizedBox(
                height: 250,
                width: double.infinity,
                child: Obx(
                  () {
                    if (controller.selectedMedia.isEmpty) {
                      return const Center(
                        child: Text(
                          "No Media Selected",
                        ),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.selectedMedia.length,
                      itemBuilder: (context, index) {
                        final media = controller.selectedMedia[index];

                        final File file = media['file'];

                        final bool isVideo = media['isVideo'];

                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8),
                              width: 200,
                              height: 200,
                              child: isVideo
                                  ? VideoPlayerWidget(
                                      mediaFile: file,
                                    )
                                  : Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                    ),
                            ),

                            // =================================
                            // REMOVE BUTTON
                            // =================================

                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  controller.removeMedia(
                                    index,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // ============================================
              // SAVE BUTTON
              // ============================================

              Obx(
                () {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    );
                  }

                  return MyButtons(
                    onTap: () {
                      controller.saveNote();
                    },
                    text: "Add Memories",
                  );
                },
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// VIDEO PLAYER
// ============================================================

class VideoPlayerWidget extends StatefulWidget {
  final File mediaFile;

  const VideoPlayerWidget({
    super.key,
    required this.mediaFile,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(
      widget.mediaFile,
    )..initialize().then(
        (_) {
          if (mounted) {
            setState(() {});
          }
        },
      );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(
        _controller,
      ),
    );
  }
}
