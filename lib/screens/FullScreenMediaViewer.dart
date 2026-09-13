import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenMediaViewer extends StatelessWidget {
  final String mediaPath;

  const FullScreenMediaViewer({super.key, required this.mediaPath});

  bool _isImage(String path) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    final extension = path.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _isImage(mediaPath)
            ? Image.file(
          File(mediaPath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                'Invalid Image',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        )
            : VideoPlayerFullScreen(mediaPath: mediaPath),
      ),
    );
  }
}

class VideoPlayerFullScreen extends StatefulWidget {
  final String mediaPath;

  const VideoPlayerFullScreen({super.key, required this.mediaPath});

  @override
  _VideoPlayerFullScreenState createState() => _VideoPlayerFullScreenState();
}

class _VideoPlayerFullScreenState extends State<VideoPlayerFullScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.mediaPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
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
