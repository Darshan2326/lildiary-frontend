import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/note_details_controller.dart';
import 'package:lildairy/widget/smart_media_widget.dart';

class NoteDetailScreen extends StatelessWidget {
  final String noteId;
  final Map<String, dynamic> noteData;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
    required this.noteData,
  });

  /// Builds a single media item for the carousel using SmartMediaWidget.
  Widget _buildCarouselItem(
    BuildContext context,
    NoteDetailsController controller,
    String rawMediaPath,
    int index,
    List<dynamic> mediaPaths,
  ) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.hardEdge,
            child: Obx(
              () => SmartMediaWidget(
                mediaPath: rawMediaPath,
                fit: BoxFit.cover,
                isPlaying: controller.currentIndex.value == index,
                onVideoPlayPause: (isPlaying) {
                  controller.onVideoPlayPause(isPlaying, index);
                },
              ),
            ),
          ),
        ),
        // Full screen expand icon button on top right of media
        Positioned(
          top: 8,
          right: 12,
          child: GestureDetector(
            onTap: () => controller.openFullScreen(context, rawMediaPath),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final NoteDetailsController controller = Get.put(
      NoteDetailsController(
        noteId: noteId,
        initialNoteData: noteData,
      ),
      tag: noteId,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Memories Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel Slider for Media (Images & Videos)
              Obx(() {
                final mediaPaths = controller.mediaPaths;
                if (mediaPaths.isNotEmpty) {
                  return CarouselSlider(
                    items: mediaPaths.asMap().entries.map((entry) {
                      final index = entry.key;
                      final mediaPath = entry.value as String;
                      return _buildCarouselItem(
                        context,
                        controller,
                        mediaPath,
                        index,
                        mediaPaths,
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 250.0,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: mediaPaths.length > 1,
                      autoPlay: false,
                      viewportFraction: 1,
                      onPageChanged: (index, reason) {
                        controller.onPageChanged(index);
                      },
                    ),
                  );
                } else {
                  return Center(
                    child: Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Text(
                          'No Media',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.calendar,
                    color: Color(0xFFF48FB1),
                  ),
                  const SizedBox(width: 10),
                  Obx(
                    () => Text(
                      controller.formattedDate,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => Text(
                        controller.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.printer_fill,
                      color: Color(0xFFF48FB1),
                    ),
                    onPressed: controller.shareNote,
                  ),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.share_up,
                      color: Color(0xFF81D4FA),
                    ),
                    onPressed: controller.shareNote,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                  ),
                  const Icon(Icons.access_time, color: Color(0xFF81D4FA)),
                  const SizedBox(width: 8),
                  Obx(
                    () => Text(
                      controller.formattedTime,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 245,
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Obx(
                    () => Text(
                      controller.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => controller.openEditNote(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF81D4FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                      child: Text(
                        'Edit Details',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.isDeleting.value) {
                      return const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF81D4FA),
                          ),
                        ),
                      );
                    }
                    return IconButton(
                      onPressed: () => controller.confirmAndDelete(context),
                      icon: const Icon(CupertinoIcons.delete),
                      color: const Color(0xFF81D4FA),
                      tooltip: 'Delete Note',
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Alias for convenience / consistency
typedef NoteDetailsScreen = NoteDetailScreen;
