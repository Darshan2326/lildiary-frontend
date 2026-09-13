// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;

// class ApiClient {
//   Future<http.Response> post(
//     String url,
//     Map<String, dynamic> body,
//   ) async {
//     final uri = Uri.parse(url);
//     final headers = {
//       'Content-Type': 'application/json',
//     };
//     final encodedBody = jsonEncode(body);
//     final logBody = Map<String, dynamic>.from(body)
//       ..update('password', (value) => '***', ifAbsent: () => '***');

//     debugPrint('[API REQUEST] POST $uri');
//     debugPrint('[API REQUEST] Headers: $headers');
//     debugPrint('[API REQUEST] Body: ${jsonEncode(logBody)}');

//     try {
//       final response = await http
//           .post(
//             uri,
//             headers: headers,
//             body: encodedBody,
//           )
//           .timeout(const Duration(seconds: 15));

//       debugPrint('[API RESPONSE] POST $uri');
//       debugPrint('[API RESPONSE] Status: ${response.statusCode}');
//       debugPrint('[API RESPONSE] Headers: ${response.headers}');
//       debugPrint('[API RESPONSE] Body: ${response.body}');

//       return response;
//     } catch (error, stackTrace) {
//       debugPrint('[API ERROR] POST $uri failed: $error');
//       debugPrint('[API ERROR] Stack trace: $stackTrace');
//       rethrow;
//     }
//   }
// }

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  Future<http.Response> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse(url);

    final headers = {
      'Content-Type': 'application/json',
    };

    final encodedBody = jsonEncode(body);

    // Hide sensitive fields from logs
    final logBody = Map<String, dynamic>.from(body);

    if (logBody.containsKey('password')) {
      logBody['password'] = '***';
    }

    _logRequest(
      method: 'POST',
      url: uri.toString(),
      headers: headers,
      body: logBody,
    );

    try {
      final response = await http
          .post(
            uri,
            headers: headers,
            body: encodedBody,
          )
          .timeout(const Duration(seconds: 15));

      _logResponse(
        method: 'POST',
        url: uri.toString(),
        response: response,
      );

      return response;
    } catch (error, stackTrace) {
      _logError(
        method: 'POST',
        url: uri.toString(),
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  void _logRequest({
    required String method,
    required String url,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
  }) {
    debugPrint('');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('📤 API REQUEST');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('Method  : $method');
    debugPrint('URL     : $url');
    debugPrint('Headers : ${jsonEncode(headers)}');
    debugPrint('Body    : ${_prettyJson(body)}');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('');
  }

  void _logResponse({
    required String method,
    required String url,
    required http.Response response,
  }) {
    debugPrint('');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('📥 API RESPONSE');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('Method      : $method');
    debugPrint('URL         : $url');
    debugPrint('Status Code : ${response.statusCode}');
    debugPrint('Status      : ${_statusText(response.statusCode)}');
    debugPrint('Headers     : ${jsonEncode(response.headers)}');
    debugPrint('Body        : ${_prettyResponse(response.body)}');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('');
  }

  void _logError({
    required String method,
    required String url,
    required Object error,
    required StackTrace stackTrace,
  }) {
    debugPrint('');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('❌ API ERROR');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('Method : $method');
    debugPrint('URL    : $url');
    debugPrint('Error  : $error');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('');
  }

  String _prettyJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  String _prettyResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      return _prettyJson(decoded);
    } catch (_) {
      return body;
    }
  }

  String _statusText(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return 'SUCCESS';
    }

    if (statusCode >= 400 && statusCode < 500) {
      return 'CLIENT ERROR';
    }

    if (statusCode >= 500) {
      return 'SERVER ERROR';
    }

    return 'UNKNOWN';
  }
}
