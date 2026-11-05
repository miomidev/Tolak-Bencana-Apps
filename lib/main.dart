import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_colors.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/deep_link_service.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise auth state from SharedPreferences
  await AuthService.init();

  // Initialise notification service (registers as GetxService singleton)
  await Get.putAsync<NotificationService>(
    () => NotificationService().init(),
    permanent: true,
  );

  // Initialise deep link handling (registers as GetxService singleton)
  await Get.putAsync<DeepLinkService>(
    () => DeepLinkService().init(),
    permanent: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KALIWEDI Apps',
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        useMaterial3: true,
        textTheme: ThemeData(useMaterial3: true).textTheme.copyWith(
          displayLarge: const TextStyle(
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.w800,
            fontSize: 32,
            color: Colors.white,
          ),
          displayMedium: const TextStyle(
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
          titleLarge: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
          bodyLarge: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
