import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi_go/src/data/models/auth_model.dart';

class LocalStorageService {
  static const _tokenKey = 'token';
  static const _userKey = 'user';
  static const _tokenExpiryKey = 'token_expiry';
  static const _unlimitedSessionKey = 'unlimited_session';

  // ✅ NEW: Get token with validation (returns null jika expired dan bukan unlimited session)
  Future<String?> getToken({bool checkExpiry = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null) return null;

    // Skip expiry check jika unlimited session aktif
    final isUnlimited = prefs.getBool(_unlimitedSessionKey) ?? false;
    if (isUnlimited || !checkExpiry) return token;

    // Check token expiry
    final expiryStr = prefs.getString(_tokenExpiryKey);
    if (expiryStr != null) {
      try {
        final expiry = DateTime.parse(expiryStr);
        if (DateTime.now().isAfter(expiry)) {
          // Token expired
          return null;
        }
      } catch (_) {
        // Jika parsing expiry gagal, anggap token valid
      }
    }

    return token;
  }

  Future<void> saveToken(String token, {DateTime? expiry}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    // Jika expiry tidak diberikan, set unlimited session
    if (expiry != null) {
      await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
      await prefs.setBool(_unlimitedSessionKey, false);
    } else {
      // Save as unlimited session
      await prefs.setBool(_unlimitedSessionKey, true);
    }
  }

  // ✅ NEW: Set unlimited session
  Future<void> setUnlimitedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_unlimitedSessionKey, true);
  }

  // ✅ NEW: Get unlimited session status
  Future<bool> isUnlimitedSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_unlimitedSessionKey) ?? false;
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_unlimitedSessionKey);
  }

  // Simpan seluruh object user sebagai JSON string
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Load user dari SharedPreferences
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userStr));
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Hapus semua saat logout
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
