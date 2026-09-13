import 'package:flutter/material.dart';
import 'package:lildairy/provider/test_provider.dart';
import 'package:lildairy/screens/HomeScreen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LilDairy',
      theme: ThemeData(primaryColor: const Color(0xFF81D4FA)),
      home: ChangeNotifierProvider(
        create: (_) => test_provider(),
        child: const NotesHomeScreen(),
      ),
    );
  }
}
