import 'package:get/get.dart';

class NotesHomeScreenController extends GetxController {
  // Selected bottom navigation index
  final RxInt selectedIndex = 0.obs;

  // Change selected tab
  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
