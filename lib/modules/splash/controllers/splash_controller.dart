import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startSplash();
  }

  void _startSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      try {
        // Attempt to verify token online
        final response = await ApiClient.dio.get('/user');
        if (response.statusCode == 200) {
          Get.offAllNamed(Routes.mainNavigation);
        } else {
          Get.offAllNamed(Routes.login);
        }
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 401) {
          // Token is invalid/expired
          await prefs.remove('auth_token');
          Get.offAllNamed(Routes.login);
        } else {
          // Network connection error / offline - allow offline entry
          Get.offAllNamed(Routes.mainNavigation);
        }
      }
    } else {
      Get.offAllNamed(Routes.onboarding);
    }
  }
}
