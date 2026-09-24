import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lildairy/models/user.dart';
import 'package:lildairy/utils/api_constants.dart';

import 'ApiClient/api_client.dart';

class MemoriesApi {
  final ApiClient _apiClient = ApiClient();

  Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'accept': 'application/json',
      };

  // ============================================
  // 1️⃣ CREATE MEMORY RECAP
  // POST /api/v1/memories/recap/generate
  // ============================================

  Future<Memories> createRecap({
    required String token,
    RecapGenerateRequest? request,
  }) async {
    final body = request?.toJson() ?? const RecapGenerateRequest().toJson();

    final response = await _apiClient.post(
      ApiConstants.recapGenerate,
      body,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 202 ||
        response.statusCode == 200 ||
        response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Response is not a JSON object');
        }
        final recap = Memories.fromJson(decoded);
        debugPrint(
            '[MEMORIES RECAP] Started recap generation job #${recap.recapId ?? recap.id}');
        return recap;
      } catch (e) {
        debugPrint('[MEMORIES RECAP ERROR] Could not parse generate response: $e');
        throw Exception('Invalid response format from memory recap generator');
      }
    }

    if (response.statusCode == 400) {
      final detail = _extractDetail(response.body);
      throw Exception(detail ?? 'Invalid input parameters for memory recap');
    }

    if (response.statusCode == 401) {
      throw Exception('Could not validate credentials');
    }

    throw Exception(
      'Failed to create recap (${response.statusCode}): ${_extractDetail(response.body) ?? response.body}',
    );
  }

  // ============================================
  // 2️⃣ GET RECAP STATUS & PROGRESS (POLLING)
  // GET /api/v1/memories/recap/{recap_id}/status
  // ============================================

  Future<Memories> getRecapStatus({
    required dynamic recapId,
    required String token,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.recapStatus(recapId),
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Status response is not a JSON object');
        }
        final statusMem = Memories.fromJson(decoded);
        debugPrint(
            '[MEMORIES STATUS] Recap #${recapId} -> status: ${statusMem.status}, progress: ${statusMem.progress}%');
        return statusMem;
      } catch (e) {
        debugPrint(
            '[MEMORIES STATUS ERROR] Could not parse status response: $e');
        throw Exception('Invalid status response from server');
      }
    }

    if (response.statusCode == 404) {
      throw Exception('Memory recap job not found');
    }

    if (response.statusCode == 401) {
      throw Exception('Could not validate credentials');
    }

    throw Exception(
      'Failed to get status (${response.statusCode}): ${_extractDetail(response.body) ?? response.body}',
    );
  }

  // ============================================
  // 3️⃣ LIST USER MEMORY RECAPS
  // GET /api/v1/memories
  // ============================================

  Future<List<Memories>> getAllMemories({required String token}) async {
    final response = await _apiClient.get(
      ApiConstants.memories,
      headers: _authHeaders(token),
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

        debugPrint('[MEMORIES] Loaded ${memories.length} memory recaps');
        return memories;
      } catch (error, stackTrace) {
        debugPrint('[MEMORIES ERROR] Could not parse memories: $error');
        debugPrint('[MEMORIES ERROR] Stack trace: $stackTrace');
        throw Exception('Invalid memories response from server');
      }
    }

    if (response.statusCode == 404 ||
        response.body.toLowerCase().contains('no memories found')) {
      debugPrint('[MEMORIES] No memories found');
      return <Memories>[];
    }

    if (response.statusCode == 401) {
      throw Exception('Could not validate credentials');
    }

    throw Exception(
      'Failed to load memories (${response.statusCode}): ${_extractDetail(response.body) ?? response.body}',
    );
  }

  // ============================================
  // 4️⃣ GET SINGLE MEMORY DETAIL
  // GET /api/v1/memories/{memory_id}
  // ============================================

  Future<Memories> getMemoryById({
    required dynamic memoryId,
    required String token,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.memoryById(memoryId),
      headers: _authHeaders(token),
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
      throw Exception('Could not validate credentials');
    }

    if (response.statusCode == 404) {
      throw Exception('Memory recap job not found');
    }

    throw Exception(
      'Failed to load memory #$memoryId (${response.statusCode}): ${_extractDetail(response.body) ?? response.body}',
    );
  }

  // ============================================
  // 5️⃣ QUICK RECAP TRIGGER (BACKWARD-COMPATIBLE)
  // POST /api/v1/memories/generate
  // ============================================

  Future<Map<String, dynamic>> generateMemoryQuick({
    required String token,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.generateMemory,
      {},
      headers: _authHeaders(token),
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
        debugPrint('[MEMORIES] Quick memory generation triggered');
        return decoded;
      } catch (error, stackTrace) {
        debugPrint('[MEMORIES ERROR] Could not parse generate response: $error');
        debugPrint('[MEMORIES ERROR] Stack trace: $stackTrace');
        throw Exception('Invalid response from server');
      }
    }

    if (response.statusCode == 401) {
      throw Exception('Could not validate credentials');
    }

    throw Exception(
      'Failed to generate memory (${response.statusCode}): ${_extractDetail(response.body) ?? response.body}',
    );
  }

  String? _extractDetail(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded.containsKey('detail')) {
        return decoded['detail']?.toString();
      }
    } catch (_) {}
    return null;
  }

  // ============================================
  // 6️⃣ GET BACKGROUND MUSIC CATALOG
  // GET /memories/music
  // ============================================

  Future<List<MusicTrack>> getMusicCatalog({
    String? category,
    required String token,
  }) async {
    final url = (category != null && category.trim().isNotEmpty)
        ? ApiConstants.musicByCategory(category.trim().toLowerCase())
        : ApiConstants.musicCatalog;

    final response = await _apiClient.get(
      url,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is! List) {
          throw const FormatException(
              'Music catalog response is not a JSON list');
        }
        final tracks = decoded
            .map((item) => MusicTrack.fromJson(item as Map<String, dynamic>))
            .where((t) => t.isActive)
            .toList();
        debugPrint('[MEMORIES MUSIC] Loaded ${tracks.length} music tracks');
        return tracks;
      } catch (error, stackTrace) {
        debugPrint(
            '[MEMORIES MUSIC ERROR] Could not parse music catalog: $error');
        debugPrint('[MEMORIES MUSIC ERROR] Stack trace: $stackTrace');
        throw Exception('Invalid music catalog response from server');
      }
    }

    if (response.statusCode == 401) {
      throw Exception('Could not validate credentials');
    }

    throw Exception(
      'Failed to load music catalog (${response.statusCode}): ${_extractDetail(response.body) ?? response.body}',
    );
  }
}
