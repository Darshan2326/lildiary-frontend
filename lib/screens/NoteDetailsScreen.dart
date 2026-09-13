import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lildairy/screens/FullScreenMediaViewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'EditNoteScreen.dart'; // Import the new edit screen

class NoteDetailScreen extends StatefulWidget {
  final String noteId;
  final Map<String, dynamic> noteData;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
    required this.noteData,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  int _currentIndex = 0; // Track current carousel index

  // Function to delete the note
  Future<void> _deleteNote() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Delete action is ready for API integration.')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaPaths = widget.noteData['mediaPaths'] as List<dynamic>?;
    final timestamp = DateTime.parse(widget.noteData['timestamp'] as String);
    final formattedDate = DateFormat('dd MMM, yyyy').format(timestamp);
    final formattedTime = DateFormat('hh:mm a').format(timestamp);

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
              if (mediaPaths != null && mediaPaths.isNotEmpty)
                CarouselSlider(
                  items: mediaPaths.map((mediaPath) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FullScreenMediaViewer(mediaPath: mediaPath),
                          ),
                        );
                      },
                      child: Builder(
                        builder: (BuildContext context) {
                          if (mediaPath.endsWith('.mp4')) {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: VideoPlayerWidget(
                                mediaFile: File(mediaPath),
                                isPlaying: _currentIndex ==
                                    mediaPaths.indexOf(mediaPath),
                                onVideoPlayPause: (isPlaying) {
                                  setState(() {
                                    if (isPlaying) {
                                      _currentIndex =
                                          mediaPaths.indexOf(mediaPath);
                                    }
                                  });
                                },
                              ),
                            );
                          } else {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.file(
                                File(mediaPath),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey,
                                    child: const Center(
                                        child: Text('Invalid Image')),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 250.0,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 7),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 3000),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),

              if (mediaPaths == null || mediaPaths.isEmpty)
                Center(
                  child: Container(
                    height: 250,
                    color: Colors.grey[
                        200], // Optional: You can change this to any color
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
                ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.calendar,
                    color: Color(0xFFF48FB1),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 100,
                  ),
                  // const Text('3/4'),
                  const SizedBox(width: 10),
                  // SizedBox(
                  //   width: 120,
                  //   child: LinearProgressIndicator(
                  //     value: 0.75,
                  //     backgroundColor: Colors.grey[300],
                  //     color: const Color(0xFFF48FB1),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.noteData['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.printer_fill,
                        color: Color(0xFFF48FB1)),
                    onPressed: () async {
                      String title = widget.noteData['title'] ?? 'No Title';
                      String description =
                          widget.noteData['description'] ?? 'No Description';
                      List<dynamic>? mediaPaths = widget.noteData['mediaPaths'];

                      String shareMessage = "$title\n\n$description";

                      try {
                        if (mediaPaths != null && mediaPaths.isNotEmpty) {
                          List<XFile> files =
                              mediaPaths.map((path) => XFile(path)).toList();
                          await Share.shareXFiles(files, text: shareMessage);
                        } else {
                          await Share.share(shareMessage);
                        }
                      } catch (e) {
                        print('Error while sharing: $e');
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.share_up,
                        color: Color(0xFF81D4FA)),
                    onPressed: () async {
                      String title = widget.noteData['title'] ?? 'No Title';
                      String description =
                          widget.noteData['description'] ?? 'No Description';
                      List<dynamic>? mediaPaths = widget.noteData['mediaPaths'];

                      String shareMessage = "$title\n\n$description";

                      try {
                        if (mediaPaths != null && mediaPaths.isNotEmpty) {
                          List<XFile> files =
                              mediaPaths.map((path) => XFile(path)).toList();
                          await Share.shareXFiles(files, text: shareMessage);
                        } else {
                          await Share.share(shareMessage);
                        }
                      } catch (e) {
                        print('Error while sharing: $e');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                  ),
                  const Icon(Icons.access_time, color: Color(0xFF81D4FA)),
                  const SizedBox(width: 8),
                  Text(
                    formattedTime,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 245,
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    widget.noteData['description'] ?? 'No Description',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditNoteScreen(
                            noteId: widget.noteId,
                            noteData: widget.noteData,
                          ),
                        ),
                      ).then((_) {
                        setState(() {});
                      });
                    },
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
                  IconButton(
                    onPressed: _deleteNote,
                    icon: const Icon(CupertinoIcons.delete),
                    color: const Color(0xFF81D4FA),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final File mediaFile;
  final bool isPlaying;
  final Function(bool) onVideoPlayPause;

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
    if (widget.isPlaying) {
      _controller.play();
    } else {
      _controller.pause();
    }

    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
