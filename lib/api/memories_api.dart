import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lildairy/models/user.dart';
import 'package:lildairy/utils/api_constants.dart';

import 'ApiClient/api_client.dart';

class MemoriesApi {
  final ApiClient _apiClient = ApiClient();

  // ============================================
  // 1. GET ALL MEMORIES (/memories)
  // ============================================

  Future<List<Memories>> getAllMemories({required String token}) async {
    final response = await _apiClient.get(
      ApiConstants.memories,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is! List) {
          throw const FormatException('Memories response is not a JSON array');
        }

        final List<Memories> memories = decoded
            .map((item) => Memories.fromJson(item as Map<String, dynamic>))
            .toList();

        debugPrint('[MEMORIES] Loaded ${memories.length} memories');
        return memories;
      } catch (error, stackTrace) {
        debugPrint('[MEMORIES ERROR] Could not parse memories: $error');
        debugPrint('[MEMORIES ERROR] Stack trace: $stackTrace');
        throw Exception('Invalid memories response from server');
      }
    }

    if (response.statusCode == 404 ||
        response.body.toLowerCase().contains('no memories found')) {
      debugPrint('[MEMORIES] No memories found (404)');
      return <Memories>[];
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired or unauthorized');
    }

    throw Exception(
      'Failed to load memories: ${response.statusCode}. Response: ${response.body}',
    );
  }

  // ============================================
  // 2. GENERATE MEMORIES (/memories/generate)
  // ============================================

  Future<Map<String, dynamic>> generateMemory({required String token}) async {
    final response = await _apiClient.post(
      ApiConstants.generateMemory,
      {},
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
              'Generate memory response is not a JSON object');
        }
        debugPrint('[MEMORIES] Memory generation triggered successfully');
        return decoded;
      } catch (error, stackTrace) {
        debugPrint('[MEMORIES ERROR] Could not parse generate response: $error');
        debugPrint('[MEMORIES ERROR] Stack trace: $stackTrace');
        throw Exception('Invalid response from server');
      }
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired or unauthorized');
    }

    throw Exception(
      'Failed to generate memory: ${response.statusCode}. Response: ${response.body}',
    );
  }

  // ============================================
  // 3. GET MEMORY BY ID (/memories/{id})
  // ============================================

  Future<Memories> getMemoryById({
    required int memoryId,
    required String token,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.memoryById(memoryId),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Memory response is not a JSON object');
        }

        final memory = Memories.fromJson(decoded);
        debugPrint('[MEMORIES] Loaded memory #${memory.id} details');
        return memory;
      } catch (error, stackTrace) {
        debugPrint('[MEMORIES ERROR] Could not parse memory #$memoryId: $error');
        debugPrint('[MEMORIES ERROR] Stack trace: $stackTrace');
        throw Exception('Invalid memory response from server');
      }
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired or unauthorized');
    }

    if (response.statusCode == 404) {
      throw Exception('Memory not found');
    }

    throw Exception(
      'Failed to load memory #$memoryId: ${response.statusCode}. Response: ${response.body}',
    );
  }
}
