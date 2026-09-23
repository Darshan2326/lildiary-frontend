import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lildairy/api/diary_api.dart';
import 'package:lildairy/controllers/calendarscreen_controller.dart';
import 'package:lildairy/controllers/lendinghome_controller.dart';
import 'package:lildairy/screens/EditNoteScreen.dart';
import 'package:lildairy/screens/FullScreenMediaViewer.dart';
import 'package:lildairy/screens/HomeScreen.dart';
import 'package:lildairy/services/storage_service.dart';
import 'package:lildairy/widget/smart_media_widget.dart';
import 'package:share_plus/share_plus.dart';

class NoteDetailsController extends GetxController {
  final String noteId;
  final DiaryApi _diaryApi = DiaryApi();

  // Observable note data
  final RxMap<String, dynamic> noteData = <String, dynamic>{}.obs;

  // Active carousel item index
  final RxInt currentIndex = 0.obs;

  // Loading indicator for deletion
  final RxBool isDeleting = false.obs;

  NoteDetailsController({
    required this.noteId,
    required Map<String, dynamic> initialNoteData,
  }) {
    noteData.assignAll(initialNoteData);
  }

  // Carousel page change
  void onPageChanged(int index) {
    currentIndex.value = index;
    update();
  }

  // Video play/pause callback
  void onVideoPlayPause(bool isPlaying, int index) {
    if (isPlaying) {
      currentIndex.value = index;
      update();
    }
  }

  // Getters for convenience
  List<dynamic> get mediaPaths =>
      (noteData['mediaPaths'] as List<dynamic>?) ?? <dynamic>[];

  String get title => (noteData['title'] as String?) ?? 'No Title';

  String get description =>
      (noteData['description'] as String?) ?? 'No Description';

  String get formattedDate {
    final raw = noteData['timestamp'];
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return raw.toString();
    return DateFormat('dd MMM, yyyy').format(parsed);
  }

  String get formattedTime {
    final raw = noteData['timestamp'];
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return '';
    return DateFormat('hh:mm a').format(parsed);
  }

  // Open full-screen media viewer
  void openFullScreen(BuildContext context, String rawMediaPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMediaViewer(mediaPath: rawMediaPath),
      ),
    );
  }

  // Open edit note screen
  Future<void> openEditNote(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(
          noteId: noteId,
          noteData: Map<String, dynamic>.from(noteData),
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      noteData.assignAll(result);
      update();
    }
  }

  // Share note details & media
  Future<void> shareNote() async {
    final shareMessage = "$title\n\n$description";

    try {
      final resolved = mediaPaths
          .map((p) => MediaUtils.resolvePath(p.toString()))
          .toList();
      final localFiles = resolved
          .where((p) =>
              !p.startsWith('http://') && !p.startsWith('https://'))
          .map((p) => XFile(p))
          .toList();

      if (localFiles.isNotEmpty) {
        await Share.shareXFiles(localFiles, text: shareMessage);
      } else {
        final urlList = resolved
            .where((p) =>
                p.startsWith('http://') || p.startsWith('https://'))
            .join('\n');
        await Share.share(
            urlList.isNotEmpty ? '$shareMessage\n\n$urlList' : shareMessage);
      }
    } catch (e) {
      debugPrint('Error while sharing: $e');
    }
  }

  // Confirm before deleting
  Future<void> confirmAndDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(CupertinoIcons.trash, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              'Delete Diary',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this diary entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteNote(context: context);
    }
  }

  // Delete note using DELETE /diary/{diary_id}
  Future<bool> deleteNote({BuildContext? context}) async {
    try {
      isDeleting.value = true;
      update();

      final token = StorageService.getToken();
      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Unauthorized',
          'User token not found. Please log in again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.85),
          colorText: Colors.white,
        );
        return false;
      }

      final rawId = noteData['id']?.toString() ?? noteId;
      final diaryId = int.tryParse(rawId) ?? rawId;

      final result = await _diaryApi.deleteDiary(
        diaryId: diaryId,
        token: token,
      );

      // Refresh other controllers if registered
      if (Get.isRegistered<CalendarController>()) {
        final calCtrl = Get.find<CalendarController>();
        calCtrl.fetchMemoriesForDate(calCtrl.selectedDate.value);
      }
      if (Get.isRegistered<LendingHomeController>()) {
        Get.find<LendingHomeController>().loadUserData();
      }

      final message =
          result['message']?.toString() ?? 'Diary deleted successfully';

      // Redirect back to previous screen or fallback to HomeScreen
      final navContext = context ?? Get.context;
      if (navContext != null && Navigator.canPop(navContext)) {
        Navigator.pop(navContext, true);
      } else {
        Get.offAll(() => NotesHomeScreen());
      }

      // Show success feedback on the redirected screen
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.85),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      debugPrint('Delete diary error: $e');
      final cleanError = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        cleanError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isDeleting.value = false;
      update();
    }
  }
}
