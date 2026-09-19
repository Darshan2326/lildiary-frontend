import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lildairy/models/register_response.dart';

import '../models/login_response.dart';
import '../models/user.dart';
import '../utils/api_constants.dart';
import 'ApiClient/api_client.dart';

class AuthApi {
  final ApiClient _apiClient = ApiClient();

  Future<LoginResponse> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      {
        'identifier': identifier,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw const FormatException('Login response is not a JSON object');
        }

        final loginResponse = LoginResponse.fromJson(data);
        debugPrint('[AUTH] Login response parsed successfully');
        return loginResponse;
      } catch (error, stackTrace) {
        debugPrint('[AUTH ERROR] Could not parse login response: $error');
        debugPrint('[AUTH ERROR] Stack trace: $stackTrace');
        throw Exception('Invalid login response from server');
      }
    }

    if (response.statusCode == 401) {
      throw Exception('Invalid username/email or password');
    }

    if (response.statusCode == 422) {
      throw Exception('Invalid request body');
    }

    throw Exception(
      'Login failed: ${response.statusCode}. Response: ${response.body}',
    );
  }

  Future<void> logout({required String token}) async {
    final response = await _apiClient.post(
      ApiConstants.logout,
      {},
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Logout failed: ${response.statusCode}. Response: ${response.body}',
      );
    }
  }

  Future<User> getCurrentUser({required String token}) async {
    final response = await _apiClient.get(
      ApiConstants.me,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw const FormatException('User response is not a JSON object');
      }

      return User.fromJson(data);
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired or invalid token');
    }

    throw Exception(
      'Could not load user: ${response.statusCode}. Response: ${response.body}',
    );
  }

  Future<RegisterResponse> RegisterAPI({
    required String name,
    required String username,
    required String email,
    required String password,
    required String confirm_password,
  }) async {
    final response = await _apiClient.post(ApiConstants.register, {
      "name": name,
      "username": username,
      "email": email,
      "password": password,
      "confirm_password": confirm_password
    });

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw const FormatException(
              "Register API response is not a JSON object");
        }

        final registerResponse = RegisterResponse.fromJson(data);
        debugPrint("[AUTH] Register response parsed successfully");
        return registerResponse;
      } catch (error, stackTrace) {
        debugPrint('[AUTH ERROR] Could not parse Resgister response: $error');
        debugPrint('[AUTH ERROR] Stack trace: $stackTrace');
        throw Exception('Invalid Register response from server');
      }
    }
    if (response.statusCode == 401) {
      throw Exception('Invalid username/email or password');
    }

    if (response.statusCode == 422) {
      throw Exception('Invalid request body');
    }

    throw Exception(
      'Login failed: ${response.statusCode}. Response: ${response.body}',
    );
  }
}
