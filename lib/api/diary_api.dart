import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lildairy/models/user.dart';
import 'package:lildairy/utils/api_constants.dart';

import 'ApiClient/api_client.dart';

class DiaryApi {
  final ApiClient _apiClient = ApiClient();

  Future<List<Diaries>> getDiariesByDate({
    required String date,
    required String token,
  }) async {
    final url = '${ApiConstants.diaryByDate}?diary_date=$date';

    final response = await _apiClient.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is! List) {
          throw const FormatException('Diary response is not a JSON array');
        }

        final List<Diaries> diaries = decoded
            .map((item) => Diaries.fromJson(item as Map<String, dynamic>))
            .toList();

        debugPrint('[DIARY] Loaded ${diaries.length} diaries for date: $date');
        return diaries;
      } catch (error, stackTrace) {
        debugPrint('[DIARY ERROR] Could not parse diary response: $error');
        debugPrint('[DIARY ERROR] Stack trace: $stackTrace');
        throw Exception('Invalid diary response from server');
      }
    }

    if (response.statusCode == 404 ||
        response.body.toLowerCase().contains('no memories found')) {
      debugPrint('[DIARY] No memories found for date: $date');
      return <Diaries>[];
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired or unauthorized');
    }

    throw Exception(
      'Failed to load diaries: ${response.statusCode}. Response: ${response.body}',
    );
  }
}
