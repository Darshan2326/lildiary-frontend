class ApiConstants {
  static const String baseUrl = "http://192.168.1.3:8001";

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
  static const String musicCatalog = "$baseUrl/memories/music";
  static String musicByCategory(String category) =>
      "$baseUrl/memories/music?category=$category";
}
