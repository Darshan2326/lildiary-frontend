import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  static Future<bool> setToken(String token) async {
    return await _prefs.setString('token', token);
  }

  static String? getToken() {
    return _prefs.getString('token');
  }

  // Login status
  static Future<bool> setLoggedIn(bool value) async {
    return await _prefs.setBool('isLoggedIn', value);
  }

  static bool isLoggedIn() {
    return _prefs.getBool('isLoggedIn') ?? false;
  }

  // Clear all stored data
  static Future<bool> clear() async {
    return await _prefs.clear();
  }
}
