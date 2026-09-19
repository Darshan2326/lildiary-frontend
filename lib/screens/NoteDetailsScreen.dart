import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lildairy/screens/FullScreenMediaViewer.dart';
import 'package:lildairy/widget/smart_media_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'EditNoteScreen.dart';

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

  /// Builds a single media item for the carousel using SmartMediaWidget.
  Widget _buildCarouselItem(
      String rawMediaPath, int index, List<dynamic> mediaPaths) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.hardEdge,
            child: SmartMediaWidget(
              mediaPath: rawMediaPath,
              fit: BoxFit.cover,
              isPlaying: _currentIndex == index,
              onVideoPlayPause: (isPlaying) {
                if (isPlaying) {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
            ),
          ),
        ),
        // Full screen expand icon button on top right of media
        Positioned(
          top: 8,
          right: 12,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FullScreenMediaViewer(mediaPath: rawMediaPath),
                ),
              );
            },
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
                  items: mediaPaths.asMap().entries.map((entry) {
                    final index = entry.key;
                    final mediaPath = entry.value as String;
                    return _buildCarouselItem(mediaPath, index, mediaPaths);
                  }).toList(),
                  options: CarouselOptions(
                    height: 250.0,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: mediaPaths.length > 1,
                    autoPlay: false,
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
                  const SizedBox(width: 10),
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
                      List<dynamic>? paths = widget.noteData['mediaPaths'];

                      String shareMessage = "$title\n\n$description";

                      try {
                        final resolved = paths
                                ?.map((p) => MediaUtils.resolvePath(p.toString()))
                                .toList() ??
                            [];
                        final localFiles = resolved
                            .where((p) =>
                                !p.startsWith('http://') &&
                                !p.startsWith('https://'))
                            .map((p) => XFile(p))
                            .toList();

                        if (localFiles.isNotEmpty) {
                          await Share.shareXFiles(localFiles,
                              text: shareMessage);
                        } else {
                          final urlList = resolved
                              .where((p) =>
                                  p.startsWith('http://') ||
                                  p.startsWith('https://'))
                              .join('\n');
                          await Share.share(urlList.isNotEmpty
                              ? '$shareMessage\n\n$urlList'
                              : shareMessage);
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
                      List<dynamic>? paths = widget.noteData['mediaPaths'];

                      String shareMessage = "$title\n\n$description";

                      try {
                        final resolved = paths
                                ?.map((p) => MediaUtils.resolvePath(p.toString()))
                                .toList() ??
                            [];
                        final localFiles = resolved
                            .where((p) =>
                                !p.startsWith('http://') &&
                                !p.startsWith('https://'))
                            .map((p) => XFile(p))
                            .toList();

                        if (localFiles.isNotEmpty) {
                          await Share.shareXFiles(localFiles,
                              text: shareMessage);
                        } else {
                          final urlList = resolved
                              .where((p) =>
                                  p.startsWith('http://') ||
                                  p.startsWith('https://'))
                              .join('\n');
                          await Share.share(urlList.isNotEmpty
                              ? '$shareMessage\n\n$urlList'
                              : shareMessage);
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
