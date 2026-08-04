import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reactive singleton that holds the current auth state in memory.
/// All widgets/controllers should read [AuthService.isGuestObs] or
/// [AuthService.isLoggedInObs] instead of calling the async helpers
/// so that the UI rebuilds automatically when the state changes.
class AuthService {
  static const _keyIsGuest = 'is_guest';
  static const _keyAuthToken = 'auth_token';

  // ── Reactive observables ──────────────────────────────────────────────────
  static final RxBool isGuestObs = false.obs;
  static final RxBool isLoggedInObs = false.obs;

  /// Call once at app start (e.g. in SplashController) to hydrate the
  /// reactive state from SharedPreferences.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final guest = prefs.getBool(_keyIsGuest) ?? false;
    final token = prefs.getString(_keyAuthToken) ?? '';
    isGuestObs.value = guest;
    isLoggedInObs.value = token.isNotEmpty && !guest;
  }

  // ── Async helpers (still available for one-off checks) ────────────────────

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

  // ── State mutators ────────────────────────────────────────────────────────

  /// Set mode Guest – clears token and marks guest flag
  static Future<void> setGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsGuest, true);
    await prefs.remove(_keyAuthToken);
    isGuestObs.value = true;
    isLoggedInObs.value = false;
  }

  /// Called after a successful login – saves token and clears guest flag
  static Future<void> setLoggedIn(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
    await prefs.remove(_keyIsGuest);
    isGuestObs.value = false;
    isLoggedInObs.value = true;
  }

  /// Hapus semua sesi (untuk logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsGuest);
    await prefs.remove(_keyAuthToken);
    isGuestObs.value = false;
    isLoggedInObs.value = false;
  }
}
