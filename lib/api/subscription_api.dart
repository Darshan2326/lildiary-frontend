import 'dart:convert';
import '../models/user.dart';
import '../utils/api_constants.dart';
import 'ApiClient/api_client.dart';

class SubscriptionApi {
  final ApiClient _apiClient = ApiClient();

  /// GET /subscriptions/plan - Fetch current subscription plan configured by admin
  Future<SubscriptionPlan> getPlan({String? token}) async {
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await _apiClient.get(
      ApiConstants.subscriptionPlan,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Subscription plan response is not a valid JSON object');
      }
      return SubscriptionPlan.fromJson(data);
    }

    throw Exception(
      'Failed to load subscription plan (${response.statusCode}): ${_extractErrorMsg(response)}',
    );
  }

  /// GET /subscriptions/status - Fetch user's subscription status and daily/weekly quotas
  Future<SubscriptionStatus> getStatus({required String token}) async {
    final response = await _apiClient.get(
      ApiConstants.subscriptionStatus,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Subscription status response is not a valid JSON object');
      }
      return SubscriptionStatus.fromJson(data);
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired or unauthorized');
    }

    throw Exception(
      'Failed to load subscription status (${response.statusCode}): ${_extractErrorMsg(response)}',
    );
  }

  /// POST /subscriptions/create-order - Create Razorpay order
  Future<Map<String, dynamic>> createOrder({required String token}) async {
    final response = await _apiClient.post(
      ApiConstants.createSubscriptionOrder,
      <String, dynamic>{},
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Create order response is not a valid JSON object');
      }
      return data;
    }

    throw Exception(
      'Failed to create payment order (${response.statusCode}): ${_extractErrorMsg(response)}',
    );
  }

  /// POST /subscriptions/verify-payment - Verify Razorpay signature and activate subscription
  Future<Map<String, dynamic>> verifyPayment({
    required String token,
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.verifySubscriptionPayment,
      <String, dynamic>{
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Verify payment response is not a valid JSON object');
      }
      return data;
    }

    throw Exception(
      'Payment verification failed (${response.statusCode}): ${_extractErrorMsg(response)}',
    );
  }

  String _extractErrorMsg(dynamic response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body.containsKey('detail')) {
        return body['detail'].toString();
      }
      if (body is Map && body.containsKey('message')) {
        return body['message'].toString();
      }
    } catch (_) {}
    return response.reasonPhrase ?? 'Unknown error';
  }
}
