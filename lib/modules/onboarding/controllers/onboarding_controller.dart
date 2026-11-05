import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Laporkan titik bencana dengan GPS",
      "description": "Tandai lokasi bencana secara real-time dengan GPS akurat",
      "image": "assets/images/gps_logo.svg"
    },
    {
      "title": "Dapatkan notifikasi peringatan dini",
      "description": "Terima alert ketika ada potensi bencana di wilayahmu",
      "image": "assets/images/bell_logo.svg"
    },
    {
      "title": "Temukan rute evakuasi terdekat",
      "description": "Akses shelter dan jalur evakuasi paling aman",
      "image": "assets/images/warning_logo.svg"
    }
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() async {
    if (currentPage.value == 0) {
      // Minta izin akses lokasi saat klik lanjut di "Laporkan titik banjir dengan GPS"
      await Permission.location.request();
    } else if (currentPage.value == 1) {
      // Minta izin notifikasi saat klik lanjut di "Dapatkan notifikasi peringatan dini"
      await Permission.notification.request();
    }

    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
      Get.offAllNamed(Routes.login);
    }
  }

  void skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    Get.offAllNamed(Routes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
