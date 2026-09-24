import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/api/memories_api.dart';
import 'package:lildairy/models/user.dart';
import 'package:lildairy/services/storage_service.dart';

class MemoriesController extends GetxController {
  final MemoriesApi _memoriesApi = MemoriesApi();

  // ============================================
  // STATE OBSERVABLES
  // ============================================

  final RxList<Memories> memories = <Memories>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;
  final RxString errorMessage = ''.obs;

  // Music Catalog Observables
  final RxList<MusicTrack> musicTracks = <MusicTrack>[].obs;
  final RxString selectedCategory = 'calm'.obs;
  final Rxn<MusicTrack> selectedTrack = Rxn<MusicTrack>();
  final RxBool isLoadingMusic = false.obs;

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

  @override
  void onClose() {
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
}