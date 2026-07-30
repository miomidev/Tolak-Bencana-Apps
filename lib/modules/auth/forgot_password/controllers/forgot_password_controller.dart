import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isNewPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final RxString email = ''.obs;
  final RxString devOtp = ''.obs; // only for dev/testing

  // Password strength 0-4
  final RxInt passwordStrength = 0.obs;

  // Step: 1=email, 2=otp, 3=new password
  final RxInt step = 1.obs;

  @override
  void onInit() {
    super.onInit();
    newPasswordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    final pw = newPasswordController.text;
    int strength = 0;
    if (pw.length >= 8) strength++;
    if (pw.contains(RegExp(r'[A-Z]'))) strength++;
    if (pw.contains(RegExp(r'[0-9]'))) strength++;
    if (pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength++;
    passwordStrength.value = strength;
  }

  Future<void> sendOtp() async {
    final mail = emailController.text.trim();
    if (mail.isEmpty || !GetUtils.isEmail(mail)) {
      Get.snackbar('Peringatan', 'Masukkan email yang valid.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    isLoading.value = true;
    try {
      final response = await ApiClient.dio.post('/forgot-password', data: {'email': mail});
      if (response.statusCode == 200) {
        email.value = mail;
        // Dev only: grab OTP from response
        devOtp.value = response.data['otp']?.toString() ?? '';
        step.value = 2;
        Get.snackbar(
          'OTP Dikirim',
          devOtp.value.isNotEmpty
              ? 'Kode OTP (dev): ${devOtp.value}'
              : 'Cek email Anda untuk kode OTP.',
          backgroundColor: const Color(0xFF0F767E),
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Email tidak ditemukan atau terjadi kesalahan.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.length != 6) {
      Get.snackbar('Peringatan', 'Masukkan kode OTP 6 digit.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    isLoading.value = true;
    try {
      final response = await ApiClient.dio.post('/verify-reset-token', data: {
        'email': email.value,
        'otp': otp,
      });
      if (response.statusCode == 200) {
        step.value = 3;
      }
    } catch (e) {
      Get.snackbar('Kode Salah', 'Kode OTP tidak valid atau sudah kedaluwarsa.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final newPw = newPasswordController.text.trim();
    final confirmPw = confirmPasswordController.text.trim();

    if (newPw.length < 8) {
      Get.snackbar('Peringatan', 'Kata sandi minimal 8 karakter.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (newPw != confirmPw) {
      Get.snackbar('Peringatan', 'Konfirmasi kata sandi tidak cocok.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiClient.dio.post('/reset-password', data: {
        'email': email.value,
        'otp': otpController.text.trim(),
        'password': newPw,
        'password_confirmation': confirmPw,
      });
      if (response.statusCode == 200) {
        Get.snackbar(
          'Berhasil!',
          'Kata sandi berhasil diubah. Silakan masuk.',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan saat mengatur ulang kata sandi.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() {
    if (step.value > 1) {
      step.value--;
    } else {
      Get.back();
    }
  }

  String get strengthLabel {
    switch (passwordStrength.value) {
      case 0:
      case 1:
        return 'Lemah';
      case 2:
        return 'Sedang';
      case 3:
        return 'Kuat';
      case 4:
        return 'Sangat Kuat';
      default:
        return '';
    }
  }

  Color get strengthColor {
    switch (passwordStrength.value) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      case 4:
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
