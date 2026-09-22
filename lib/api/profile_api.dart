import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/api_constants.dart';
import 'ApiClient/api_client.dart';

class ProfileApi {
  final ApiClient _apiClient = ApiClient();

  /// GET /users/profile - Fetch basic profile information
  Future<User> getProfile({required String token}) async {
    final response = await _apiClient.get(
      ApiConstants.profile,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Profile response is not a valid JSON object');
      }
      return User.fromJson(data);
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired or unauthorized');
    }

    throw Exception(
      'Failed to load profile (${response.statusCode}): ${_extractErrorMsg(response)}',
    );
  }

  /// GET /me - Fetch full profile with diaries & memories
  Future<User> getMeProfile({required String token}) async {
    final response = await _apiClient.get(
      ApiConstants.me,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('User me response is not a valid JSON object');
      }
      return User.fromJson(data);
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired or unauthorized');
    }

    throw Exception(
      'Failed to load user info (${response.statusCode}): ${_extractErrorMsg(response)}',
    );
  }

  /// PATCH /users/profile - Update profile details (Name, Username, Email, Image)
  Future<User> updateProfile({
    required String token,
    String? name,
    String? username,
    String? email,
    File? image,
  }) async {
    final Map<String, String> fields = {};
    if (name != null && name.trim().isNotEmpty) {
      fields['name'] = name.trim();
    }
    if (username != null && username.trim().isNotEmpty) {
      fields['username'] = username.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      fields['email'] = email.trim();
    }

    final List<http.MultipartFile> files = [];
    if (image != null) {
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        image.path,
      );
      files.add(multipartFile);
    }

    final response = await _apiClient.patchMultipart(
      ApiConstants.profile,
      fields: fields,
      files: files,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    }

    if (response.statusCode == 409) {
      throw Exception('Username or email is already taken by another user.');
    }

    throw Exception(
      'Failed to update profile (${response.statusCode}): ${_extractErrorMsg(response)}',
    );
  }

  /// POST /users/profile/image - Upload avatar image to storage
  Future<User> uploadProfileImage({
    required String token,
    required File image,
  }) async {
    final multipartFile = await http.MultipartFile.fromPath(
      'image',
      image.path,
    );

    final response = await _apiClient.postMultipart(
      ApiConstants.profileImage,
      files: [multipartFile],
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    }

    throw Exception(
      'Failed to upload profile image (${response.statusCode}): ${_extractErrorMsg(response)}',
    );
  }

  /// POST /users/profile/email/request - Initiate email change OTP verification
  Future<String> requestEmailChange({
    required String token,
    required String newEmail,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.profileEmailRequest,
      {
        'new_email': newEmail.trim(),
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'OTP sent to your new email address';
    }

    if (response.statusCode == 400) {
      throw Exception(_extractErrorMsg(response) ?? 'This is already your email address');
    }

    if (response.statusCode == 409) {
      throw Exception('That email address is already in use');
    }

    throw Exception(
      'Email request failed (${response.statusCode}): ${_extractErrorMsg(response)}',
    );
  }

  /// POST /users/profile/email/verify - Verify OTP code & update user email
  Future<User> verifyEmailChange({
    required String token,
    required String newEmail,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.profileEmailVerify,
      {
        'new_email': newEmail.trim(),
        'otp': otp.trim(),
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    }

    if (response.statusCode == 400) {
      throw Exception('Invalid or expired OTP code');
    }

    if (response.statusCode == 409) {
      throw Exception('That email address is already in use');
    }

    throw Exception(
      'Email verification failed (${response.statusCode}): ${_extractErrorMsg(response)}',
    );
  }

  /// DELETE /users/profile - Soft delete / deactivate user account
  Future<void> deleteProfile({
    required String token,
    required String password,
  }) async {
    final response = await _apiClient.delete(
      ApiConstants.profile,
      body: {
        'password': password,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 400) {
      throw Exception('Incorrect password provided.');
    }

    if (response.statusCode == 401) {
      throw Exception('Unauthorized request or invalid session.');
    }

    throw Exception(
      'Failed to delete account (${response.statusCode}): ${_extractErrorMsg(response)}',
    );
  }

  /// POST /logout - Revoke access token
  Future<void> logout({required String token}) async {
    final response = await _apiClient.post(
      ApiConstants.logout,
      {},
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception('Logout failed with status ${response.statusCode}');
  }

  String? _extractErrorMsg(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body.containsKey('detail')) {
        final detail = body['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          return detail.first['msg']?.toString() ?? detail.toString();
        }
      }
    } catch (_) {}
    return response.body.isNotEmpty ? response.body : null;
  }
}
