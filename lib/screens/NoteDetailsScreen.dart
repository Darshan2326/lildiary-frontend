import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/note_details_controller.dart';
import 'package:lildairy/widget/smart_media_widget.dart';

class NoteDetailScreen extends StatefulWidget {
  final String noteId;
  final Map<String, dynamic> noteData;
  final int initialIndex;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
    required this.noteData,
    this.initialIndex = 0,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final String _tag;
  late final NoteDetailsController _controller;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _tag = widget.noteId.isNotEmpty && widget.noteId != 'null'
        ? widget.noteId
        : UniqueKey().toString();

    _controller = Get.put(
      NoteDetailsController(
        noteId: widget.noteId,
        initialNoteData: widget.noteData,
      ),
      tag: _tag,
    );

    // Sync note data immediately in case controller is reused
    _controller.updateNoteData(widget.noteData);

    if (widget.initialIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.setInitialIndex(widget.initialIndex);
        if (_controller.mediaPaths.length > widget.initialIndex) {
          _carouselController.jumpToPage(widget.initialIndex);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant NoteDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.noteData != widget.noteData) {
      _controller.updateNoteData(widget.noteData);
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<NoteDetailsController>(tag: _tag)) {
      Get.delete<NoteDetailsController>(tag: _tag);
    }
    super.dispose();
  }

  /// Builds a single media item for the carousel using SmartMediaWidget.
  Widget _buildCarouselItem(
    BuildContext context,
    String rawMediaPath,
    int index,
    int totalCount,
  ) {
    return GestureDetector(
      onTap: () => _controller.openFullScreen(
        context,
        rawMediaPath,
        initialIndex: index,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Obx(
              () => SmartMediaWidget(
                mediaPath: rawMediaPath,
                fit: BoxFit.cover,
                isPlaying: _controller.currentIndex.value == index,
                onVideoPlayPause: (isPlaying) {
                  _controller.onVideoPlayPause(isPlaying, index);
                },
              ),
            ),

            // Top-left Counter Badge (e.g. "1 / 4")
            if (totalCount > 1)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${index + 1} / $totalCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Full screen expand icon button on top right of media
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _controller.openFullScreen(
                  context,
                  rawMediaPath,
                  initialIndex: index,
                ),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              // Media Carousel, Dots Indicator, and Thumbnail Strip
              Obx(() {
                final mediaPaths = _controller.mediaPaths;
                if (mediaPaths.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Carousel Slider Stack with Navigation Arrows
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CarouselSlider(
                            carouselController: _carouselController,
                            items: mediaPaths.asMap().entries.map((entry) {
                              final index = entry.key;
                              final mediaPath = entry.value;
                              return _buildCarouselItem(
                                context,
                                mediaPath,
                                index,
                                mediaPaths.length,
                              );
                            }).toList(),
                            options: CarouselOptions(
                              height: 260.0,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              enableInfiniteScroll: mediaPaths.length > 1,
                              autoPlay: false,
                              initialPage: widget.initialIndex
                                  .clamp(0, mediaPaths.length - 1),
                              onPageChanged: (index, reason) {
                                _controller.onPageChanged(index);
                              },
                            ),
                          ),

                          // Previous Arrow Button (Left)
                          if (mediaPaths.length > 1)
                            Positioned(
                              left: 8,
                              child: GestureDetector(
                                onTap: () {
                                  _carouselController.previousPage(
                                    duration:
                                        const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.black.withValues(alpha: 0.45),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_left_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),

                          // Next Arrow Button (Right)
                          if (mediaPaths.length > 1)
                            Positioned(
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  _carouselController.nextPage(
                                    duration:
                                        const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.black.withValues(alpha: 0.45),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Animated Dots Indicator
                      if (mediaPaths.length > 1) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(mediaPaths.length, (i) {
                            final isSelected =
                                _controller.currentIndex.value == i;
                            return GestureDetector(
                              onTap: () {
                                _carouselController.animateToPage(
                                  i,
                                  duration:
                                      const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: isSelected ? 22 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFF48FB1)
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],

                      // Horizontal Thumbnails Preview Strip
                      if (mediaPaths.length > 1) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 60,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            itemCount: mediaPaths.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final isSelected =
                                  _controller.currentIndex.value == i;
                              final thumbPath = mediaPaths[i];
                              return GestureDetector(
                                onTap: () {
                                  _controller.onPageChanged(i);
                                  _carouselController.animateToPage(
                                    i,
                                    duration:
                                        const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFF48FB1)
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2.5 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFF48FB1)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Opacity(
                                    opacity: isSelected ? 1.0 : 0.65,
                                    child: SmartMediaWidget(
                                      mediaPath: thumbPath,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  );
                } else {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            const Color(0xFFF48FB1).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 46,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No photos attached to this memory',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }),

              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.calendar,
                    color: Color(0xFFF48FB1),
                  ),
                  const SizedBox(width: 10),
                  Obx(
                    () => Text(
                      _controller.formattedDate,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => Text(
                        _controller.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.printer_fill,
                      color: Color(0xFFF48FB1),
                    ),
                    onPressed: _controller.shareNote,
                  ),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.share_up,
                      color: Color(0xFF81D4FA),
                    ),
                    onPressed: _controller.shareNote,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                  ),
                  const Icon(Icons.access_time, color: Color(0xFF81D4FA)),
                  const SizedBox(width: 8),
                  Obx(
                    () => Text(
                      _controller.formattedTime,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 245,
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Obx(
                    () => Text(
                      _controller.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _controller.openEditNote(context),
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
                  Obx(() {
                    if (_controller.isDeleting.value) {
                      return const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF81D4FA),
                          ),
                        ),
                      );
                    }
                    return IconButton(
                      onPressed: () => _controller.confirmAndDelete(context),
                      icon: const Icon(CupertinoIcons.delete),
                      color: const Color(0xFF81D4FA),
                      tooltip: 'Delete Note',
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Alias for convenience / consistency
typedef NoteDetailsScreen = NoteDetailScreen;
