import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lildairy/controllers/memories_controller.dart';
import 'package:lildairy/screens/NoteDetailsScreen.dart';
import 'package:lildairy/widget/smart_media_widget.dart';

class Memoriesscreen extends StatelessWidget {
  const Memoriesscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MemoriesController controller =
        Get.put(MemoriesController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Memories",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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

        child: Obx(
          () {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.memories.isEmpty) {
              return RefreshIndicator(
                onRefresh: controller.refreshMemories,
                child: ListView(
                  children: const [
                    SizedBox(
                      height: 300,
                    ),
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
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshMemories,
              child: ListView.builder(
                itemCount: controller.memories.length,
                itemBuilder: (context, index) {
                  final noteData = controller.memories[index];

                  final mediaPaths = noteData.containsKey('mediaPaths')
                      ? List<String>.from(
                          noteData['mediaPaths'] as List<dynamic>,
                        )
                      : <String>[];

                  final formattedDate = DateFormat(
                    'dd MMM, yyyy',
                  ).format(
                    DateTime.parse(
                      noteData['timestamp'] as String,
                    ),
                  );

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                    ),
                    child: Column(
                      children: [
                        if (mediaPaths.isNotEmpty)
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: SmartMediaWidget(
                              mediaPath: mediaPaths[0],
                              fit: BoxFit.cover,
                            ),
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

                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  noteData['title'] ?? 'No Title',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _viewFullNote(
                                    context,
                                    noteData['id'] as String,
                                    noteData,
                                  );
                                },
                                child: const Text(
                                  "View Details",
                                  style: TextStyle(
                                    color: Color(
                                      0xFF81D4FA,
                                    ),
                                    backgroundColor: Color(
                                      0xFFE1F5FE,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.calendar,
                                color: Color(
                                  0xFFF48FB1,
                                ),
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
                              noteData['id'] as String,
                              noteData,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

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
}