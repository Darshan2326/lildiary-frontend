import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lildairy/widget/smart_media_widget.dart';
import 'package:share_plus/share_plus.dart';

class FullScreenMediaViewer extends StatefulWidget {
  final String? mediaPath;
  final List<dynamic>? mediaList;
  final int initialIndex;

  const FullScreenMediaViewer({
    super.key,
    this.mediaPath,
    this.mediaList,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  late final List<String> _items;
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    if (widget.mediaList != null && widget.mediaList!.isNotEmpty) {
      _items = widget.mediaList!
          .where((m) => m != null)
          .map((m) => m.toString().trim())
          .where((m) => m.isNotEmpty)
          .toList();
    } else if (widget.mediaPath != null && widget.mediaPath!.isNotEmpty) {
      _items = [widget.mediaPath!];
    } else {
      _items = [];
    }

    if (_items.isEmpty) {
      _currentIndex = 0;
    } else {
      _currentIndex = widget.initialIndex.clamp(0, _items.length - 1);
    }

    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _shareCurrentImage() async {
    if (_items.isEmpty) return;
    final currentPath = _items[_currentIndex];
    final resolved = MediaUtils.resolvePath(currentPath);

    try {
      if (!resolved.startsWith('http://') &&
          !resolved.startsWith('https://') &&
          File(resolved).existsSync()) {
        await Share.shareXFiles([XFile(resolved)]);
      } else {
        await Share.share(resolved);
      }
    } catch (e) {
      debugPrint('Error sharing full screen image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: _items.length > 1
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "${_currentIndex + 1} / ${_items.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        centerTitle: true,
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(CupertinoIcons.share, color: Colors.white),
              tooltip: 'Share Image',
              onPressed: _shareCurrentImage,
            ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'No media available',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final itemPath = _items[index];
                    return InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Center(
                        child: SmartMediaWidget(
                          mediaPath: itemPath,
                          fit: BoxFit.contain,
                          isPlaying: _currentIndex == index,
                        ),
                      ),
                    );
                  },
                ),

                // Left Navigation Arrow
                if (_items.length > 1 && _currentIndex > 0)
                  Positioned(
                    left: 12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Right Navigation Arrow
                if (_items.length > 1 && _currentIndex < _items.length - 1)
                  Positioned(
                    right: 12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Bottom thumbnails indicator
                if (_items.length > 1)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_items.length, (i) {
                        final isSelected = _currentIndex == i;
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isSelected ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF48FB1) : Colors.white38,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
    );
  }
}
