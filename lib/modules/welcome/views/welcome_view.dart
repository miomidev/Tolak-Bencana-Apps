import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo & App Name
              Image.asset(
                'assets/images/logo.png',
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24.0),
              const Text(
                'TOLAK BENCANA',
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Sistem Informasi & Tanggap Bencana',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textLight.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(flex: 2),

              // Welcome Text Description
              const Text(
                'Pantau situasi bencana di sekitar Anda secara real-time dan laporkan kejadian bencana untuk keselamatan bersama.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textDark,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 1),

              // Actions Block
              Column(
                children: [
                  // Guest Entry (Primary action)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to main navigation
                        Get.offAllNamed(Routes.mainNavigation);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Masuk Sebagai Tamu',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14.0),

                  // Login (Secondary action)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.toNamed(Routes.login);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryTeal),
                        foregroundColor: AppColors.primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Masuk ke Akun',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
