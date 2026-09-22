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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () => controller.loadUserDetails(),
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadUserDetails(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ============================================
                // PROFILE IMAGE & AVATAR UPLOAD (POST /users/profile/image)
                // ============================================
                Obx(
                  () => GestureDetector(
                    onTap: controller.pickAndSaveImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: _getProfileImage(controller),
                          ),
                        ),

                        // Edit Badge Icon
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blue.shade600,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),

                        // Loading overlay during image upload
                        if (controller.isUploadingImage.value)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ============================================
                // USER NAME & USERNAME & EMAIL DISPLAY
                // ============================================
                Obx(
                  () => controller.isLoading.value
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          children: [
                            Text(
                              controller.userName.value.isEmpty
                                  ? 'No Name Set'
                                  : controller.userName.value,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (controller.userUsername.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '@${controller.userUsername.value}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              controller.userEmail.value.isEmpty
                                  ? 'No Email Set'
                                  : controller.userEmail.value,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 30),

                // ============================================
                // PROFILE WORKFLOW OPTIONS
                // ============================================

                // 1. Edit Profile Information (PATCH /users/profile)
                _buildProfileOption(
                  icon: Icons.person_outline,
                  title: 'Edit Profile Information',
                  subtitle: 'Update full name and username',
                  onTap: () => _showEditProfileDialog(context, controller),
                ),

                // 2. Change Email Address (POST /email/request & verify)
                _buildProfileOption(
                  icon: Icons.mark_email_unread_outlined,
                  title: 'Change Email Address',
                  subtitle: 'Verify & update email with OTP',
                  onTap: () => _showChangeEmailDialog(context, controller),
                ),

                // 3. Memories Navigation
                _buildProfileOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Memories',
                  subtitle: 'View your memory gallery',
                  onTap: () {
                    Get.to(() => const Memoriesscreen());
                  },
                ),

                // 4. About Us Navigation
                _buildProfileOption(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  subtitle: 'Learn more about LilDiary',
                  onTap: () {
                    Get.to(() => AboutUsScreen());
                  },
                ),

                // 5. Delete Account (DELETE /users/profile with password)
                _buildProfileOption(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  subtitle: 'Deactivate account permanently',
                  titleColor: Colors.red.shade700,
                  iconColor: Colors.red.shade700,
                  onTap: () => _showDeleteAccountDialog(context, controller),
                ),

                const SizedBox(height: 30),

                // ============================================
                // LOGOUT BUTTON (POST /logout)
                // ============================================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context, controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // IMAGE PROVIDER HELPER
  // ============================================

  ImageProvider _getProfileImage(ProfileController controller) {
    if (controller.profileImage.value != null) {
      return FileImage(controller.profileImage.value!);
    }

    if (controller.profileImageUrl.value.isNotEmpty) {
      return NetworkImage(controller.profileImageUrl.value);
    }

    return const AssetImage('assets/logos/user2.png');
  }

  // ============================================
  // PROFILE OPTION CARD BUILDER
  // ============================================

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color titleColor = Colors.black87,
    Color iconColor = Colors.blue,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  // ============================================
  // DIALOG: EDIT PROFILE INFO (PATCH /users/profile)
  // ============================================

  void _showEditProfileDialog(
    BuildContext context,
    ProfileController controller,
  ) {
    final nameController = TextEditingController(
      text: controller.userName.value,
    );
    final usernameController = TextEditingController(
      text: controller.userUsername.value,
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isUpdatingProfile.value
                  ? null
                  : () async {
                      final success = await controller.updateProfileInfo(
                        name: nameController.text,
                        username: usernameController.text,
                      );
                      if (success) {
                        Get.back();
                      }
                    },
              child: controller.isUpdatingProfile.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // DIALOG: SECURE EMAIL CHANGE WORKFLOW (2-STEP OTP)
  // ============================================

  void _showChangeEmailDialog(
    BuildContext context,
    ProfileController controller,
  ) {
    final newEmailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Request Email Change'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Email: ${controller.userEmail.value}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'New Email Address',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isSendingOtp.value
                  ? null
                  : () async {
                      final newEmail = newEmailController.text.trim();
                      if (newEmail.isEmpty || !newEmail.contains('@')) {
                        Get.snackbar('Invalid Email', 'Please enter a valid email');
                        return;
                      }

                      final success = await controller.requestEmailChangeOTP(newEmail);
                      if (success) {
                        Get.back();
                        _showVerifyOtpDialog(context, controller, newEmail);
                      }
                    },
              child: controller.isSendingOtp.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send OTP'),
            ),
          ),
        ],
      ),
    );
  }

  void _showVerifyOtpDialog(
    BuildContext context,
    ProfileController controller,
    String newEmail,
  ) {
    final otpController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Verify Email OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 6-digit OTP code sent to:\n$newEmail',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                labelText: 'OTP Code',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isVerifyingOtp.value
                  ? null
                  : () async {
                      final otp = otpController.text.trim();
                      if (otp.length < 4) {
                        Get.snackbar('Invalid OTP', 'Please enter valid OTP code');
                        return;
                      }

                      final success = await controller.verifyEmailChangeOTP(
                        newEmail: newEmail,
                        otp: otp,
                      );
                      if (success) {
                        Get.back();
                      }
                    },
              child: controller.isVerifyingOtp.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify & Update'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // DIALOG: DELETE ACCOUNT (DELETE /users/profile with Password)
  // ============================================

  void _showDeleteAccountDialog(
    BuildContext context,
    ProfileController controller,
  ) {
    final passwordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action will deactivate your profile and invalidate active sessions. Please enter your account password to confirm:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(
            () => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              onPressed: controller.isDeletingAccount.value
                  ? null
                  : () async {
                      final password = passwordController.text;
                      if (password.isEmpty) {
                        Get.snackbar('Required', 'Password is required to delete account');
                        return;
                      }

                      Get.back();
                      await controller.deleteAccount(password);
                    },
              child: controller.isDeletingAccount.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // DIALOG: LOGOUT CONFIRMATION (POST /logout)
  // ============================================

  void _showLogoutDialog(
    BuildContext context,
    ProfileController controller,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
            ),
            onPressed: () async {
              Get.back();
              await controller.logout();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
