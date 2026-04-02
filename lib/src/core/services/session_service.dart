import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  //Inisialisasi Shared Preference
  static final PreferenceHandler _instance = PreferenceHandler._internal();

  factory PreferenceHandler() => _instance;
  PreferenceHandler._internal();

  //Key user
  static const _tokenKey = 'token';

  //CREATE
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_tokenKey, token);
  }

  //GET
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    var data = prefs.getString(_tokenKey);
    return data;
  }

  //DELETE
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
