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

  @override
  void onInit() {
    super.onInit();
    fetchMemories();
  }

  // ============================================
  // FETCH ALL MEMORIES (GET /memories)
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
  // GENERATE MEMORY VIDEO (POST /memories/generate)
  // ============================================

  Future<void> generateMemory() async {
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Error",
        "User not logged in. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isGenerating.value = true;

      final response = await _memoriesApi.generateMemory(token: token);
      final message =
          response['message']?.toString() ?? 'Memory generation started';

      Get.snackbar(
        "Generation Started",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF81D4FA).withValues(alpha: 0.9),
        colorText: Colors.black87,
        icon: const Icon(Icons.auto_awesome, color: Colors.amber),
        duration: const Duration(seconds: 4),
      );

      // Refresh memories list to show any newly initiated processing memory
      await fetchMemories();
    } catch (e) {
      debugPrint('Generate memory error: $e');
      Get.snackbar(
        "Error",
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  // ============================================
  // FETCH MEMORY BY ID (GET /memories/{id})
  // ============================================

  Future<Memories?> fetchMemoryById(int id) async {
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final updated = await _memoriesApi.getMemoryById(
        memoryId: id,
        token: token,
      );

      final index = memories.indexWhere((m) => m.id == id);
      if (index != -1) {
        memories[index] = updated;
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
    await fetchMemories();
  }
}