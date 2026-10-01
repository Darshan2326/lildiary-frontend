import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkException implements Exception {
  final String message;
  final dynamic originalError;
  final String? url;

  const NetworkException(
    this.message, {
    this.originalError,
    this.url,
  });

  @override
  String toString() => message;
}

class ApiClient {
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    try {
      final response = await http
          .get(uri, headers: requestHeaders)
          .timeout(const Duration(seconds: 15));

      _logResponse(
        method: 'GET',
        url: uri.toString(),
        response: response,
      );

      return response;
    } catch (error, stackTrace) {
      _handleError(
        method: 'GET',
        url: uri.toString(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<http.Response> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };
    final encodedBody = jsonEncode(body);
    final logBody = Map<String, dynamic>.from(body);

    if (logBody.containsKey('password')) {
      logBody['password'] = '***';
    }

    _logRequest(
      method: 'POST',
      url: uri.toString(),
      headers: requestHeaders,
      body: logBody,
    );

    try {
      final response = await http
          .post(
            uri,
            headers: requestHeaders,
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
      _handleError(
        method: 'POST',
        url: uri.toString(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<http.Response> patch(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };
    final encodedBody = jsonEncode(body);

    _logRequest(
      method: 'PATCH',
      url: uri.toString(),
      headers: requestHeaders,
      body: body,
    );

    try {
      final response = await http
          .patch(
            uri,
            headers: requestHeaders,
            body: encodedBody,
          )
          .timeout(const Duration(seconds: 15));

      _logResponse(
        method: 'PATCH',
        url: uri.toString(),
        response: response,
      );

      return response;
    } catch (error, stackTrace) {
      _handleError(
        method: 'PATCH',
        url: uri.toString(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<http.Response> postMultipart(
    String url, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (fields != null) {
      request.fields.addAll(fields);
    }
    if (files != null) {
      request.files.addAll(files);
    }

    _logMultipartRequest(
      method: 'POST (Multipart)',
      url: uri.toString(),
      headers: request.headers,
      fields: request.fields,
      fileCount: request.files.length,
    );

    try {
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(
        method: 'POST (Multipart)',
        url: uri.toString(),
        response: response,
      );

      return response;
    } catch (error, stackTrace) {
      _handleError(
        method: 'POST (Multipart)',
        url: uri.toString(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<http.Response> patchMultipart(
    String url, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('PATCH', uri);

    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (fields != null) {
      request.fields.addAll(fields);
    }
    if (files != null) {
      request.files.addAll(files);
    }

    _logMultipartRequest(
      method: 'PATCH (Multipart)',
      url: uri.toString(),
      headers: request.headers,
      fields: request.fields,
      fileCount: request.files.length,
    );

    try {
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(
        method: 'PATCH (Multipart)',
        url: uri.toString(),
        response: response,
      );

      return response;
    } catch (error, stackTrace) {
      _handleError(
        method: 'PATCH (Multipart)',
        url: uri.toString(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<http.Response> delete(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final request = http.Request('DELETE', uri);

    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      final logBody = Map<String, dynamic>.from(body);
      if (logBody.containsKey('password')) {
        logBody['password'] = '***';
      }
      _logRequest(
        method: 'DELETE',
        url: uri.toString(),
        headers: request.headers,
        body: logBody,
      );
      request.body = jsonEncode(body);
    }

    try {
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 15),
          );
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(
        method: 'DELETE',
        url: uri.toString(),
        response: response,
      );

      return response;
    } catch (error, stackTrace) {
      _handleError(
        method: 'DELETE',
        url: uri.toString(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _logMultipartRequest({
    required String method,
    required String url,
    required Map<String, String> headers,
    required Map<String, String> fields,
    required int fileCount,
  }) {
    debugPrint('');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('📤 API MULTIPART REQUEST');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('Method     : $method');
    debugPrint('URL        : $url');
    debugPrint('Headers    : ${jsonEncode(headers)}');
    debugPrint('Fields     : ${jsonEncode(fields)}');
    debugPrint('Files Count: $fileCount');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('');
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

  Never _handleError({
    required String method,
    required String url,
    required Object error,
    required StackTrace stackTrace,
  }) {
    _logError(
      method: method,
      url: url,
      error: error,
      stackTrace: stackTrace,
    );

    if (error is NetworkException) {
      throw error;
    }

    final errorString = error.toString().toLowerCase();

    if (error is SocketException ||
        error is http.ClientException ||
        errorString.contains('socketexception') ||
        errorString.contains('clientexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('connection reset') ||
        errorString.contains('connection closed')) {
      throw NetworkException(
        'Unable to connect to server. Please check your internet connection or server IP address.',
        originalError: error,
        url: url,
      );
    }

    if (error is TimeoutException ||
        errorString.contains('timeoutexception') ||
        errorString.contains('timed out')) {
      throw NetworkException(
        'Connection timed out. The server took too long to respond.',
        originalError: error,
        url: url,
      );
    }

    if (error is HandshakeException ||
        errorString.contains('handshakeexception') ||
        errorString.contains('certificate')) {
      throw NetworkException(
        'Secure connection failed. Please check SSL configuration.',
        originalError: error,
        url: url,
      );
    }

    if (error is HttpException) {
      throw NetworkException(
        'HTTP error: ${error.message}',
        originalError: error,
        url: url,
      );
    }

    if (error is Exception) {
      throw NetworkException(
        'Network error: ${error.toString().replaceAll('Exception: ', '')}',
        originalError: error,
        url: url,
      );
    }

    throw NetworkException(
      'An unexpected network error occurred.',
      originalError: error,
      url: url,
    );
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
