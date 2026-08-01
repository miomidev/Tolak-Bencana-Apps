import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyIsGuest = 'is_guest';
  static const _keyAuthToken = 'auth_token';

  /// Cek apakah user sedang dalam mode Guest
  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsGuest) ?? false;
  }

  /// Cek apakah user sudah login (punya token dan bukan guest)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyAuthToken) ?? '';
    final guest = prefs.getBool(_keyIsGuest) ?? false;
    return token.isNotEmpty && !guest;
  }

  /// Set mode Guest
  static Future<void> setGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsGuest, true);
    await prefs.remove(_keyAuthToken);
  }

  /// Hapus semua sesi (untuk logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsGuest);
    await prefs.remove(_keyAuthToken);
  }
}
