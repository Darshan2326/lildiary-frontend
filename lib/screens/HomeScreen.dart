// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:lildairy/screens/bottom_bar_screen/LendingHomeScreen.dart';
// import 'package:lildairy/screens/bottom_bar_screen/add_new_note.dart';
// import 'package:lildairy/screens/bottom_bar_screen/calenderScreen.dart';
// import 'package:lildairy/screens/bottom_bar_screen/memoriesScreen.dart';
// import 'package:lildairy/screens/bottom_bar_screen/profileScreen.dart';
// import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

// class NotesHomeScreen extends StatefulWidget {
//   const NotesHomeScreen({super.key});

//   @override
//   _NotesHomeScreenState createState() => _NotesHomeScreenState();
// }

// class _NotesHomeScreenState extends State<NotesHomeScreen> {
//   int _selectedIndex = 0;
//   final TextEditingController noteController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();

//   // List of screens for each tab
//   List<Widget> _buildScreens() {
//     const String userId = 'preview';
//     return [
//       lendingHomeScreen(userId: userId),
//       const CalendarScreen(),
//       const addNewNote(),
//       const Memoriesscreen(),
//       ProfilePage(userId: userId),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _buildScreens()[_selectedIndex],
//       bottomNavigationBar: SalomonBottomBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         items: [
//           SalomonBottomBarItem(
//             icon: const Icon(Icons.home, size: 30),
//             title: const Text("Home"),
//             selectedColor: const Color(0xFFEEA3B8),
//           ),
//           SalomonBottomBarItem(
//             icon: const Icon(Icons.calendar_month, size: 30),
//             title: const Text("Calendar"),
//             selectedColor: const Color(0xFFEEA3B8),
//           ),
//           SalomonBottomBarItem(
//             icon: const Icon(Icons.add_circle_outline, size: 30),
//             title: const Text("Add"),
//             selectedColor: const Color(0xFFEEA3B8),
//           ),
//           SalomonBottomBarItem(
//             icon: const Icon(Icons.access_time_sharp, size: 30),
//             title: const Text("Memories"),
//             selectedColor: const Color(0xFFEEA3B8),
//           ),
//           SalomonBottomBarItem(
//             icon: const Icon(Icons.person_rounded, size: 30),
//             title: const Text("Profile"),
//             selectedColor: const Color(0xFFEEA3B8),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/NotesHomeScreen_controller.dart';
import 'package:lildairy/screens/bottom_bar_screen/LendingHomeScreen.dart';
import 'package:lildairy/screens/bottom_bar_screen/add_new_note.dart';
import 'package:lildairy/screens/bottom_bar_screen/calenderScreen.dart';
import 'package:lildairy/screens/bottom_bar_screen/memoriesScreen.dart';
import 'package:lildairy/screens/bottom_bar_screen/profileScreen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class NotesHomeScreen extends StatelessWidget {
  NotesHomeScreen({super.key});

  final NotesHomeScreenController controller = Get.put(
    NotesHomeScreenController(),
  );

  // List of screens for each tab
  List<Widget> _buildScreens() {
    const String userId = 'preview';

    return [
      lendingHomeScreen(userId: userId),
      const CalendarScreen(),
      const addNewNote(),
      const Memoriesscreen(),
      ProfilePage(userId: userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();

    return Scaffold(
      body: Obx(
        () => screens[controller.selectedIndex.value],
      ),
      bottomNavigationBar: Obx(
        () => SalomonBottomBar(
          currentIndex: controller.selectedIndex.value,
          onTap: (index) {
            controller.changeTab(index);
          },
          items: [
            SalomonBottomBarItem(
              icon: const Icon(
                Icons.home,
                size: 30,
              ),
              title: const Text("Home"),
              selectedColor: const Color(0xFFEEA3B8),
            ),
            SalomonBottomBarItem(
              icon: const Icon(
                Icons.calendar_month,
                size: 30,
              ),
              title: const Text("Calendar"),
              selectedColor: const Color(0xFFEEA3B8),
            ),
            SalomonBottomBarItem(
              icon: const Icon(
                Icons.add_circle_outline,
                size: 30,
              ),
              title: const Text("Add"),
              selectedColor: const Color(0xFFEEA3B8),
            ),
            SalomonBottomBarItem(
              icon: const Icon(
                Icons.access_time_sharp,
                size: 30,
              ),
              title: const Text("Memories"),
              selectedColor: const Color(0xFFEEA3B8),
            ),
            SalomonBottomBarItem(
              icon: const Icon(
                Icons.person_rounded,
                size: 30,
              ),
              title: const Text("Profile"),
              selectedColor: const Color(0xFFEEA3B8),
            ),
          ],
        ),
      ),
    );
  }
}
