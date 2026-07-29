import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startSplash();
  }

  void _startSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    // Navigate to Onboarding screen, preventing user from going back to Splash
    Get.offAllNamed(Routes.onboarding);
  }
}
