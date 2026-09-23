import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lildairy/controllers/lendinghome_controller.dart';
import 'package:lildairy/screens/NoteDetailsScreen.dart';
import 'package:lildairy/widget/smart_media_widget.dart';
import 'package:lottie/lottie.dart';

class lendingHomeScreen extends StatelessWidget {
  final String userId;

  lendingHomeScreen({
    super.key,
    required this.userId,
  });

  final LendingHomeController controller = Get.put(
    LendingHomeController(),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: const [
              Image(
                image: AssetImage(
                  "assets/logos/Logo_png.png",
                ),
              ),
            ],
            toolbarHeight: 100,
            title: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black38,
                    ),
                  ),
                  Text(
                    controller.userName.value.isEmpty
                        ? 'Loading...'
                        : controller.userName.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          child: Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.searchNotes,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                    ),
                    hintText: 'Search Diary...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              // Notes
              Expanded(
                child: Obx(
                  () {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final notes = controller.diaries.where(
                      (diary) {
                        final searchableText =
                            '${diary.title ?? ''} ${diary.description ?? ''}'
                                .toLowerCase();

                        return searchableText.contains(
                          controller.searchQuery.value,
                        );
                      },
                    ).toList();

                    // No search result
                    if (notes.isEmpty &&
                        controller.searchQuery.value.isNotEmpty) {
                      return Column(
                        children: [
                          Center(
                            child: Lottie.asset(
                              'assets/animation/empty.json',
                              width: 250,
                              height: 250,
                            ),
                          ),
                          const Text(
                            "No Memories...",
                          ),
                        ],
                      );
                    }

                    // No notes
                    if (notes.isEmpty) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                      );
                    }

                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final diary = notes[index];
                        final mediaPaths = diary.images ?? <String>[];
                        final noteData = <String, dynamic>{
                          'id': diary.id?.toString(),
                          'title': diary.title,
                          'description': diary.description,
                          'mediaPaths': mediaPaths,
                          'timestamp': diary.createdAt ??
                              DateTime.now().toIso8601String(),
                        };
                        final createdAt = DateTime.tryParse(
                          diary.createdAt ?? '',
                        );
                        final formattedDate = createdAt == null
                            ? 'Date unavailable'
                            : DateFormat('dd MMM, yyyy').format(createdAt);

                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              // Media
                              if (mediaPaths.isNotEmpty)
                                _buildMediaGrid(
                                  mediaPaths,
                                  context,
                                  diary.id.toString(),
                                  noteData,
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

                              // Note information
                              ListTile(
                                title: Text(
                                  diary.title ?? 'No Title',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.calendar,
                                      color: Color(0xFFF48FB1),
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
                                    diary.id.toString(),
                                    noteData,
                                  );
                                },
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

  // Open note details
  void _viewFullNote(
    BuildContext context,
    String noteId,
    Map<String, dynamic> noteData,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(
          noteId: noteId,
          noteData: noteData,
        ),
      ),
    );

    if (result == true) {
      controller.loadUserData();
    }
  }

  // Media grid
  Widget _buildMediaGrid(
    List<String> mediaPaths,
    BuildContext context,
    String noteId,
    Map<String, dynamic> noteData,
  ) {
    final int mediaCount = mediaPaths.length;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mediaCount > 2 ? 2 : mediaCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: mediaCount > 3 ? 4 : mediaCount,
      itemBuilder: (ctx, index) {
        // More overlay
        if (index == 3 && mediaCount > 3) {
          return GestureDetector(
            onTap: () => _viewFullNote(context, noteId, noteData),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SmartMediaWidget(
                  mediaPath: mediaPaths[index],
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Text(
                      'More',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return GestureDetector(
          onTap: () => _viewFullNote(context, noteId, noteData),
          child: SmartMediaWidget(
            mediaPath: mediaPaths[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
