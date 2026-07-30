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
import '../modules/main_navigation/controllers/main_navigation_controller.dart';
import '../modules/main_navigation/views/main_navigation_view.dart';
import '../modules/report_flood/controllers/report_flood_controller.dart';
import '../modules/report_flood/views/report_flood_view.dart';
import '../modules/saved_locations/controllers/saved_locations_controller.dart';
import '../modules/saved_locations/views/saved_locations_view.dart';
import '../modules/saved_locations/views/location_picker_map_view.dart';
import '../modules/profile/controllers/edit_profile_controller.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/profile/controllers/change_password_controller.dart';
import '../modules/profile/views/change_password_view.dart';
import '../modules/report_history/controllers/report_history_controller.dart';
import '../modules/report_history/views/report_history_view.dart';
import '../modules/report_history/controllers/report_detail_controller.dart';
import '../modules/report_history/views/report_detail_view.dart';
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
    GetPage(
      name: Routes.mainNavigation,
      page: () => const MainNavigationView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MainNavigationController>(() => MainNavigationController());
      }),
    ),
    GetPage(
      name: Routes.reportFlood,
      page: () => const ReportFloodView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ReportFloodController>(() => ReportFloodController());
      }),
    ),
    GetPage(
      name: Routes.savedLocations,
      page: () => const SavedLocationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SavedLocationsController>(() => SavedLocationsController());
      }),
    ),
    GetPage(
      name: Routes.addLocationMap,
      page: () => const LocationPickerMapView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LocationPickerMapController>(() => LocationPickerMapController());
      }),
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EditProfileController>(() => EditProfileController());
      }),
    ),
    GetPage(
      name: Routes.reportHistory,
      page: () => const ReportHistoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ReportHistoryController>(() => ReportHistoryController());
      }),
    ),
    GetPage(
      name: Routes.changePassword,
      page: () => const ChangePasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChangePasswordController>(() => ChangePasswordController());
      }),
    ),
    GetPage(
      name: Routes.reportDetail,
      page: () => const ReportDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ReportDetailController>(() => ReportDetailController());
      }),
    ),
  ];
}
