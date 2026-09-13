import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lildairy/screens/NoteDetailsScreen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:video_player/video_player.dart';
// import 'NoteDetailsScreen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _memoriesForSelectedDate = [];

  @override
  void initState() {
    super.initState();
    _fetchMemoriesForDate(_selectedDate);
  }

  Future<void> _fetchMemoriesForDate(DateTime date) async {
    if (!mounted) return;

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    try {
      setState(() {
        _memoriesForSelectedDate = [];
      });
    } catch (e) {
      debugPrint('Calendar fetch error: $e');
      if (!mounted) return;
      setState(() {
        _memoriesForSelectedDate = [];
      });
    }
  }

  void _onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
    });
    _fetchMemoriesForDate(selectedDay);
  }

  void _viewFullNote(String noteId, Map<String, dynamic> noteData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NoteDetailScreen(noteId: noteId, noteData: noteData),
      ),
    );
  }

  // Function to check if a file is an image
  bool _isImage(String path) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    final extension = path.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  // Widget to display media (image or video)
  Widget _buildMediaPreview(String path) {
    if (_isImage(path)) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey,
            child: const Center(child: Text('Invalid Image')),
          );
        },
      );
    } else {
      return VideoPreview(path: path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calendar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB4DCF1), Colors.white, Color(0xFFF1C6D4)])),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Card(
                elevation: 5,
                child: TableCalendar(
                  focusedDay: _selectedDate,
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                  onDaySelected: _onDateSelected,
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF81D4FA),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.grey, // Color for the current day
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: Colors.white, // Text color for selected date
                      fontWeight: FontWeight.bold,
                    ),
                    todayTextStyle: TextStyle(
                      color: Colors.white, // Text color for today
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _memoriesForSelectedDate.isNotEmpty
                  ? ListView.builder(
                      itemCount: _memoriesForSelectedDate.length,
                      itemBuilder: (context, index) {
                        final memory = _memoriesForSelectedDate[index];
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
                              vertical: 8, horizontal: 12),
                          child: ListTile(
                            title: Text(title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(description),
                                const SizedBox(height: 8),
                                if (mediaPaths.isNotEmpty)
                                  SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: mediaPaths.length,
                                      itemBuilder: (context, index) {
                                        final mediaPath = mediaPaths[index];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4.0),
                                          child: SizedBox(
                                            width: 150,
                                            child:
                                                _buildMediaPreview(mediaPath),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () => _viewFullNote(noteId, noteData),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('No memories for this date'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Video Preview Widget
class VideoPreview extends StatefulWidget {
  final String path;

  const VideoPreview({super.key, required this.path});

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
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
