import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String keyLogin = "isLoggedIn";
  static const String keyUsername = "username";

  static Future<void> login(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLogin, true);
    await prefs.setString(keyUsername, username);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLogin) ?? false;
  }
}
