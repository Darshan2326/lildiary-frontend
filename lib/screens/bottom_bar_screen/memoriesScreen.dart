import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lildairy/screens/NoteDetailsScreen.dart';
import 'package:video_player/video_player.dart';

class Memoriesscreen extends StatefulWidget {
  const Memoriesscreen({super.key});

  @override
  State<Memoriesscreen> createState() => _MemoriesscreenState();
}

class _MemoriesscreenState extends State<Memoriesscreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Memories",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB4DCF1), Colors.white, Color(0xFFF1C6D4)])),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.value(const <Map<String, dynamic>>[]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final notes = snapshot.data!;

            if (notes.isEmpty) {
              // Show message when there are no notes
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      'No Memories...',
                      style: TextStyle(fontSize: 20, color: Colors.black54),
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
                    ? List<String>.from(noteData['mediaPaths'] as List<dynamic>)
                    : [];

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
                      // If mediaPaths is not empty, show the media; otherwise, show "No Media"
                      if (mediaPaths.isNotEmpty)
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: mediaPaths[0].endsWith('.mp4')
                              ? VideoPlayerWidget(
                                  mediaFile: File(mediaPaths[0]))
                              : Image.file(
                                  File(mediaPaths[0]),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey,
                                      child: const Center(
                                          child: Text('Invalid Image')),
                                    );
                                  },
                                ),
                        )
                      else
                        Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[
                              200], // You can choose any color for the empty state
                          child: const Center(
                            child: Text(
                              'No Media',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black54),
                            ),
                          ),
                        ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                noteData?['title'] ?? 'No Title',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _viewFullNote(
                                  noteData['id'] as String, noteData),
                              child: const Text(
                                "View Details",
                                style: TextStyle(
                                    color: Color(0xFF81D4FA),
                                    backgroundColor: Color(0xFFE1F5FE)),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(CupertinoIcons.calendar,
                                color: Color(0xFFF48FB1), size: 20),
                            const SizedBox(width: 5),
                            Text(formattedDate),
                          ],
                        ),
                        onTap: () =>
                            _viewFullNote(noteData['id'] as String, noteData),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final File mediaFile;
  const VideoPlayerWidget({super.key, required this.mediaFile});

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
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
