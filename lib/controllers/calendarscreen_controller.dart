import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lildairy/api/diary_api.dart';
import 'package:lildairy/models/user.dart';
import 'package:lildairy/services/storage_service.dart';

class CalendarController extends GetxController {
  final DiaryApi _diaryApi = DiaryApi();

  // Selected date
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Diaries for selected date
  final RxList<Diaries> diaries = <Diaries>[].obs;

  // Memories for selected date (maintained for backward compatibility)
  final RxList<Map<String, dynamic>> memoriesForSelectedDate =
      <Map<String, dynamic>>[].obs;

  // Loading and error states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Fetch memories for today's date
    fetchMemoriesForDate(selectedDate.value);
  }

  // Fetch memories for a specific date
  Future<void> fetchMemoriesForDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    debugPrint('Fetching diaries for: $formattedDate');

    try {
      isLoading.value = true;
      errorMessage.value = '';
      diaries.clear();
      memoriesForSelectedDate.clear();

      final token = StorageService.getToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = 'User not logged in';
        return;
      }

      final result = await _diaryApi.getDiariesByDate(
        date: formattedDate,
        token: token,
      );

      diaries.assignAll(result);

      // Keep memoriesForSelectedDate in sync
      final mappedMemories = result.map((diary) {
        return {
          'id': diary.id?.toString() ?? '',
          'data': <String, dynamic>{
            'id': diary.id?.toString(),
            'title': diary.title,
            'description': diary.description,
            'mediaPaths': diary.images ?? <String>[],
            'timestamp': diary.createdAt ?? DateTime.now().toIso8601String(),
          },
        };
      }).toList();

      memoriesForSelectedDate.assignAll(mappedMemories);
    } catch (e) {
      debugPrint('Calendar fetch error: $e');
      final errorStr = e.toString();
      if (errorStr.contains('404') ||
          errorStr.toLowerCase().contains('no memories found')) {
        errorMessage.value = '';
      } else {
        errorMessage.value = errorStr;
      }
      diaries.clear();
      memoriesForSelectedDate.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // When user selects a date
  void onDateSelected(
    DateTime selectedDay,
    DateTime focusedDay,
  ) {
    selectedDate.value = selectedDay;

    fetchMemoriesForDate(selectedDay);
  }
}