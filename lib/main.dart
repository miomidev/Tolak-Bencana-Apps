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
        scaffoldBackgroundColor: AppColors.backgroundLight,
        useMaterial3: true,
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
