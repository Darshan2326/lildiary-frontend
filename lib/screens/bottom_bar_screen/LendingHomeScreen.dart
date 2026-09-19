import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lildairy/controllers/lendinghome_controller.dart';
import 'package:lildairy/screens/NoteDetailsScreen.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

class lendingHomeScreen extends StatelessWidget {
  final String userId;

  lendingHomeScreen({
    super.key,
    required this.userId,
  });

  final LendingHomeController controller = Get.put(
    LendingHomeController(),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: const [
              Image(
                image: AssetImage(
                  "assets/logos/Logo_png.png",
                ),
              ),
            ],
            toolbarHeight: 100,
            title: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black38,
                    ),
                  ),
                      Text(
                        controller.userName.value.isEmpty
                            ? 'Loading...'
                            : controller.userName.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
              // Search
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.searchNotes,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                    ),
                    hintText: 'Search Diary...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              // Notes
              Expanded(
                child: Obx(
                  () {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final notes = controller.diaries.where(
                      (diary) {
                        final searchableText =
                            '${diary.title ?? ''} ${diary.description ?? ''}'
                                .toLowerCase();

                        return searchableText.contains(
                          controller.searchQuery.value,
                        );
                      },
                    ).toList();

                        // No search result
                        if (notes.isEmpty &&
                            controller.searchQuery.value.isNotEmpty) {
                          return Column(
                            children: [
                              Center(
                                child: Lottie.asset(
                                  'assets/animation/empty.json',
                                  width: 250,
                                  height: 250,
                                ),
                              ),
                              const Text(
                                "No Memories...",
                              ),
                            ],
                          );
                        }

                        // No notes
                        if (notes.isEmpty) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                          );
                        }

                        return ListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final diary = notes[index];
                            final mediaPaths = diary.images ?? <String>[];
                            final noteData = <String, dynamic>{
                              'id': diary.id?.toString(),
                              'title': diary.title,
                              'description': diary.description,
                              'mediaPaths': mediaPaths,
                              'timestamp': diary.createdAt ??
                                  DateTime.now().toIso8601String(),
                            };
                            final createdAt = DateTime.tryParse(
                              diary.createdAt ?? '',
                            );
                            final formattedDate = createdAt == null
                                ? 'Date unavailable'
                                : DateFormat('dd MMM, yyyy').format(createdAt);

                            return Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  // Media
                                  if (mediaPaths.isNotEmpty)
                                    _buildMediaGrid(
                                      mediaPaths,
                                    )
                                  else
                                    Container(
                                      height: 200,
                                      width: double.infinity,
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

                                  // Note information
                                  ListTile(
                                    title: Text(
                                      diary.title ?? 'No Title',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.calendar,
                                          color: Color(0xFFF48FB1),
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
                                    onTap: () {
                                      _viewFullNote(
                                        context,
                                        diary.id.toString(),
                                        noteData,
                                      );
                                    },
                                  ),
                                ],
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
      ),
    );
  }

  // Open note details
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

  // Media grid
  Widget _buildMediaGrid(
    List<String> mediaPaths,
  ) {
    final int mediaCount = mediaPaths.length;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mediaCount > 2 ? 2 : mediaCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: mediaCount > 3 ? 4 : mediaCount,
      itemBuilder: (context, index) {
        final bool isVideo = mediaPaths[index].endsWith('.mp4');

        // More overlay
        if (index == 3 && mediaCount > 3) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildMedia(
                mediaPaths[index],
                isVideo,
              ),
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Text(
                    'More',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return _buildMedia(
          mediaPaths[index],
          isVideo,
        );
      },
    );
  }

  // Build image/video
  Widget _buildMedia(
    String mediaPath,
    bool isVideo,
  ) {
    if (isVideo && !mediaPath.startsWith('http')) {
      return Obx(
        () => VideoPlayerWidget(
          mediaFile: File(mediaPath),
          isPlaying: controller.isVideoPlaying.value,
          onVideoPlayPause: () {
            controller.toggleVideo();
          },
        ),
      );
    }

    if (mediaPath.startsWith('http')) {
      return Image.network(
        mediaPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _invalidMedia(),
      );
    }

    return Image.file(
      File(mediaPath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _invalidMedia();
      },
    );
  }

  Widget _invalidMedia() {
    return Container(
      color: Colors.grey,
      child: const Center(child: Text('Invalid Image')),
    );
  }
}

// ============================================================
// VIDEO PLAYER
// ============================================================

class VideoPlayerWidget extends StatefulWidget {
  final File mediaFile;

  final bool isPlaying;

  final VoidCallback onVideoPlayPause;

  const VideoPlayerWidget({
    super.key,
    required this.mediaFile,
    required this.isPlaying,
    required this.onVideoPlayPause,
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
  void didUpdateWidget(
    covariant VideoPlayerWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying) {
      _controller.play();
    } else {
      _controller.pause();
    }
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

    return GestureDetector(
      onTap: widget.onVideoPlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(
              _controller,
            ),
          ),
          if (!widget.isPlaying)
            const Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 50,
            ),
        ],
      ),
    );
  }
}
