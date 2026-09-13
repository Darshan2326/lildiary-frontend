import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/screens/HomeScreen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'LilDairy',
        theme: ThemeData(primaryColor: const Color(0xFF81D4FA)),
        home: NotesHomeScreen());
  }
}
