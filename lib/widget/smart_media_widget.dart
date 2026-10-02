import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lildairy/utils/api_constants.dart';
import 'package:video_player/video_player.dart';

enum SmartMediaType { image, video }

class MediaUtils {
  static final Map<String, SmartMediaType> _typeCache = {};

  /// Resolves raw path to full absolute URL if relative, or returns local file path.
  static String resolvePath(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    // Check if it's an existing file on device filesystem
    try {
      if (File(trimmed).existsSync()) {
        return trimmed;
      }
    } catch (_) {}

    // Treat as server relative path
    final clean = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return '${ApiConstants.baseUrl}/$clean';
  }

  /// Synchronously detects whether media is likely image or video without blocking.
  static SmartMediaType? quickDetectMediaType(String rawPath) {
    final path = resolvePath(rawPath);
    if (_typeCache.containsKey(path)) {
      return _typeCache[path];
    }

    final cleanPath = path.toLowerCase().split('?').first.split('#').first;

    // Check file extension for video
    if (cleanPath.endsWith('.mp4') ||
        cleanPath.endsWith('.mov') ||
        cleanPath.endsWith('.m4v') ||
        cleanPath.endsWith('.webm') ||
        cleanPath.endsWith('.mkv') ||
        cleanPath.endsWith('.avi') ||
        cleanPath.endsWith('.3gp') ||
        cleanPath.endsWith('.flv') ||
        (cleanPath.contains('/memories/') && !cleanPath.contains('thumb'))) {
      _typeCache[path] = SmartMediaType.video;
      return SmartMediaType.video;
    }

    // Check file extension or diary path for image
    if (cleanPath.endsWith('.jpg') ||
        cleanPath.endsWith('.jpeg') ||
        cleanPath.endsWith('.png') ||
        cleanPath.endsWith('.webp') ||
        cleanPath.endsWith('.gif') ||
        cleanPath.endsWith('.bmp') ||
        cleanPath.endsWith('.heic') ||
        cleanPath.endsWith('.heif') ||
        cleanPath.contains('/diaries/') ||
        cleanPath.contains('image') ||
        cleanPath.contains('thumb') ||
        cleanPath.contains('photo')) {
      _typeCache[path] = SmartMediaType.image;
      return SmartMediaType.image;
    }

    // Default to image for network URLs since the vast majority of media are images,
    // and Image.network will handle decoding natively.
    if (path.startsWith('http://') || path.startsWith('https://')) {
      _typeCache[path] = SmartMediaType.image;
      return SmartMediaType.image;
    }

    return null;
  }

  /// Detects whether media at path/URL is video or image.
  static Future<SmartMediaType> detectMediaType(String rawPath) async {
    final quick = quickDetectMediaType(rawPath);
    if (quick != null) return quick;

    final path = resolvePath(rawPath);
    if (_typeCache.containsKey(path)) {
      return _typeCache[path]!;
    }

    // For URLs without clear indicators
    if (path.startsWith('http://') || path.startsWith('https://')) {
      try {
        final response = await http.head(Uri.parse(path)).timeout(
          const Duration(seconds: 2),
        );
        final contentType = (response.headers['content-type'] ?? '').toLowerCase();
        if (contentType.startsWith('video/')) {
          _typeCache[path] = SmartMediaType.video;
          return SmartMediaType.video;
        } else if (contentType.startsWith('image/')) {
          _typeCache[path] = SmartMediaType.image;
          return SmartMediaType.image;
        }
      } catch (_) {}
    }

    // Default fallback
    _typeCache[path] = SmartMediaType.image;
    return SmartMediaType.image;
  }
}

// ============================================================
// SMART MEDIA WIDGET
// Automatically handles images and videos (both local & network)
// ============================================================

class SmartMediaWidget extends StatefulWidget {
  final String mediaPath;
  final BoxFit fit;
  final bool isPlaying;
  final Function(bool)? onVideoPlayPause;

  const SmartMediaWidget({
    super.key,
    required this.mediaPath,
    this.fit = BoxFit.cover,
    this.isPlaying = false,
    this.onVideoPlayPause,
  });

  @override
  State<SmartMediaWidget> createState() => _SmartMediaWidgetState();
}

