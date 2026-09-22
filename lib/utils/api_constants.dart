class ApiConstants {
  static const String baseUrl = "http://192.168.1.4:8001";

  static const String login = "$baseUrl/login";
  static const String logout = "$baseUrl/logout";
  static const String me = "$baseUrl/me";

  static const String register = "$baseUrl/register";
  static const String diaryByDate = "$baseUrl/diary/by_date";
  static const String addDiary = "$baseUrl/diary/add_diary";

  static const String memories = "$baseUrl/memories";
  static const String generateMemory = "$baseUrl/memories/generate";
  static String memoryById(int id) => "$baseUrl/memories/$id";
}
