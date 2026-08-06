import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/auth_service.dart';

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
        final token = data['access_token'] as String;

        // Save token AND clear guest flag via AuthService
        await AuthService.setLoggedIn(token);

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

  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web Client ID dari Google Cloud Console (OAuth 2.0 Web application)
    serverClientId: '192572861773-vhvm24fd41798j8e4j50gt45v8ts8t7q.apps.googleusercontent.com',
  );

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      // Sign out first to force account picker to show
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        Get.snackbar(
          'Gagal',
          'Tidak dapat mendapatkan token Google. Coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Send ID token to backend for verification
      final response = await ApiClient.dio.post(
        '/auth/google',
        data: {'id_token': idToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['access_token'] as String;

        await AuthService.setLoggedIn(token);

        Get.snackbar(
          'Sukses',
          'Login dengan Google berhasil',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed(Routes.mainNavigation);
      }
    } on DioException catch (e) {
      String message = 'Terjadi kesalahan jaringan';
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        }
      }
      Get.snackbar(
        'Gagal',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Login Google gagal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginAsGuest() async {
    await AuthService.setGuestMode();
    Get.offAllNamed(Routes.mainNavigation);
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.snackbar(
        'Mode Tamu Aktif',
        'Anda masuk sebagai tamu. Beberapa fitur tidak tersedia.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0D9488),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    });
  }

  void goToRegister() {
    Get.toNamed(Routes.register);
  }

  @override
  void onClose() {
    emailController.removeListener(_validateForm);
    passwordController.removeListener(_validateForm);
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