class _SmartMediaWidgetState extends State<SmartMediaWidget> {
  SmartMediaType? _detectedType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final quick = MediaUtils.quickDetectMediaType(widget.mediaPath);
    if (quick != null) {
      _detectedType = quick;
      _isLoading = false;
    } else {
      _detect();
    }
  }

  @override
  void didUpdateWidget(covariant SmartMediaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaPath != widget.mediaPath) {
      final quick = MediaUtils.quickDetectMediaType(widget.mediaPath);
      if (quick != null) {
        setState(() {
          _detectedType = quick;
          _isLoading = false;
        });
      } else {
        _detect();
      }
    }
  }

  Future<void> _detect() async {
    final type = await MediaUtils.detectMediaType(widget.mediaPath);
    if (mounted) {
      setState(() {
        _detectedType = type;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final resolvedPath = MediaUtils.resolvePath(widget.mediaPath);
    final isNetwork = resolvedPath.startsWith('http://') || resolvedPath.startsWith('https://');

    if (_detectedType == SmartMediaType.video) {
      if (isNetwork) {
        return NetworkVideoPlayerWidget(
          url: resolvedPath,
          isPlaying: widget.isPlaying,
          onVideoPlayPause: widget.onVideoPlayPause,
        );
      } else {
        return VideoPlayerWidget(
          mediaFile: File(resolvedPath),
          isPlaying: widget.isPlaying,
          onVideoPlayPause: widget.onVideoPlayPause,
        );
      }
    } else {
      if (isNetwork) {
        return Image.network(
          resolvedPath,
          fit: widget.fit,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey,
            child: const Center(child: Text('Invalid Image')),
          ),
        );
      } else {
        return Image.file(
          File(resolvedPath),
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey,
            child: const Center(child: Text('Invalid Image')),
          ),
        );
      }
    }
  }
}

// ============================================================
// LOCAL VIDEO PLAYER WIDGET
// ============================================================

class VideoPlayerWidget extends StatefulWidget {
  final File mediaFile;
  final bool isPlaying;
  final Function(bool)? onVideoPlayPause;

  const VideoPlayerWidget({
    super.key,
    required this.mediaFile,
    required this.isPlaying,
    this.onVideoPlayPause,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    try {
      _controller = VideoPlayerController.file(widget.mediaFile)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            if (widget.isPlaying) {
              _controller.play();
            }
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        });
    } catch (e) {
      _hasError = true;
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.value.isInitialized) {
      if (widget.isPlaying && !_controller.value.isPlaying) {
        _controller.play();
      } else if (!widget.isPlaying && _controller.value.isPlaying) {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isInitialized) {
      setState(() {
        if (_controller.value.isPlaying) {
          _controller.pause();
          widget.onVideoPlayPause?.call(false);
        } else {
          _controller.play();
          widget.onVideoPlayPause?.call(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Text(
            'Failed to load video',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
            Container(
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// NETWORK VIDEO PLAYER WIDGET
// ============================================================

class NetworkVideoPlayerWidget extends StatefulWidget {
  final String url;
  final bool isPlaying;
  final Function(bool)? onVideoPlayPause;

  const NetworkVideoPlayerWidget({
    super.key,
    required this.url,
    required this.isPlaying,
    this.onVideoPlayPause,
  });

  @override
  State<NetworkVideoPlayerWidget> createState() =>
      _NetworkVideoPlayerWidgetState();
}

class _NetworkVideoPlayerWidgetState extends State<NetworkVideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    try {
      final resolved = MediaUtils.resolvePath(widget.url);
      final uri = Uri.tryParse(resolved);
      if (uri == null || !uri.hasScheme) {
        debugPrint('[NETWORK VIDEO WARNING] Invalid video URI: $resolved');
        if (mounted) setState(() => _hasError = true);
        return;
      }

      _controller = VideoPlayerController.networkUrl(uri)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            if (widget.isPlaying) {
              _controller.play();
            }
          }
        }).catchError((error) {
          debugPrint('[NETWORK VIDEO ERROR] $error');
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        });
    } catch (e) {
      debugPrint('[NETWORK VIDEO INIT ERROR] $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant NetworkVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      try {
        _controller.dispose();
      } catch (_) {}
      _hasError = false;
      _initController();
    } else if (!_hasError && _controller.value.isInitialized) {
      if (widget.isPlaying && !_controller.value.isPlaying) {
        _controller.play();
      } else if (!widget.isPlaying && _controller.value.isPlaying) {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isInitialized) {
      setState(() {
        if (_controller.value.isPlaying) {
          _controller.pause();
          widget.onVideoPlayPause?.call(false);
        } else {
          _controller.play();
          widget.onVideoPlayPause?.call(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
              SizedBox(height: 8),
              Text(
                'Video failed to load',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
            Container(
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
        ],
      ),
    );
  }
}
