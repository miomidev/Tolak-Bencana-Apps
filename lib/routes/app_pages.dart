import 'package:get/get.dart';
import '../modules/map/controllers/map_controller.dart';
import '../modules/map/views/map_view.dart';
import '../modules/splash/controllers/splash_controller.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/onboarding/controllers/onboarding_controller.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/auth/login/controllers/login_controller.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/register/controllers/register_controller.dart';
import '../modules/auth/register/views/register_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashController>(() => SplashController());
      }),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OnboardingController>(() => OnboardingController());
      }),
    ),
    GetPage(
      name: Routes.map,
      page: () => const MapView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MapController>(() => MapController());
      }),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RegisterController>(() => RegisterController());
      }),
    ),
  ];
}
