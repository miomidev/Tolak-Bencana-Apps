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
      title: 'Tolak Bencana',
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          surface: Colors.white,
          onSurface: AppColors.textDark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        useMaterial3: true,
        textTheme: ThemeData.light(useMaterial3: true).textTheme.copyWith(
          displayLarge: const TextStyle(
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.w800,
            fontSize: 32,
            color: AppColors.textDark,
          ),
          displayMedium: const TextStyle(
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: AppColors.textDark,
          ),
          titleLarge: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.textDark,
          ),
          bodyLarge: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: AppColors.textDark,
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: AppColors.textDark,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          labelStyle: TextStyle(color: AppColors.textDark, fontSize: 14),
          prefixIconColor: Color(0xFF94A3B8),
          suffixIconColor: Color(0xFF94A3B8),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primaryGreen,
          selectionColor: Color(0x3315803D),
          selectionHandleColor: AppColors.primaryGreen,
        ),
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
