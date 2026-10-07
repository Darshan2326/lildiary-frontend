import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lildairy/api/diary_api.dart';
import 'package:lildairy/controllers/subscription_controller.dart';
import 'package:lildairy/models/user.dart';
import 'package:lildairy/screens/subscription/subscription_dialog.dart';
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

  // Loading, error, and lock states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isDateLocked = false.obs;

  bool isDateOlderThan6Months(DateTime date) {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    final targetDate = DateTime(date.year, date.month, date.day);
    final cutoffDate = DateTime(sixMonthsAgo.year, sixMonthsAgo.month, sixMonthsAgo.day);
    return targetDate.isBefore(cutoffDate);
  }

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

    final isOlderThan6Months = isDateOlderThan6Months(date);
    final subCtrl = Get.isRegistered<SubscriptionController>()
        ? Get.find<SubscriptionController>()
        : Get.put(SubscriptionController());
    final isUserSubscribed = subCtrl.isSubscribed.value;

    if (isOlderThan6Months && !isUserSubscribed) {
      isDateLocked.value = true;
      diaries.clear();
      memoriesForSelectedDate.clear();
      isLoading.value = false;
      errorMessage.value = '';
      return;
    }

    isDateLocked.value = false;

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

    final isOlderThan6Months = isDateOlderThan6Months(selectedDay);
    final subCtrl = Get.isRegistered<SubscriptionController>()
        ? Get.find<SubscriptionController>()
        : Get.put(SubscriptionController());
    final isUserSubscribed = subCtrl.isSubscribed.value;

    if (isOlderThan6Months && !isUserSubscribed) {
      isDateLocked.value = true;
      diaries.clear();
      memoriesForSelectedDate.clear();
      if (Get.context != null) {
        SubscriptionDialog.show(
          Get.context!,
          title: "6-Month Archive Locked",
          description:
              "Memories older than 6 months are archived for free accounts. Upgrade to Lil Diary Premium to access all past moments and your full calendar archive!",
          icon: Icons.history_toggle_off_rounded,
          iconColor: const Color(0xFF0288D1),
        );
      }
      return;
    }

    isDateLocked.value = false;
    fetchMemoriesForDate(selectedDay);
  }
}