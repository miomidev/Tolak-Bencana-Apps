import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startSplash();
  }

  void _startSplash() async {
    // Show the logo briefly while hydrating auth state in parallel, so the
    // splash does not add extra waiting time on top of the session check.
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 3000)),
      AuthService.init(),
    ]);

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
