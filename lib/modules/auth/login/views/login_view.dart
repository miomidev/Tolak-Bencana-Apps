import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android: white icons
        statusBarBrightness: Brightness.dark, // iOS: white icons
      ),
      child: Scaffold(
        backgroundColor: AppColors.primaryTeal,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Selamat datang\nkembali! 👋',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Masuk untuk memantau situasi dan melaporkan bencana',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // White Card Form Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Email atau Username',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'nama@gmail.com / nama.user',
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixIcon: const Icon(Icons.mail_outline, color: Colors.black38),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryTeal),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Kata Sandi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => TextField(
                          controller: controller.passwordController,
                          obscureText: controller.isPasswordHidden.value,
                          decoration: InputDecoration(
                            hintText: 'Masukkan kata sandi',
                            hintStyle: const TextStyle(color: Colors.black38),
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.black38),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordHidden.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.black38,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primaryTeal),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed(Routes.forgotPassword),
                          child: const Text(
                            'Lupa kata sandi?',
                            style: TextStyle(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isFormValid.value && !controller.isLoading.value
                                ? controller.login
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              disabledBackgroundColor: Colors.grey.shade200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Masuk',
                                    style: TextStyle(
                                      color: controller.isFormValid.value
                                          ? Colors.white
                                          : Colors.black54,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'atau',
                              style: TextStyle(color: Colors.black38, fontSize: 12),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: controller.loginWithGoogle,
                          icon: SvgPicture.asset(
                            'assets/images/google_logo.svg',
                            width: 24,
                            height: 24,
                          ),
                          label: const Text(
                            'Masuk dengan Google',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? ',
                            style: TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: controller.goToRegister,
                            child: const Text(
                              'Daftar gratis',
                              style: TextStyle(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Guest login button
                      GestureDetector(
                        onTap: controller.loginAsGuest,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_outline, color: Colors.grey.shade600, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Lanjutkan sebagai Tamu',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
