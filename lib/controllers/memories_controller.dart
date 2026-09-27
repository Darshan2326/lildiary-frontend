import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lildairy/api/memories_api.dart';
import 'package:lildairy/models/user.dart';
import 'package:lildairy/services/storage_service.dart';
import 'package:lildairy/utils/api_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class MemoriesController extends GetxController {
  final MemoriesApi _memoriesApi = MemoriesApi();

  // ============================================
  // STATE OBSERVABLES
  // ============================================

  final RxList<Memories> memories = <Memories>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;
  final RxString errorMessage = ''.obs;

  // Track currently deleting & sharing memory IDs
  final RxnInt deletingMemoryId = RxnInt(null);
  final RxnInt sharingMemoryId = RxnInt(null);


  // Music Catalog Observables
  final RxList<MusicTrack> musicTracks = <MusicTrack>[].obs;
  final RxString selectedCategory = 'calm'.obs;
  final Rxn<MusicTrack> selectedTrack = Rxn<MusicTrack>();
  final RxBool isLoadingMusic = false.obs;

  // Track Audio Preview Observables (Instagram style)
  VideoPlayerController? _previewPlayer;
  final RxnInt playingTrackId = RxnInt(null);
  final RxBool isPreviewPlaying = false.obs;
  final RxBool isPreviewBuffering = false.obs;

  // Track active periodic polling timers by recap ID
  final Map<int, Timer> _pollingTimers = {};

  @override
  void onInit() {
    super.onInit();
    fetchMemories();
    fetchMusicCatalog();
  }

  Future<void> fetchMusicCatalog({String? category}) async {
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) return;

    try {
      isLoadingMusic.value = true;
      final tracks = await _memoriesApi.getMusicCatalog(
        category: category,
        token: token,
      );
      musicTracks.assignAll(tracks);
    } catch (e) {
      debugPrint('Fetch music catalog error: $e');
    } finally {
      isLoadingMusic.value = false;
    }
  }

  void selectCategory(String category) {
    stopTrackPreview();
    selectedCategory.value = category;
    selectedTrack.value = null;
    fetchMusicCatalog(category: category);
  }

  void selectTrack(MusicTrack? track) {
    selectedTrack.value = track;
    if (track != null) {
      selectedCategory.value = track.category;
    }
  }

  // ============================================
  // TRACK AUDIO PREVIEW ENGINE (INSTAGRAM STYLE)
  // ============================================

  String resolveTrackUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    final url = rawUrl.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final clean = url.startsWith('/') ? url.substring(1) : url;
    return '${ApiConstants.baseUrl}/$clean';
  }

  Future<void> toggleTrackPreview(MusicTrack track) async {
    final trackUrl = resolveTrackUrl(track.fileUrl);
    if (trackUrl.isEmpty) {
      Get.snackbar(
        "Preview Unavailable",
        "No audio sample available for \"${track.title}\"",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // If currently playing or paused on this exact track: toggle play/pause
    if (playingTrackId.value == track.id && _previewPlayer != null) {
      if (_previewPlayer!.value.isPlaying) {
        await _previewPlayer!.pause();
        isPreviewPlaying.value = false;
      } else {
        await _previewPlayer!.play();
        isPreviewPlaying.value = true;
      }
      return;
    }

    // Otherwise, stop previous and start this track
    await stopTrackPreview();

    try {
      playingTrackId.value = track.id;
      isPreviewBuffering.value = true;
      isPreviewPlaying.value = false;

      final uri = Uri.tryParse(trackUrl);
      if (uri == null) throw Exception("Invalid URL: $trackUrl");

      debugPrint('[TRACK PREVIEW] Initializing preview from URL: $trackUrl');
      final controller = VideoPlayerController.networkUrl(uri);
      _previewPlayer = controller;

      await controller.initialize();

      // Ensure another track hasn't been requested in the meantime
      if (playingTrackId.value != track.id) {
        controller.dispose();
        return;
      }

      await controller.setLooping(true);
      await controller.play();

      isPreviewBuffering.value = false;
      isPreviewPlaying.value = true;

      controller.addListener(() {
        if (playingTrackId.value == track.id) {
          isPreviewPlaying.value = controller.value.isPlaying;
          isPreviewBuffering.value = controller.value.isBuffering;
          if (controller.value.hasError) {
            debugPrint(
                '[TRACK PREVIEW ERROR] ${controller.value.errorDescription}');
            stopTrackPreview();
          }
        }
      });
    } catch (e) {
      debugPrint('[TRACK PREVIEW ERROR] $e');
      stopTrackPreview();
      Get.snackbar(
        "Audio Playback",
        "Could not play preview for \"${track.title}\"",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> pauseTrackPreview() async {
    try {
      if (_previewPlayer != null && _previewPlayer!.value.isPlaying) {
        await _previewPlayer!.pause();
        isPreviewPlaying.value = false;
      }
    } catch (e) {
      debugPrint('[TRACK PREVIEW ERROR] Pause error: $e');
    }
  }

  Future<void> stopTrackPreview() async {
    try {
      if (_previewPlayer != null) {
        final player = _previewPlayer!;
        _previewPlayer = null;
        await player.pause();
        await player.dispose();
      }
    } catch (e) {
      debugPrint('[TRACK PREVIEW ERROR] Stop error: $e');
    } finally {
      playingTrackId.value = null;
      isPreviewPlaying.value = false;
      isPreviewBuffering.value = false;
    }
  }

  @override
  void onClose() {
    stopTrackPreview();
    _stopAllPolling();
    super.onClose();
  }

  void _stopAllPolling() {
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();
  }

  void _stopPolling(int recapId) {
    if (_pollingTimers.containsKey(recapId)) {
      _pollingTimers[recapId]?.cancel();
      _pollingTimers.remove(recapId);
      debugPrint('[MEMORIES POLLING] Stopped polling for recap #$recapId');
    }
  }

  // ============================================
  // 1️⃣ FETCH ALL MEMORIES (GET /api/v1/memories)
  // ============================================

  Future<void> fetchMemories() async {
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      errorMessage.value = 'User not logged in';
      memories.clear();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _memoriesApi.getAllMemories(token: token);
      memories.assignAll(result);

      // Check if any returned memories are in 'processing' status and start polling
      for (final item in result) {
        final id = item.recapId ?? item.id;
        final status = (item.status ?? '').toLowerCase();
        if (id != null && (status == 'processing' || status == 'generating')) {
          startPollingRecap(id);
        }
      }
    } catch (e) {
      debugPrint('Memories fetch error: $e');
      final errorStr = e.toString();
      if (errorStr.contains('404') ||
          errorStr.toLowerCase().contains('no memories found')) {
        errorMessage.value = '';
        memories.clear();
      } else {
        errorMessage.value = errorStr;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // 2️⃣ GENERATE CUSTOM MEMORY RECAP
  // (POST /api/v1/memories/recap/generate)
  // ============================================

  Future<void> generateCustomRecap(RecapGenerateRequest request) async {
    stopTrackPreview();
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Authentication Error",
        "User not logged in. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isGenerating.value = true;

      final recap = await _memoriesApi.createRecap(
        token: token,
        request: request,
      );

      final recapId = recap.recapId ?? recap.id;

      // Check if item already exists in list or add it to front
      if (recapId != null) {
        final existingIdx = memories.indexWhere(
            (m) => (m.recapId ?? m.id) == recapId);
        if (existingIdx != -1) {
          memories[existingIdx] = recap;
        } else {
          memories.insert(0, recap);
        }

        // Start polling every 2 seconds
        startPollingRecap(recapId);
      }

      Get.snackbar(
        "Recap Generation Started ✨",
        recap.statusMessage ?? "Creating your memory recap...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF81D4FA).withValues(alpha: 0.95),
        colorText: Colors.black87,
        icon: const Icon(Icons.auto_awesome, color: Colors.amber),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      debugPrint('Generate recap error: $e');
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        "Generation Error",
        cleanMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isGenerating.value = false;
    }
  }

  // ============================================
  // QUICK MEMORY GENERATION (POST /api/v1/memories/generate)
  // ============================================

  Future<void> generateMemory() async {
    await generateCustomRecap(const RecapGenerateRequest());
  }

  // ============================================
  // 3️⃣ REAL-TIME POLLING ENGINE (GET /recap/{id}/status)
  // ============================================

  void startPollingRecap(int recapId) {
    if (_pollingTimers.containsKey(recapId)) {
      debugPrint('[MEMORIES POLLING] Timer already running for recap #$recapId');
      return;
    }

    debugPrint('[MEMORIES POLLING] Starting 2s timer for recap #$recapId');

    // Run first check immediately
    _checkRecapStatus(recapId);

    // Periodic 2-second interval timer
    _pollingTimers[recapId] = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkRecapStatus(recapId),
    );
  }

  Future<void> _checkRecapStatus(int recapId) async {
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      _stopPolling(recapId);
      return;
    }

    try {
      final updated = await _memoriesApi.getRecapStatus(
        recapId: recapId,
        token: token,
      );

      // Find index in reactive list
      final index = memories.indexWhere((m) => (m.recapId ?? m.id) == recapId);
      if (index != -1) {
        memories[index] = updated;
        memories.refresh();
      } else {
        memories.insert(0, updated);
      }

      final status = (updated.status ?? '').toLowerCase();

      // Check if job completed or failed
      if (status == 'ready' || status == 'completed') {
        _stopPolling(recapId);

        Get.snackbar(
          "Recap Ready ❤️",
          updated.statusMessage ?? "Your memory recap is ready!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          duration: const Duration(seconds: 5),
        );
      } else if (status == 'failed') {
        _stopPolling(recapId);

        Get.snackbar(
          "Recap Generation Failed ⚠️",
          updated.errorMessage ??
              updated.statusMessage ??
              "No memories found in selected range",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      debugPrint('Polling error for recap #$recapId: $e');
    }
  }

  // ============================================
  // 4️⃣ FETCH MEMORY BY ID (GET /api/v1/memories/{id})
  // ============================================

  Future<Memories?> fetchMemoryById(int id) async {
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final updated = await _memoriesApi.getMemoryById(
        memoryId: id,
        token: token,
      );

      final index = memories.indexWhere((m) => (m.recapId ?? m.id) == id);
      if (index != -1) {
        memories[index] = updated;
        memories.refresh();
      }

      return updated;
    } catch (e) {
      debugPrint('Error fetching memory #$id: $e');
      return null;
    }
  }

  // ============================================
  // REFRESH
  // ============================================

  Future<void> refreshMemories() async {
    _stopAllPolling();
    await fetchMemories();
  }

  // ============================================
  // 5️⃣ DELETE MEMORY RECAP
  // ============================================

  Future<bool> deleteMemory(dynamic memoryId) async {
    if (memoryId == null) return false;
    final id = memoryId is int ? memoryId : int.tryParse(memoryId.toString());
    if (id == null) return false;

    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Authentication Error",
        "User not logged in. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
      return false;
    }

    try {
      deletingMemoryId.value = id;
      await _memoriesApi.deleteMemory(memoryId: id, token: token);

      // Stop any active polling for this memory
      _stopPolling(id);

      // Remove from reactive list
      memories.removeWhere((m) => (m.recapId ?? m.id) == id);
      memories.refresh();

      Get.snackbar(
        "Memory Deleted",
        "Memory recap was deleted successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade900,
        colorText: Colors.white,
        icon: const Icon(Icons.delete_outline, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
      return true;
    } catch (e) {
      debugPrint('Delete memory error: $e');
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        "Delete Failed",
        cleanMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      deletingMemoryId.value = null;
    }
  }

  // ============================================
  // 6️⃣ SHARE MEMORY RECAP (SOCIAL MEDIA)
  // ============================================

  Future<void> shareMemory(BuildContext context, Memories memory) async {
    final id = memory.recapId ?? memory.id;
    if (id == null) return;

    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Authentication Error",
        "User not logged in. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
      return;
    }

    try {
      sharingMemoryId.value = id;

      // 1. Call backend share API
      String shareUrl = memory.videoUrl ?? '';
      String shareText = 'Check out this memory recap from Lil Diary! 🎥✨';

      try {
        final shareData = await _memoriesApi.getShareInfo(
          memoryId: id,
          token: token,
        );
        if (shareData['share_url'] != null &&
            shareData['share_url'].toString().isNotEmpty) {
          shareUrl = shareData['share_url'].toString();
        }
        if (shareData['share_text'] != null &&
            shareData['share_text'].toString().isNotEmpty) {
          shareText = shareData['share_text'].toString();
        }
      } catch (apiErr) {
        debugPrint('[MEMORIES SHARE API] Notice: $apiErr, using local fallback');
        if (shareUrl.isNotEmpty) {
          shareText =
              'Check out my memory recap: "${memory.title ?? "Memory Recap"}" on Lil Diary! 🎥✨\n$shareUrl';
        }
      }

      // 2. Share video file if available, or fallback to URL share
      final videoTargetUrl =
          shareUrl.isNotEmpty ? shareUrl : (memory.videoUrl ?? '');
      if (videoTargetUrl.isNotEmpty) {
        final resolvedUrl = videoTargetUrl.startsWith('http')
            ? videoTargetUrl
            : '${ApiConstants.baseUrl}/${videoTargetUrl.startsWith('/') ? videoTargetUrl.substring(1) : videoTargetUrl}';

        try {
          final tempDir = await getTemporaryDirectory();
          final sanitizedName = 'memory_recap_$id.mp4';
          final targetFile = File('${tempDir.path}/$sanitizedName');

          if (!await targetFile.exists() || (await targetFile.length()) == 0) {
            final uri = Uri.parse(resolvedUrl);
            final res =
                await http.get(uri).timeout(const Duration(seconds: 40));
            if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
              await targetFile.writeAsBytes(res.bodyBytes);
            }
          }

          if (await targetFile.exists() && (await targetFile.length()) > 0) {
            final xFile = XFile(
              targetFile.path,
              mimeType: 'video/mp4',
              name: sanitizedName,
            );
            await Share.shareXFiles(
              [xFile],
              text: shareText,
              subject: memory.title ?? 'Memory Recap',
            );
            return;
          }
        } catch (downloadErr) {
          debugPrint(
              '[MEMORIES SHARE FILE ERROR] Could not cache video file: $downloadErr');
        }
      }

      // Fallback to text + URL sharing
      await Share.share(
        shareText,
        subject: memory.title ?? 'Memory Recap',
      );
    } catch (e) {
      debugPrint('Share memory error: $e');
      Get.snackbar(
        "Sharing Error",
        "Could not prepare memory recap for sharing.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      sharingMemoryId.value = null;
    }
  }
}