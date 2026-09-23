class ApiConstants {
  static const String baseUrl = "http://10.52.102.52:8001";

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

  static const String memories = "$baseUrl/memories";
  static const String generateMemory = "$baseUrl/memories/generate";
  static String memoryById(int id) => "$baseUrl/memories/$id";
}
