import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/calendarscreen_controller.dart';
import 'package:lildairy/screens/NoteDetailsScreen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:video_player/video_player.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController controller = Get.put(CalendarController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calendar",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB4DCF1),
              Colors.white,
              Color(0xFFF1C6D4),
            ],
          ),
        ),
        child: Column(
          children: [
            // ==============================
            // CALENDAR
            // ==============================

            Padding(
              padding: const EdgeInsets.all(8),
              child: Card(
                elevation: 5,
                child: Obx(
                  () => TableCalendar(
                    focusedDay: controller.selectedDate.value,
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),
                    selectedDayPredicate: (day) {
                      return isSameDay(
                        controller.selectedDate.value,
                        day,
                      );
                    },
                    onDaySelected: controller.onDateSelected,
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFF81D4FA),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      todayTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ==============================
            // MEMORIES
            // ==============================

            Expanded(
              child: Obx(
                () {
                  final memories = controller.memoriesForSelectedDate;

                  if (memories.isEmpty) {
                    return const Center(
                      child: Text(
                        'No memories for this date',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final memory = memories[index];

                      final noteId = memory['id'];

                      final noteData = memory['data'];

                      final mediaPaths =
                          noteData['mediaPaths'] as List<dynamic>? ?? [];

                      final title = noteData['title'] ?? 'No Title';

                      final description =
                          noteData['description'] ?? 'No Description';

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: ListTile(
                          title: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              // Media
                              if (mediaPaths.isNotEmpty)
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: mediaPaths.length,
                                    itemBuilder: (
                                      context,
                                      mediaIndex,
                                    ) {
                                      final mediaPath = mediaPaths[mediaIndex];

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 4.0,
                                        ),
                                        child: SizedBox(
                                          width: 150,
                                          child: _buildMediaPreview(
                                            mediaPath.toString(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            _viewFullNote(
                              context,
                              noteId,
                              noteData,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // OPEN NOTE DETAILS
  // ==============================

  void _viewFullNote(
    BuildContext context,
    String noteId,
    Map<String, dynamic> noteData,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(
          noteId: noteId,
          noteData: noteData,
        ),
      ),
    );
  }

  // ==============================
  // CHECK IMAGE
  // ==============================

  bool _isImage(String path) {
    const imageExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
    ];

    final extension = path.split('.').last.toLowerCase();

    return imageExtensions.contains(
      extension,
    );
  }

  // ==============================
  // MEDIA PREVIEW
  // ==============================

  Widget _buildMediaPreview(String path) {
    if (_isImage(path)) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey,
            child: const Center(
              child: Text(
                'Invalid Image',
              ),
            ),
          );
        },
      );
    }

    return VideoPreview(
      path: path,
    );
  }
}

// ============================================================
// VIDEO PREVIEW
// ============================================================

class VideoPreview extends StatefulWidget {
  final String path;

  const VideoPreview({
    super.key,
    required this.path,
  });

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(
      File(widget.path),
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
