import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../api/subscription_api.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class SubscriptionController extends GetxController {
  final SubscriptionApi _subscriptionApi = SubscriptionApi();
  late Razorpay _razorpay;

  final RxBool isLoading = false.obs;
  final RxBool isPaymentProcessing = false.obs;
  final RxBool isSubscribed = false.obs;
  final Rx<SubscriptionPlan?> plan = Rx<SubscriptionPlan?>(null);
  final Rx<SubscriptionStatus?> status = Rx<SubscriptionStatus?>(null);

  final RxInt weeklyRecapsUsed = 0.obs;
  final RxInt weeklyRecapsLimit = 4.obs;
  final RxInt dailyDiariesUsed = 0.obs;
  final RxInt dailyDiariesLimit = 3.obs;
  final RxBool canViewOldMemories = false.obs;
  final RxBool canUseCustomRecap = false.obs;
  String? lastOrderId;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    loadSubscriptionData();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  /// Load admin-set subscription plan and current user status
  Future<void> loadSubscriptionData() async {
    final token = StorageService.getToken();
    isLoading.value = true;
    try {
      // 1. Fetch active plan set by admin
      try {
        final fetchedPlan = await _subscriptionApi.getPlan(token: token);
        plan.value = fetchedPlan;
      } catch (e) {
        debugPrint("Notice: could not fetch plan: $e");
      }

      // 2. Fetch user status if logged in
      if (token != null && token.isNotEmpty) {
        try {
          final fetchedStatus = await _subscriptionApi.getStatus(token: token);
          status.value = fetchedStatus;
          isSubscribed.value = fetchedStatus.isSubscribed;
          weeklyRecapsUsed.value = fetchedStatus.weeklyRecapsUsed;
          weeklyRecapsLimit.value = fetchedStatus.weeklyRecapsLimit;
          dailyDiariesUsed.value = fetchedStatus.dailyDiariesUsed;
          dailyDiariesLimit.value = fetchedStatus.dailyDiariesLimit;
          canViewOldMemories.value = fetchedStatus.canViewOldMemories;
          canUseCustomRecap.value = fetchedStatus.canUseCustomRecap;
        } catch (e) {
          debugPrint("Notice: could not fetch user status: $e");
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Launch Razorpay Checkout with admin-set plan amount
  Future<void> startPayment(BuildContext context) async {
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Login Required",
        "Please log in to upgrade to Premium.",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isPaymentProcessing.value = true;
    try {
      final orderData = await _subscriptionApi.createOrder(token: token);

      final keyId = orderData['key_id']?.toString() ?? 'rzp_test_51bB8hWvS7qLzK';
      final orderId = orderData['order_id']?.toString() ?? '';
      lastOrderId = orderId;
      final amount = orderData['amount'] is num ? (orderData['amount'] as num).toInt() : 19900;
      final planName = orderData['plan_name']?.toString() ?? 'Lil Diary Premium';

      final options = {
        'key': keyId,
        'amount': amount,
        'name': 'Lil Diary',
        'description': planName,
        'order_id': orderId,
        'timeout': 300,
        'prefill': {
          'contact': '',
          'email': '',
        },
        'theme': {
          'color': '#0288D1',
        },
      };

      _razorpay.open(options);
    } catch (e) {
      isPaymentProcessing.value = false;
      Get.snackbar(
        "Error",
        "Could not initiate checkout: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Verify payment and activate subscription in backend
  Future<void> _processVerification({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      isPaymentProcessing.value = false;
      return;
    }

    try {
      await _subscriptionApi.verifyPayment(
        token: token,
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );

      isSubscribed.value = true;
      canUseCustomRecap.value = true;
      canViewOldMemories.value = true;
      dailyDiariesLimit.value = 6;

      await loadSubscriptionData();

      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.stars_rounded, color: Color(0xFFFFA000), size: 28),
              SizedBox(width: 8),
              Text(
                "Subscription Activated!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome to Lil Diary Premium! ✨\n\nYou now have unlimited access to:",
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 12),
              _buildFeatureBullet("🎨 Custom Memory Recaps (Themes, songs & dates)"),
              _buildFeatureBullet("📖 6 Diary moments per day"),
              _buildFeatureBullet("🕰️ Lifetime archive (Past 6+ months memories)"),
              _buildFeatureBullet("🎬 4 Memory recaps per week quota"),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0288D1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Get.back(),
              child: const Text("Awesome!"),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        "Verification Error",
        "Payment received but verification failed: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPaymentProcessing.value = false;
    }
  }

  /// Simulate payment success without needing active Razorpay credentials (useful in dev/sandbox)
  Future<void> simulateTestPayment() async {
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Login Required",
        "Please log in to upgrade to Premium.",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isPaymentProcessing.value = true;
    try {
      String orderId = lastOrderId ?? '';
      if (orderId.isEmpty) {
        final orderData = await _subscriptionApi.createOrder(token: token);
        orderId = orderData['order_id']?.toString() ?? 'order_simulated_${DateTime.now().millisecondsSinceEpoch}';
        lastOrderId = orderId;
      }

      await _processVerification(
        orderId: orderId,
        paymentId: 'pay_sandbox_${DateTime.now().millisecondsSinceEpoch}',
        signature: 'simulated_test_signature',
      );
    } catch (e) {
      isPaymentProcessing.value = false;
      Get.snackbar(
        "Simulation Error",
        "Could not simulate test payment: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Callback when Razorpay payment succeeds
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final orderId = response.orderId ?? (lastOrderId ?? '');
    final paymentId = response.paymentId ?? '';
    final signature = response.signature ?? '';

    await _processVerification(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
    );
  }

  static Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF0288D1), size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Callback when Razorpay payment fails
  void _handlePaymentError(PaymentFailureResponse response) {
    isPaymentProcessing.value = false;
    Get.snackbar(
      "Payment Cancelled / Failed",
      response.message ?? "The transaction was not completed. If using Test Mode, configure valid keys in backend .env or tap Test Sandbox below.",
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.brown.shade900,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          simulateTestPayment();
        },
        child: const Text(
          "Test Sandbox",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0288D1),
          ),
        ),
      ),
    );
  }

  /// Callback for external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External wallet selected: ${response.walletName}");
  }
}
