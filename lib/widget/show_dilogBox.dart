import 'package:flutter/material.dart';

class MyDialog extends StatefulWidget {
  const MyDialog({super.key});

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  final double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      // content: Text("Progress = ${_progress}"),
      actions: <Widget>[

      ],
    );
  }
}