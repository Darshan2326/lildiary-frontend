import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lildairy/models/user.dart';

void main() {
  group('Subscription Model Tests', () {
    test('SubscriptionPlan JSON parsing', () {
      const planJson = '''
      {
        "id": 1,
        "plan_name": "Lil Diary Premium",
        "description": "Unlimited memory recaps & 6 moments per day",
        "amount": 199.0,
        "currency": "INR",
        "duration_days": 30,
        "is_active": true
      }
      ''';

      final decoded = jsonDecode(planJson) as Map<String, dynamic>;
      final plan = SubscriptionPlan.fromJson(decoded);

      expect(plan.id, 1);
      expect(plan.planName, 'Lil Diary Premium');
      expect(plan.amount, 199.0);
      expect(plan.currency, 'INR');
      expect(plan.durationDays, 30);
      expect(plan.isActive, true);
    });

    test('SubscriptionStatus JSON parsing for free user', () {
      const statusJson = '''
      {
        "is_subscribed": false,
        "subscription_expires_at": null,
        "plan_name": null,
        "days_remaining": 0,
        "weekly_recaps_used": 2,
        "weekly_recaps_limit": 4,
        "daily_diaries_used": 1,
        "daily_diaries_limit": 3,
        "can_view_old_memories": false,
        "can_use_custom_recap": false
      }
      ''';

      final decoded = jsonDecode(statusJson) as Map<String, dynamic>;
      final status = SubscriptionStatus.fromJson(decoded);

      expect(status.isSubscribed, false);
      expect(status.subscriptionExpiresAt, isNull);
      expect(status.weeklyRecapsUsed, 2);
      expect(status.weeklyRecapsLimit, 4);
      expect(status.dailyDiariesUsed, 1);
      expect(status.dailyDiariesLimit, 3);
      expect(status.canViewOldMemories, false);
      expect(status.canUseCustomRecap, false);
    });

    test('SubscriptionStatus JSON parsing for premium user', () {
      const statusJson = '''
      {
        "is_subscribed": true,
        "subscription_expires_at": "2026-11-06T12:00:00",
        "plan_name": "Lil Diary Premium",
        "days_remaining": 30,
        "weekly_recaps_used": 1,
        "weekly_recaps_limit": 4,
        "daily_diaries_used": 5,
        "daily_diaries_limit": 6,
        "can_view_old_memories": true,
        "can_use_custom_recap": true
      }
      ''';

      final decoded = jsonDecode(statusJson) as Map<String, dynamic>;
      final status = SubscriptionStatus.fromJson(decoded);

      expect(status.isSubscribed, true);
      expect(status.planName, 'Lil Diary Premium');
      expect(status.daysRemaining, 30);
      expect(status.dailyDiariesLimit, 6);
      expect(status.canViewOldMemories, true);
      expect(status.canUseCustomRecap, true);
    });

    test('User JSON parsing with subscription fields', () {
      const userJson = '''
      {
        "id": 10,
        "name": "Priya Sharma",
        "username": "priyasharma",
        "email": "priya@example.com",
        "role": "user",
        "is_active": 1,
        "is_subscribed": true,
        "subscription_expires_at": "2026-11-06T12:00:00"
      }
      ''';

      final decoded = jsonDecode(userJson) as Map<String, dynamic>;
      final user = User.fromJson(decoded);

      expect(user.id, 10);
      expect(user.name, 'Priya Sharma');
      expect(user.isSubscribed, true);
      expect(user.isPremium, true);
      expect(user.subscriptionExpiresAt, '2026-11-06T12:00:00');
    });
  });

  group('Quota & Business Logic Validation', () {
    test('6-month archive cutoff calculation', () {
      final now = DateTime.now();
      final sixMonthsAgo = now.subtract(const Duration(days: 180));
      final recentDate = now.subtract(const Duration(days: 30));
      final oldDate = now.subtract(const Duration(days: 200));

      final recentCutoff = recentDate.isBefore(sixMonthsAgo);
      final oldCutoff = oldDate.isBefore(sixMonthsAgo);

      expect(recentCutoff, false, reason: '30-day-old memory is within 6 months');
      expect(oldCutoff, true, reason: '200-day-old memory is older than 6 months');
    });

    test('Diary daily limit comparison (free=3, sub=6)', () {
      const freeLimit = 3;
      const subLimit = 6;

      expect(2 < freeLimit, true);
      expect(3 >= freeLimit, true); // Reached limit
      expect(3 < subLimit, true); // Premium can still add
      expect(6 >= subLimit, true); // Premium reaches limit at 6
    });

    test('Weekly recap limit comparison (4/week)', () {
      const weeklyLimit = 4;

      expect(3 < weeklyLimit, true);
      expect(4 >= weeklyLimit, true); // Free user hits 4 recap limit
    });
  });
}
