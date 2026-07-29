import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Laporkan titik banjir dengan GPS",
      "description": "Tandai lokasi banjir secara real-time dengan GPS akurat",
      "image": "assets/images/gps_logo.svg"
    },
    {
      "title": "Dapatkan notifikasi peringatan dini",
      "description": "Terima alert ketika ada potensi banjir di wilayahmu",
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

  void nextPage() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Get.offAllNamed(Routes.login);
    }
  }

  void skip() {
    Get.offAllNamed(Routes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
