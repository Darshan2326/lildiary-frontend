import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'login.dart';

class UserProfilePerAccount extends StatefulWidget {
  final String userId; // Pass the user ID to differentiate accounts

  const UserProfilePerAccount({required this.userId, Key? key})
      : super(key: key);

  @override
  State<UserProfilePerAccount> createState() => _UserProfilePerAccountState();
}

class _UserProfilePerAccountState extends State<UserProfilePerAccount> {
  final ImagePicker _imagePicker = ImagePicker();

  File? _profileImage;
  String? _userEmail;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUserDetails();
  }

  Future<void> _loadProfileImage() async {
    // API profile loading will be added here.
  }

  Future<void> _loadUserDetails() async {
    setState(() {
      _userEmail = 'API email';
      _userName = 'API user';
    });
  }

  Future<void> _pickAndSaveImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Per Account'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickAndSaveImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/user_placeholder.png')
                        as ImageProvider,
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, color: Colors.blue),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Display user name below the profile picture
            Text(
              _userName ?? 'Loading...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Display user email below the profile picture
            Text(
              _userEmail ?? 'Loading...',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAndSaveImage,
              child: const Text('Upload New Image'),
            ),
          ],
        ),
      ),
    );
  }
}
