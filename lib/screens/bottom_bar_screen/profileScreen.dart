import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lildairy/controllers/profile_controller.dart';
import 'package:lildairy/screens/aboutus.dart';
import 'package:lildairy/screens/bottom_bar_screen/memoriesScreen.dart';

class ProfilePage extends StatelessWidget {
  final String userId;

  const ProfilePage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(
      ProfileController(
        userId: userId,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),

            // ============================================
            // PROFILE IMAGE
            // ============================================

            Obx(
              () => GestureDetector(
                onTap: controller.pickAndSaveImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: controller.profileImage.value != null
                          ? FileImage(
                              controller.profileImage.value!,
                            )
                          : const AssetImage(
                              'assets/logos/user2.png',
                            ) as ImageProvider,
                    ),

                    // Edit icon
                    const Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    // Loading indicator
                    if (controller.isUploadingImage.value)
                      const Positioned.fill(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ============================================
            // USER NAME
            // ============================================

            Obx(
              () => Text(
                controller.userName.value.isEmpty
                    ? 'Loading...'
                    : controller.userName.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ============================================
            // USER EMAIL
            // ============================================

            Obx(
              () => Text(
                controller.userEmail.value.isEmpty
                    ? 'Loading...'
                    : controller.userEmail.value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // ============================================
            // PROFILE OPTIONS
            // ============================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                children: [
                  // Change Password
                  _buildProfileOption(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () {
                      controller.sendPasswordResetEmail();
                    },
                  ),

                  // Memories
                  _buildProfileOption(
                    icon: Icons.image,
                    title: 'Memories',
                    onTap: () {
                      Get.to(
                        () => const Memoriesscreen(),
                      );
                    },
                  ),

                  // Rate Us
                  _buildProfileOption(
                    icon: Icons.star,
                    title: 'Rate Us',
                    onTap: () {
                      // TODO:
                      // Implement rate us functionality
                    },
                  ),

                  // About Us
                  _buildProfileOption(
                    icon: Icons.info,
                    title: 'About Us',
                    onTap: () {
                      Get.to(
                        () => AboutUsScreen(),
                      );
                    },
                  ),

                  // Delete Account
                  _buildProfileOption(
                    icon: Icons.delete_forever,
                    title: 'Delete Account',
                    onTap: () {
                      _confirmDeleteDialog(
                        controller,
                      );
                    },
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // ========================================
                  // LOGOUT BUTTON
                  // ========================================

                  ElevatedButton(
                    onPressed: () {
                      _confirmLogOutDialog(
                        controller,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // PROFILE OPTION
  // ============================================

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue,
        ),
        title: Text(
          title,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  // ============================================
  // DELETE CONFIRMATION
  // ============================================

  Future<void> _confirmDeleteDialog(
    ProfileController controller,
  ) async {
    final bool? confirmDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          'Confirm Account Deletion',
        ),
        content: const Text(
          'Are you sure you want to delete your account?',
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                onPressed: () {
                  Get.back(
                    result: false,
                  );
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(
                      0xFF81D4FA,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 20,
              ),

              // Delete
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF81D4FA,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                onPressed: () {
                  Get.back(
                    result: true,
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await controller.deleteAccount();
    }
  }

  // ============================================
  // LOGOUT CONFIRMATION
  // ============================================

  Future<void> _confirmLogOutDialog(
    ProfileController controller,
  ) async {
    await Get.dialog<void>(
      AlertDialog(
        title: const Center(
          child: Text(
            'Confirm Logout...',
          ),
        ),
        content: const Text(
          'Are you sure you want to Logout your account?',
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(
                      0xFF81D4FA,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 20,
              ),

              // Yes
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF81D4FA,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                onPressed: () async {
                  Get.back();

                  await controller.logout();
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
