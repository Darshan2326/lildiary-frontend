import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/login_controller.dart';
import 'package:lildairy/screens/HomeScreen.dart';
import 'package:lildairy/screens/login.dart';
import 'package:lildairy/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'LilDairy',
      theme: ThemeData(primaryColor: const Color(0xFF81D4FA)),
      // home: NotesHomeScreen());
      home: Obx(
        () {
          if (authController.isLoggedIn.value) {
            return NotesHomeScreen();
          }

          return LoginScreen();
        },
      ),
    );
  }
}
