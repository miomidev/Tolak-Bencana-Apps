import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/network/api_client.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isPasswordHidden = true.obs;
  final isFormValid = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    isFormValid.value = emailController.text.trim().isNotEmpty &&
                        passwordController.text.trim().isNotEmpty;
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    if (!isFormValid.value) return;

    isLoading.value = true;
    try {
      // Use central ApiClient
      final response = await ApiClient.dio.post(
        '/login',
        data: {
          'login': emailController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['access_token'];

        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        Get.snackbar('Sukses', 'Login berhasil',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);

        // Navigate to main navigation layout
        Get.offAllNamed(Routes.mainNavigation);
      }
    } on DioException catch (e) {
      String message = 'Terjadi kesalahan jaringan';
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        } else if (data is Map && data.containsKey('errors')) {
          message = data['errors'].values.first[0];
        } else {
          message = 'Kredensial salah atau terjadi kesalahan';
        }
      }
      Get.snackbar('Gagal', message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void loginWithGoogle() {
    Get.snackbar('Info', 'Login Google belum diimplementasikan.',
        snackPosition: SnackPosition.BOTTOM);
  }

  void goToRegister() {
    Get.toNamed(Routes.register);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
