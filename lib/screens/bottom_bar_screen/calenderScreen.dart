import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/calendarscreen_controller.dart';
import 'package:lildairy/controllers/subscription_controller.dart';
import 'package:lildairy/screens/NoteDetailsScreen.dart';
import 'package:lildairy/screens/subscription/subscription_dialog.dart';
import 'package:lildairy/screens/subscription/subscription_screen.dart';
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

            // Archive Notice for Free Users
            Obx(() {
              final subCtrl = Get.isRegistered<SubscriptionController>()
                  ? Get.find<SubscriptionController>()
                  : Get.put(SubscriptionController());
              if (subCtrl.isSubscribed.value) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5FE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF81D4FA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF0288D1), size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Free plan displays past 6 months. Upgrade to view full history.",
                        style: TextStyle(fontSize: 12, color: Color(0xFF0277BD)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const SubscriptionScreen()),
                      child: const Text(
                        "Upgrade ⭐",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF01579B),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 6),

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

                  if (controller.isDateLocked.value) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                              ),
                              child: const Icon(
                                Icons.lock_clock_rounded,
                                size: 54,
                                color: Color(0xFFF57F17),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Archive Locked (6+ Months Old)",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Free accounts can only view memories up to 6 months old. Upgrade to Lil Diary Premium to unlock your lifetime archive!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0288D1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.stars_rounded),
                              label: const Text("Unlock with Premium ⭐"),
                              onPressed: () {
                                SubscriptionDialog.show(
                                  context,
                                  title: "Unlock 6-Month Archive",
                                  description:
                                      "Upgrade to Lil Diary Premium to view all memories past 6 months, create 6 diaries per day, and generate custom recaps!",
                                  icon: Icons.history_toggle_off_rounded,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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
                        'images': mediaPaths,
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

                                      return GestureDetector(
                                        onTap: () {
                                          _viewFullNote(
                                            context,
                                            noteId,
                                            noteData,
                                            initialIndex: mediaIndex,
                                          );
                                        },
                                        child: Padding(
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
    Map<String, dynamic> noteData, {
    int initialIndex = 0,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(
          noteId: noteId,
          noteData: noteData,
          initialIndex: initialIndex,
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
