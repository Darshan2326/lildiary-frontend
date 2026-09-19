import 'package:flutter/material.dart';
import 'package:lildairy/widget/smart_media_widget.dart';

class FullScreenMediaViewer extends StatelessWidget {
  final String mediaPath;

  const FullScreenMediaViewer({super.key, required this.mediaPath});

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
        child: SmartMediaWidget(
          mediaPath: mediaPath,
          fit: BoxFit.contain,
          isPlaying: true,
        ),
      ),
    );
  }
}
