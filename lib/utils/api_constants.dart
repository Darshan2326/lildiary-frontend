class ApiConstants {
  static const String baseUrl = "http://10.52.102.107:8000";

  static const String login = "$baseUrl/login";
  static const String logout = "$baseUrl/logout";
  static const String me = "$baseUrl/me";
  static const String register = "$baseUrl/register";

  // User Profile Endpoints
  static const String profile = "$baseUrl/users/profile";
  static const String profileImage = "$baseUrl/users/profile/image";
  static const String profileEmailRequest =
      "$baseUrl/users/profile/email/request";
  static const String profileEmailVerify =
      "$baseUrl/users/profile/email/verify";

  static const String diaryByDate = "$baseUrl/diary/by_date";
  static const String addDiary = "$baseUrl/diary/add_diary";
  static String deleteDiary(dynamic diaryId) => "$baseUrl/diary/$diaryId";

  static const String memories = "$baseUrl/memories";
  static const String recapGenerate = "$baseUrl/memories/recap/generate";
  static String recapStatus(dynamic recapId) =>
      "$baseUrl/memories/recap/$recapId/status";
  static const String generateMemory = "$baseUrl/memories/generate";
  static String memoryById(dynamic id) => "$baseUrl/memories/$id";
  static String deleteMemory(dynamic id) => "$baseUrl/memories/$id";
  static String shareMemory(dynamic id) => "$baseUrl/memories/$id/share";
  static const String musicCatalog = "$baseUrl/memories/music";
  static String musicByCategory(String category) =>
      "$baseUrl/memories/music?category=$category";
  static String musicSearch(String query) =>
      "$baseUrl/memories/music?search=${Uri.encodeComponent(query)}";

  // Subscription & Razorpay Endpoints
  static const String subscriptionPlan = "$baseUrl/subscriptions/plan";
  static const String subscriptionStatus = "$baseUrl/subscriptions/status";
  static const String createSubscriptionOrder =
      "$baseUrl/subscriptions/create-order";
  static const String verifySubscriptionPayment =
      "$baseUrl/subscriptions/verify-payment";
}
