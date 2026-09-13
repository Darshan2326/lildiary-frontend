import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lildairy/screens/NoteDetailsScreen.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

class lendingHomeScreen extends StatefulWidget {
  final String userId; // Pass the user ID to differentiate accounts

  const lendingHomeScreen({super.key, required this.userId});

  @override
  State<lendingHomeScreen> createState() => _lendingHomeScreenState();
}

class _lendingHomeScreenState extends State<lendingHomeScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isVideoPlaying = false;
  File? _profileImage;
  String? _userName;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // Dismiss the keyboard when tapping outside of the text field
  void dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void searchNotes(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  void _viewFullNote(String noteId, Map<String, dynamic> noteData) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dismissKeyboard,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // centerTitle: true,
            actions: const [
              Image(
                image: AssetImage("assets/logos/Logo_png.png"),
              ),
            ],
            toolbarHeight: 100,
            // title: Image.asset("assets/logos/Logo_png.png",),

            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 18, color: Colors.black38),
                ),
                Text(
                  _userName ?? 'Loading...',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB4DCF1), Colors.white, Color(0xFFF1C6D4)],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: searchController,
                  onChanged: searchNotes,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search Diary...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: Future.value(const <Map<String, dynamic>>[]),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final notes = snapshot.data!.where((noteData) {
                      final title = noteData['title']?.toLowerCase() ?? '';
                      return title.contains(searchQuery);
                    }).toList();

                    if (notes.isEmpty && searchQuery.isNotEmpty) {
                      // Show empty animation if no results found
                      return Column(
                        children: [
                          Center(
                            child: Lottie.asset(
                              'assets/animation/empty.json',
                              width: 250,
                              height: 250,
                            ),
                          ),
                          const Text("No Memories...")
                        ],
                      );
                    }

                    if (notes.isEmpty) {
                      // Show message when there are no notes
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Center(
                            child: Text(
                              'No Memories...',
                              style: TextStyle(
                                  fontSize: 20, color: Colors.black54),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final noteData = notes[index];

                        // Get media paths
                        final mediaPaths = noteData != null &&
                                noteData.containsKey('mediaPaths')
                            ? (noteData['mediaPaths'] as List<dynamic>)
                                .map((item) => item.toString())
                                .toList()
                            : <String>[];

                        // Formatting the date
                        final formattedDate = DateFormat('dd MMM, yyyy').format(
                          DateTime.parse(noteData['timestamp'] as String),
                        );

                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            children: [
                              if (mediaPaths.isNotEmpty)
                                _buildMediaGrid(mediaPaths)
                              else
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Text(
                                      'No Media',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.black54),
                                    ),
                                  ),
                                ),
                              ListTile(
                                title: Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  noteData?['title'] ?? 'No Title',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Row(
                                  children: [
                                    const Icon(CupertinoIcons.calendar,
                                        color: Color(0xFFF48FB1), size: 20),
                                    const SizedBox(width: 5),
                                    Text(formattedDate),
                                  ],
                                ),
                                onTap: () => _viewFullNote(
                                    noteData['id'] as String, noteData),
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

  Widget _buildMediaGrid(List<String> mediaPaths) {
    int mediaCount = mediaPaths.length;

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
        // Check if the file is an image or video
        bool isVideo = mediaPaths[index].endsWith('.mp4');

        if (index == 3 && mediaCount > 3) {
          return Stack(
            fit: StackFit.expand,
            children: [
              isVideo
                  ? VideoPlayerWidget(
                      mediaFile: File(mediaPaths[index]),
                      isPlaying: isVideoPlaying,
                      onVideoPlayPause: () {
                        setState(() {
                          isVideoPlaying = !isVideoPlaying;
                        });
                      },
                    )
                  : Image.file(
                      File(mediaPaths[index]),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey,
                          child: const Center(child: Text('Invalid Image')),
                        );
                      },
                    ),
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Text(
                    'More',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ],
          );
        } else {
          return isVideo
              ? VideoPlayerWidget(
                  mediaFile: File(mediaPaths[index]),
                  isPlaying: isVideoPlaying,
                  onVideoPlayPause: () {
                    setState(() {
                      isVideoPlaying = !isVideoPlaying;
                    });
                  },
                )
              : Image.file(
                  File(mediaPaths[index]),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey,
                      child: const Center(child: Text('Invalid Image')),
                    );
                  },
                );
        }
      },
    );
  }
}

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
    _controller = VideoPlayerController.file(widget.mediaFile)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
            onTap: widget.onVideoPlayPause,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                if (!widget.isPlaying)
                  const Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 50),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
