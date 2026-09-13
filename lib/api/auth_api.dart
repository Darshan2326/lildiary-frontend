import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/login_response.dart';
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
}
