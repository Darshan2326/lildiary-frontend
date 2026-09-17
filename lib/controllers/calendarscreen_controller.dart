import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CalendarController extends GetxController {
  // Selected date
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Memories for selected date
  final RxList<Map<String, dynamic>> memoriesForSelectedDate =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Fetch memories for today's date
    fetchMemoriesForDate(selectedDate.value);
  }

  // Fetch memories
  Future<void> fetchMemoriesForDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    print('Fetching memories for: $formattedDate');

    try {
      // Clear old memories
      memoriesForSelectedDate.clear();

      // ------------------------------------------------
      // TODO:
      // Add your API / database call here.
      //
      // Example:
      //
      // final memories = await api.getMemories(formattedDate);
      // memoriesForSelectedDate.assignAll(memories);
      // ------------------------------------------------
    } catch (e) {
      print('Calendar fetch error: $e');

      memoriesForSelectedDate.clear();
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