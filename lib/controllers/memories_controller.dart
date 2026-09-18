import 'package:get/get.dart';

class MemoriesController extends GetxController {
  // ============================================
  // MEMORIES LIST
  // ============================================

  final RxList<Map<String, dynamic>> memories =
      <Map<String, dynamic>>[].obs;

  // ============================================
  // LOADING
  // ============================================

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    fetchMemories();
  }

  // ============================================
  // FETCH MEMORIES
  // ============================================

  Future<void> fetchMemories() async {
    try {
      isLoading.value = true;

      // TODO:
      // Add your API call here.
      //
      // Example:
      //
      // final result = await apiClient.get(
      //   "/notes",
      // );
      //
      // memories.value =
      //     List<Map<String, dynamic>>.from(result);

      // Your current code uses Future.value([])
      // so we keep the same behavior for now.
      memories.clear();
    } catch (e) {
      memories.clear();

      Get.snackbar(
        "Error",
        "Failed to load memories: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // REFRESH
  // ============================================

  Future<void> refreshMemories() async {
    await fetchMemories();
  }
}