import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/calendarscreen_controller.dart';
import 'package:lildairy/screens/NoteDetailsScreen.dart';
import 'package:lildairy/widget/smart_media_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController controller = Get.put(CalendarController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calendar",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB4DCF1),
              Colors.white,
              Color(0xFFF1C6D4),
            ],
          ),
        ),
        child: Column(
          children: [
            // ==============================
            // CALENDAR
            // ==============================

            Padding(
              padding: const EdgeInsets.all(8),
              child: Card(
                elevation: 5,
                child: Obx(
                  () => TableCalendar(
                    focusedDay: controller.selectedDate.value,
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),
                    selectedDayPredicate: (day) {
                      return isSameDay(
                        controller.selectedDate.value,
                        day,
                      );
                    },
                    onDaySelected: controller.onDateSelected,
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFF81D4FA),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      todayTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ==============================
            // MEMORIES / DIARIES
            // ==============================

            Expanded(
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final hasError = controller.errorMessage.value.isNotEmpty &&
                      !controller.errorMessage.value.contains('404') &&
                      !controller.errorMessage.value
                          .toLowerCase()
                          .contains('no memories found');

                  if (hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              controller.errorMessage.value
                                  .replaceAll('Exception: ', ''),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                controller.fetchMemoriesForDate(
                                  controller.selectedDate.value,
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final diaries = controller.diaries;

                  if (diaries.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/animation/empty.json',
                              width: 220,
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No memories found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: diaries.length,
                    itemBuilder: (context, index) {
                      final diary = diaries[index];

                      final noteId = diary.id?.toString() ?? '';

                      final mediaPaths = diary.images ?? <String>[];

                      final title = diary.title ?? 'No Title';

                      final description =
                          diary.description ?? 'No Description';

                      final noteData = <String, dynamic>{
                        'id': noteId,
                        'title': title,
                        'description': description,
                        'mediaPaths': mediaPaths,
                        'timestamp': diary.createdAt ??
                            DateTime.now().toIso8601String(),
                      };

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // Media
                              if (mediaPaths.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: mediaPaths.length,
                                    itemBuilder: (
                                      context,
                                      mediaIndex,
                                    ) {
                                      final mediaPath = mediaPaths[mediaIndex];

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6.0,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: SizedBox(
                                            width: 150,
                                            height: 150,
                                            child: _buildMediaPreview(
                                              mediaPath.toString(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            _viewFullNote(
                              context,
                              noteId,
                              noteData,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // OPEN NOTE DETAILS
  // ==============================

  void _viewFullNote(
    BuildContext context,
    String noteId,
    Map<String, dynamic> noteData,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(
          noteId: noteId,
          noteData: noteData,
        ),
      ),
    );

    if (result == true && Get.isRegistered<CalendarController>()) {
      final calCtrl = Get.find<CalendarController>();
      calCtrl.fetchMemoriesForDate(calCtrl.selectedDate.value);
    }
  }

  // ==============================
  // MEDIA PREVIEW
  // ==============================

  Widget _buildMediaPreview(String path) {
    return SmartMediaWidget(
      mediaPath: path,
      fit: BoxFit.cover,
    );
  }
}
