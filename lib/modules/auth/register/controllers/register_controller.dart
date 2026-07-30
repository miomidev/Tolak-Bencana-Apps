import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/network/api_client.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isFormValid = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_validateForm);
    usernameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    isFormValid.value = nameController.text.trim().isNotEmpty &&
                        usernameController.text.trim().isNotEmpty &&
                        emailController.text.trim().isNotEmpty &&
                        phoneController.text.trim().isNotEmpty &&
                        passwordController.text.isNotEmpty &&
                        confirmPasswordController.text.isNotEmpty;
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<void> register() async {
    if (!isFormValid.value) return;

    isLoading.value = true;
    try {
      final response = await ApiClient.dio.post(
        '/register',
        data: {
          'name': nameController.text.trim(),
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'password': passwordController.text,
          'password_confirmation': confirmPasswordController.text,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        final token = data['access_token'];

        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        Get.snackbar('Sukses', 'Registrasi berhasil',
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
          message = 'Registrasi gagal';
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

  void goToLogin() {
    Get.back(); // Karena kita pindah ke register dari login via toNamed
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
