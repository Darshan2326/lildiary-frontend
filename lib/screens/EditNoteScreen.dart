// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:lildairy/widget/button.dart';
// import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
//
// class EditNoteScreen extends StatefulWidget {
//   final String noteId;
//   final Map<String, dynamic> noteData;
//   // final PersistentTabController tabController; // Add this line
//
//
//   const EditNoteScreen({
//     super.key,
//     required this.noteId,
//     required this.noteData,
//     // required this.tabController, // And this
//
//   });
//
//   @override
//   _EditNoteScreenState createState() => _EditNoteScreenState();
// }
//
// class _EditNoteScreenState extends State<EditNoteScreen> {
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   List<File> _selectedImages = [];
//   final ImagePicker _picker = ImagePicker();
//   final PersistentTabController _controller =
//   PersistentTabController(initialIndex: 0);
//
//   @override
//   void initState() {
//     super.initState();
//     titleController.text = widget.noteData['title'] ?? '';
//     descriptionController.text = widget.noteData['description'] ?? '';
//     if (widget.noteData['imagePaths'] != null) {
//       _selectedImages = (widget.noteData['imagePaths'] as List<dynamic>)
//           .map((path) => File(path))
//           .toList();
//     }
//   }
//
//   // Function to pick images
//   Future<void> _pickImage() async {
//     final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedImage != null) {
//       setState(() {
//         _selectedImages.add(File(pickedImage.path));
//       });
//     }
//   }
//
//   // Function to save edited note
//   // Function to save edited note
//   Future<void> _saveEditedNote() async {
//     List<String> imagePaths = [];
//     if (_selectedImages.isNotEmpty) {
//       for (File image in _selectedImages) {
//         final savedImage = await image.copy(
//             '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_${image.hashCode}.png');
//         imagePaths.add(savedImage.path);
//       }
//     }
//
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Note updated successfully!')),
//     );
//
//     // Use tabController to switch to the Memories tab (assuming it's at index 3)
//     // widget.tabController.jumpToTab(3); // Adjust index based on your tab layout
//
//     // Optionally, pop the current screen if needed
//     Navigator.pop(context);
//     print("note upldated");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Note updated successfully!')),
//     );
//   }
//
//
//   // Function to remove a selected image
//   void _removeImage(int index) {
//     setState(() {
//       _selectedImages.removeAt(index);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Note'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 15.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Title",
//                       style:
//                       TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 25),
//                 child: TextField(
//                   style: const TextStyle(fontSize: 20),
//                   controller: titleController,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(CupertinoIcons.paperclip,
//                         color: Color(0xFFF48FB1)),
//                     hintText: "Enter Title",
//                     hintStyle:
//                     const TextStyle(color: Colors.black38, fontSize: 18),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     border: InputBorder.none,
//                     focusedBorder: OutlineInputBorder(
//                       borderSide:
//                       const BorderSide(color: Colors.black54, width: 1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                     fillColor: const Color(0xFFedf0f8),
//                     contentPadding: const EdgeInsets.symmetric(
//                       vertical: 15,
//                       horizontal: 20,
//                     ),
//                   ),
//                   keyboardType: TextInputType.text,
//                   // obscureText: isPass,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 15.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Description",
//                       style:
//                       TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
//                 child: TextField(
//                   style: const TextStyle(fontSize: 20),
//                   controller: descriptionController,
//                   maxLines: 4,
//                   decoration: InputDecoration(
//                     prefixIcon:
//                     Icon(CupertinoIcons.news, color: Color(0xFFF48FB1)),
//                     hintText: "Enter Description",
//                     hintStyle:
//                     const TextStyle(color: Colors.black38, fontSize: 18),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     border: InputBorder.none,
//                     focusedBorder: OutlineInputBorder(
//                       borderSide:
//                       const BorderSide(color: Colors.black54, width: 1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                     fillColor: const Color(0xFFedf0f8),
//                     contentPadding: const EdgeInsets.symmetric(
//                       vertical: 15,
//                       horizontal: 20,
//                     ),
//                   ),
//                   keyboardType: TextInputType.text,
//                   // obscureText: isPass,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: ElevatedButton(
//                   style: ButtonStyle(
//                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                           side: BorderSide(color: Color(0xFF4FC3F7)),
//
//                         )
//                     ),
//                   ),
//                   // onPressed: (){},
//                   onPressed: _pickImage,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                         child: Image.asset(
//                           "assets/logos/plus.png",
//                           height: 35,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       const Text(
//                         "Add Pictures or Videos",
//                         style: TextStyle(
//                           // fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                           color: Colors.black87,
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               Container(
//                 // color: Colors.black12,
//                 height: 250,
//                 width: double.infinity,
//                 child:Center(
//                   child: SingleChildScrollView(
//                     child: _selectedImages.isNotEmpty
//                         ? Wrap(
//                       children: _selectedImages.map((image) {
//                         int index = _selectedImages.indexOf(image);
//                         return Stack(
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.all(8),
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 image: DecorationImage(
//                                   image: FileImage(image),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               right: 0,
//                               top: 0,
//                               child: IconButton(
//                                 icon: Icon(Icons.remove_circle,
//                                     color: Colors.red),
//                                 onPressed: () => _removeImage(index),
//                               ),
//                             )
//                           ],
//                         );
//                       }).toList(),
//                     )
//                         : const Text('No Images Selected'),
//                   ),
//                 ),
//               ),
//
//
//               // if (_selectedImages.isNotEmpty)
//               //   SizedBox(
//               //     height: 100,
//               //     child: ListView.builder(
//               //       scrollDirection: Axis.horizontal,
//               //       itemCount: _selectedImages.length,
//               //       itemBuilder: (context, index) {
//               //         return Stack(
//               //           children: [
//               //             Image.file(_selectedImages[index]),
//               //             Positioned(
//               //               right: 0,
//               //               top: 0,
//               //               child: IconButton(
//               //                 icon: const Icon(Icons.remove_circle, color: Colors.red),
//               //                 onPressed: () => _removeImage(index),
//               //               ),
//               //             ),
//               //           ],
//               //         );
//               //       },
//               //     ),
//               //   ),
//               MyButtons(onTap: _saveEditedNote, text: "Save Chages"),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart'; // For video handling

class EditNoteScreen extends StatefulWidget {
  final String noteId;
  final Map<String, dynamic> noteData;

  const EditNoteScreen({
    super.key,
    required this.noteId,
    required this.noteData,
  });

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<File> _selectedMedia = []; // List to hold both images and videos
  final ImagePicker _picker = ImagePicker();
  final List<VideoPlayerController> _videoControllers =
      []; // List for video controllers

  @override
  void initState() {
    super.initState();
    titleController.text = widget.noteData['title'] ?? '';
    descriptionController.text = widget.noteData['description'] ?? '';
    if (widget.noteData['mediaPaths'] != null) {
      _selectedMedia = (widget.noteData['mediaPaths'] as List<dynamic>)
          .map((path) => File(path))
          .toList();
      _initializeVideos(); // Initialize video controllers if any
    }
  }

  // Function to initialize video controllers
  Future<void> _initializeVideos() async {
    _videoControllers.clear(); // Clear old controllers before adding new ones
    for (var media in _selectedMedia) {
      if (media.path.endsWith('.mp4')) {
        final controller = VideoPlayerController.file(media);
        await controller
            .initialize(); // Ensure video is initialized before adding it
        _videoControllers.add(controller);
        setState(() {}); // Update the UI after video is initialized
      }
    }
  }

  // Function to pick media (images or videos)
  Future<void> _pickMedia() async {
    final pickedMedia = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedMedia != null) {
      setState(() {
        _selectedMedia.add(File(pickedMedia.path));
      });
    } else {
      final pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);
      if (pickedVideo != null) {
        setState(() {
          _selectedMedia.add(File(pickedVideo.path));
          _initializeVideos(); // Reinitialize video controllers after selecting a new video
        });
      }
    }
  }

  Future<void> _saveEditedNote() async {
    // Debugging prints
    print(
        'Saving note: ${titleController.text}, ${descriptionController.text}');

    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      print('Title or Description is empty');
      return; // Avoid saving if any required fields are empty
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Note changes are ready for API integration.')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Dispose of each video controller to free up resources
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose(); // Always call the superclass's dispose method
  }

  // Function to remove a selected media (image/video)
  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
      if (_videoControllers.isNotEmpty) {
        _videoControllers[index].dispose(); // Dispose video controller
        _videoControllers.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
                  controller: titleController,
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
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
                        style: TextStyle(fontSize: 20, color: Colors.black87),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 250,
                width: double.infinity,
                child: Center(
                  child: SingleChildScrollView(
                    child: _selectedMedia.isNotEmpty
                        ? Wrap(
                            children: _selectedMedia
                                .asMap()
                                .map((index, media) {
                                  if (media.path.endsWith('.mp4')) {
                                    // If it's a video
                                    return MapEntry(
                                      index,
                                      Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.all(8),
                                            width: 100,
                                            height: 100,
                                            child: _videoControllers.length >
                                                    index
                                                ? VideoPlayer(
                                                    _videoControllers[index])
                                                : Container(), // Ensure safe access to the controller
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  _removeMedia(index),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  } else {
                                    // If it's an image
                                    return MapEntry(
                                      index,
                                      Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.all(8),
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: FileImage(media),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  _removeMedia(index),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                })
                                .values
                                .toList(),
                          )
                        : const Text(
                            "No media selected",
                            style: TextStyle(color: Colors.black),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81D4FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  // child :Text("save Changes"),
                  onPressed: _saveEditedNote,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
