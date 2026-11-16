import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  /// Completed by [SplashView] once the logo has actually been painted.
  final Completer<void> _logoRendered = Completer<void>();

  bool get isLogoRendered => _logoRendered.isCompleted;

  /// Called by the splash screen when the logo frame is available.
  void markLogoRendered() {
    if (!_logoRendered.isCompleted) {
      _logoRendered.complete();
    }
  }

  /// Called by [SplashView] once, when the splash screen is first shown.
  Future<void> start() async {
    // Wait until the logo is visibly rendered (with a safety timeout so the
    // app can never get stuck on the splash), while hydrating auth state in
    // parallel.
    await Future.wait([
      _logoRendered.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      ),
      AuthService.init(),
    ]);

    // Keep the logo on screen briefly so it is clearly visible even when the
    // image decodes very fast.
    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final isGuest = prefs.getBool('is_guest') ?? false;
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    // If user is in guest mode, go straight to main navigation
    if (isGuest) {
      Get.offAllNamed(Routes.mainNavigation);
      return;
    }

    if (token != null && token.isNotEmpty) {
      try {
        // Attempt to verify token online
        final response = await ApiClient.dio.get('/user');
        if (response.statusCode == 200) {
          Get.offAllNamed(Routes.mainNavigation);
        } else {
          await AuthService.clearSession();
          Get.offAllNamed(Routes.login);
        }
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 401) {
          // Token is invalid/expired
          await AuthService.clearSession();
          Get.offAllNamed(Routes.login);
        } else {
          // Network connection error / offline - allow offline entry
          Get.offAllNamed(Routes.mainNavigation);
        }
      }
    } else {
      if (hasSeenOnboarding) {
        Get.offAllNamed(Routes.login);
      } else {
        Get.offAllNamed(Routes.onboarding);
      }
    }
  }
}
