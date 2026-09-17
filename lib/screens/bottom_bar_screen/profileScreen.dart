import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lildairy/controllers/login_controller.dart';
import 'package:lildairy/screens/aboutus.dart';
import 'package:lildairy/screens/bottom_bar_screen/memoriesScreen.dart';

class ProfilePage extends StatefulWidget {
  final String userId; // Pass the user ID to differentiate accounts

  const ProfilePage({required this.userId, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController _authController = Get.find<AuthController>();
  String? profileImageUrl;
  String displayName = '';
  String email = '';
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;
  String? _userEmail;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _loadUserDetails();

    // _fetchUserProfile();
  }

  Future<void> _pickAndSaveImage() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path); // Keep the image transient
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update image: $e')),
      );
    }
  }

  Future<void> _loadUserEmail() async {
    setState(() {
      _userEmail = 'API email';
    });
  }

  Future<void> _loadUserDetails() async {
    setState(() {
      _userEmail = 'API email';
      _userName = 'API user';
    });
  }

  Future<void> _sendPasswordResetEmail() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Password reset is unavailable in offline mode')),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Delete action is ready for API integration')),
      );
      await _authController.logout();
    } catch (e) {
      print('Error deleting account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete account')),
      );
    }
  }

  void _navigateToMemoriesScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const Memoriesscreen()),
    );
  }

  void _aboutUsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AboutUsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickAndSaveImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/logos/user2.png')
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

            const SizedBox(height: 20),
            Text(
              _userName ?? 'Loading...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _userEmail ?? 'Loading...',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            // Text(
            //   // widget.nameController
            //   displayName,
            //   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 5),
            Text(email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: _sendPasswordResetEmail,
                  ),
                  _buildProfileOption(
                    icon: Icons.image,
                    title: 'Memories',
                    onTap: _navigateToMemoriesScreen,
                  ),
                  _buildProfileOption(
                    icon: Icons.star,
                    title: 'Rate Us',
                    onTap: () {
                      // Implement rate us functionality
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.info,
                    title: 'About Us',
                    onTap: _aboutUsScreen,
                  ),
                  _buildProfileOption(
                    icon: Icons.delete_forever,
                    title: 'Delete Account',
                    onTap: () async {
                      bool confirmDelete = await _confirmDeleteDialog();
                      if (confirmDelete) _deleteAccount();
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _confirmLogOutDialog,
                    // onPressed: () async {
                    //   await _auth.signOut();
                    //   _navigateToLoginScreen();
                    // },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<bool> _confirmDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Account Deletion'),
            content:
                const Text('Are you sure you want to delete your account?'),
            actions: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel',
                          style: TextStyle(color: Color(0xFF81D4FA))),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF81D4FA),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ) ??
        false;
  }

  Future<void> _confirmLogOutDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Confirm Logout...')),
        content: const Text('Are you sure you want to Logout your account?'),
        actions: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF81D4FA)),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81D4FA),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _authController.logoutAPI();
                  },
                  child: const Text(
                    'yes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
