import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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

  static MediaType _getMediaTypeForFile(String path) {
    final ext = path.toLowerCase().split('.').last.split('?').first;
    switch (ext) {
      // Images
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'heic':
        return MediaType('image', 'heic');
      case 'heif':
        return MediaType('image', 'heif');
      case 'bmp':
        return MediaType('image', 'bmp');

      // Videos
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'm4v':
        return MediaType('video', 'x-m4v');
      case 'avi':
        return MediaType('video', 'x-msvideo');
      case 'webm':
        return MediaType('video', 'webm');
      case 'mkv':
        return MediaType('video', 'x-matroska');
      case '3gp':
        return MediaType('video', '3gpp');
      case 'flv':
        return MediaType('video', 'x-flv');

      default:
        return MediaType('application', 'octet-stream');
    }
  }

  Future<Diaries> addDiary({
    required String title,
    required String description,
    required List<File> files,
    required String token,
  }) async {
    final List<http.MultipartFile> multipartFiles = [];

    for (final file in files) {
      final mediaType = _getMediaTypeForFile(file.path);
      final multipartFile = await http.MultipartFile.fromPath(
        'images',
        file.path,
        contentType: mediaType,
      );
      multipartFiles.add(multipartFile);
    }

    final response = await _apiClient.postMultipart(
      ApiConstants.addDiary,
      fields: {
        'title': title,
        'description': description,
      },
      files: multipartFiles,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
              'Add diary response is not a JSON object');
        }

        final diary = Diaries.fromJson(decoded);
        debugPrint('[DIARY] Created diary successfully with ID: ${diary.id}');
        return diary;
      } catch (error, stackTrace) {
        debugPrint('[DIARY ERROR] Could not parse add diary response: $error');
        debugPrint('[DIARY ERROR] Stack trace: $stackTrace');
        throw Exception('Invalid response from server');
      }
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired or unauthorized');
    }

    if (response.statusCode == 422) {
      throw Exception('Validation error: ${response.body}');
    }

    throw Exception(
      'Failed to add diary: ${response.statusCode}. Response: ${response.body}',
    );
  }

  Future<Map<String, dynamic>> deleteDiary({
    required dynamic diaryId,
    required String token,
  }) async {
    final url = ApiConstants.deleteDiary(diaryId);

    final response = await _apiClient.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            debugPrint('[DIARY] Deleted diary successfully with ID: $diaryId');
            return decoded;
          }
        } catch (error) {
          debugPrint('[DIARY] Delete succeeded, could not decode body: $error');
        }
      }
      return {
        'message': 'Diary deleted successfully',
        'diary_id': diaryId,
      };
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired or unauthorized');
    }

    if (response.statusCode == 404) {
      throw Exception('Diary not found');
    }

    String errorMsg = response.body;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('detail')) {
        final detail = decoded['detail'];
        if (detail is String) {
          errorMsg = detail;
        } else if (detail is List && detail.isNotEmpty) {
          errorMsg = detail.first['msg']?.toString() ?? detail.toString();
        }
      }
    } catch (_) {}

    throw Exception(
      'Failed to delete diary (${response.statusCode}): $errorMsg',
    );
  }
}
