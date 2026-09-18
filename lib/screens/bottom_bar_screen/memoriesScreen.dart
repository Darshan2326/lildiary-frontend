import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lildairy/controllers/memories_controller.dart';
import 'package:lildairy/screens/NoteDetailsScreen.dart';
import 'package:video_player/video_player.dart';

class Memoriesscreen extends StatelessWidget {
  const Memoriesscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MemoriesController controller =
        Get.put(MemoriesController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Memories",
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

        child: Obx(
          () {
            // ==========================================
            // LOADING
            // ==========================================

            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ==========================================
            // NO MEMORIES
            // ==========================================

            if (controller.memories.isEmpty) {
              return RefreshIndicator(
                onRefresh:
                    controller.refreshMemories,

                child: ListView(
                  children: const [
                    SizedBox(
                      height: 300,
                    ),

                    Center(
                      child: Text(
                        'No Memories...',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // ==========================================
            // MEMORIES LIST
            // ==========================================

            return RefreshIndicator(
              onRefresh:
                  controller.refreshMemories,

              child: ListView.builder(
                itemCount:
                    controller.memories.length,

                itemBuilder:
                    (context, index) {
                  final noteData =
                      controller.memories[index];

                  // ====================================
                  // MEDIA PATHS
                  // ====================================

                  final mediaPaths =
                      noteData.containsKey(
                              'mediaPaths')
                          ? List<String>.from(
                              noteData['mediaPaths']
                                  as List<dynamic>,
                            )
                          : <String>[];

                  // ====================================
                  // DATE
                  // ====================================

                  final formattedDate =
                      DateFormat(
                    'dd MMM, yyyy',
                  ).format(
                    DateTime.parse(
                      noteData['timestamp']
                          as String,
                    ),
                  );

                  // ====================================
                  // CARD
                  // ====================================

                  return Card(
                    elevation: 5,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),

                    child: Column(
                      children: [
                        // ==================================
                        // MEDIA
                        // ==================================

                        if (mediaPaths.isNotEmpty)
                          SizedBox(
                            height: 200,
                            width: double.infinity,

                            child: mediaPaths[0]
                                    .toLowerCase()
                                    .endsWith(
                                      '.mp4',
                                    )
                                ? VideoPlayerWidget(
                                    mediaFile:
                                        File(
                                      mediaPaths[0],
                                    ),
                                  )
                                : Image.file(
                                    File(
                                      mediaPaths[0],
                                    ),

                                    fit: BoxFit
                                        .cover,

                                    errorBuilder:
                                        (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Container(
                                        color:
                                            Colors.grey,

                                        child:
                                            const Center(
                                          child:
                                              Text(
                                            'Invalid Image',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          )

                        // ==================================
                        // NO MEDIA
                        // ==================================

                        else
                          Container(
                            height: 200,
                            width: double.infinity,

                            color:
                                Colors.grey[200],

                            child:
                                const Center(
                              child: Text(
                                'No Media',

                                style:
                                    TextStyle(
                                  fontSize: 18,
                                  color:
                                      Colors.black54,
                                ),
                              ),
                            ),
                          ),

                        // ==================================
                        // NOTE DETAILS
                        // ==================================

                        ListTile(
                          title: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [
                              Expanded(
                                child: Text(
                                  noteData['title'] ??
                                      'No Title',

                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  maxLines: 2,

                                  style:
                                      const TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),

                              // ============================
                              // VIEW DETAILS
                              // ============================

                              TextButton(
                                onPressed: () {
                                  _viewFullNote(
                                    context,
                                    noteData['id']
                                        as String,
                                    noteData,
                                  );
                                },

                                child:
                                    const Text(
                                  "View Details",

                                  style:
                                      TextStyle(
                                    color:
                                        Color(
                                      0xFF81D4FA,
                                    ),

                                    backgroundColor:
                                        Color(
                                      0xFFE1F5FE,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // =================================
                          // DATE
                          // =================================

                          subtitle: Row(
                            children: [
                              const Icon(
                                CupertinoIcons
                                    .calendar,

                                color:
                                    Color(
                                  0xFFF48FB1,
                                ),

                                size: 20,
                              ),

                              const SizedBox(
                                width: 5,
                              ),

                              Text(
                                formattedDate,
                              ),
                            ],
                          ),

                          // =================================
                          // OPEN DETAILS
                          // =================================

                          onTap: () {
                            _viewFullNote(
                              context,
                              noteData['id']
                                  as String,
                              noteData,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================
  // VIEW FULL NOTE
  // ============================================

  void _viewFullNote(
    BuildContext context,
    String noteId,
    Map<String, dynamic> noteData,
  ) {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) =>
            NoteDetailScreen(
          noteId: noteId,
          noteData: noteData,
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
  State<VideoPlayerWidget> createState() =>
      _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState
    extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        VideoPlayerController.file(
      widget.mediaFile,
    )
          ..initialize().then(
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
      aspectRatio:
          _controller.value.aspectRatio,

      child: VideoPlayer(
        _controller,
      ),
    );
  }
}