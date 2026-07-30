import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../../../core/network/api_client.dart';

class ChangePasswordController extends GetxController {
  final RxBool isLoading = false.obs;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxInt passwordStrength = 0.obs;

  @override
  void onInit() {
    super.onInit();
    newPasswordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final pass = newPasswordController.text;
    int strength = 0;
    if (pass.isNotEmpty) {
      if (pass.length >= 8) strength++;
      if (pass.contains(RegExp(r'[A-Z]')) || pass.contains(RegExp(r'[0-9]'))) strength++;
      if (pass.contains(RegExp(r'[!@#\$%\^&\*(),.?":{}|<>]'))) strength++;
      if (strength > 2) strength = 2;
    }
    passwordStrength.value = strength;
  }

  Future<void> changePassword() async {
    final currentPw = currentPasswordController.text.trim();
    final newPw = newPasswordController.text.trim();
    final confirmPw = confirmPasswordController.text.trim();

    if (currentPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      Get.snackbar('Gagal', 'Semua kolom isian wajib diisi!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (newPw.length < 8) {
      Get.snackbar('Gagal', 'Kata sandi baru minimal 8 karakter!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (newPw != confirmPw) {
      Get.snackbar('Gagal', 'Konfirmasi kata sandi baru tidak cocok!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiClient.dio.post(
        '/user/change-password',
        data: {
          'current_password': currentPw,
          'new_password': newPw,
          'new_password_confirmation': confirmPw,
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Sukses',
          'Kata sandi Anda berhasil diperbarui!',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back(); // Go back to profile screen
      }
    } on dio.DioException catch (e) {
      Get.snackbar(
        'Gagal Memperbarui',
        e.response?.data['message'] ?? 'Terjadi kesalahan server.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
