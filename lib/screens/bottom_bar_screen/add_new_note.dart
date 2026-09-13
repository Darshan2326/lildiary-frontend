import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lildairy/widget/button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:video_player/video_player.dart';

class addNewNote extends StatefulWidget {
  const addNewNote({super.key});

  @override
  State<addNewNote> createState() => _addNewNoteState();
}

class _addNewNoteState extends State<addNewNote> {
  final TextEditingController noteController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  final double _progress = 0;
  final List<Map<String, dynamic>> _selectedMedia = [];

  Future<void> saveNote() async {
    if (noteController.text.isEmpty || descriptionController.text.isEmpty)
      return;

    noteController.clear();
    descriptionController.clear();
    setState(() {
      _selectedMedia.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Memories added")),
    );
  }

  // Load image from local storage
  Future<void> _pickMedia() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          if (file.path != null) {
            final fileExtension = file.extension?.toLowerCase();
            bool isVideo = fileExtension == 'mp4' ||
                fileExtension == 'mov' ||
                fileExtension == 'avi';
            setState(() {
              _selectedMedia
                  .add({'file': File(file.path!), 'isVideo': isVideo});
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick files: $e")),
      );
      // print("Failed to pick files: $e");
    }
  }

  // Function to remove selected image
  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Diary",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Title",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 25),
                child: TextField(
                  style: const TextStyle(fontSize: 20),
                  controller: noteController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(CupertinoIcons.paperclip,
                        color: Color(0xFFF48FB1)),
                    hintText: "Enter Title",
                    hintStyle:
                        const TextStyle(color: Colors.black38, fontSize: 18),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black54, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFedf0f8),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  // obscureText: isPass,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Description",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: TextField(
                  style: const TextStyle(fontSize: 20),
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(CupertinoIcons.news,
                        color: Color(0xFFF48FB1)),
                    hintText: "Enter Description",
                    hintStyle:
                        const TextStyle(color: Colors.black38, fontSize: 18),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black54, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFedf0f8),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  // obscureText: isPass,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Color(0xFF4FC3F7)),
                    )),
                  ),
                  // onPressed: (){},
                  onPressed: _pickMedia,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.asset(
                          "assets/logos/plus.png",
                          height: 35,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Add Pictures or Videos",
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Display selected images with the option to remove
              SizedBox(
                height: 250,
                width: double.infinity,
                child: _selectedMedia.isNotEmpty
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedMedia.length,
                        itemBuilder: (context, index) {
                          final media = _selectedMedia[index];
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(8),
                                width: 200,
                                height: 200,
                                child: media['isVideo']
                                    ? VideoPlayerWidget(
                                        mediaFile: media['file'])
                                    : Image.file(media['file'],
                                        fit: BoxFit.cover),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                // child: Consumer<test_provider>(builder: (context, provider, child){
                                //   return IconButton(onPressed: (){
                                //     print("Remove button press");
                                //     provider.
                                //   }, icon: Icon(Icons.remove_circle,color: Colors.red,));
                                // }),
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () => _removeMedia(index),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : const Center(child: Text("No Media Selected")),
              ),

              MyButtons(onTap: () => saveNote(), text: "Add Memories"),
            ],
          ),
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
