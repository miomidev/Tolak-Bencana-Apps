import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryTeal,
      body: SafeArea(
        bottom: false,
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: controller.goBack,
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
                  const SizedBox(height: 28),
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _stepIcon(),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _stepTitle(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _stepSubtitle(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Step indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                children: List.generate(3, (i) {
                  final active = i < controller.step.value;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 4,
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // White Form Card
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F8FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: _buildStepBody(context),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  // ------------- per-step helpers ---------------

  IconData _stepIcon() {
    switch (controller.step.value) {
      case 2:
        return Icons.mark_email_read_outlined;
      case 3:
        return Icons.lock_reset_outlined;
      default:
        return Icons.lock_open_outlined;
    }
  }

  String _stepTitle() {
    switch (controller.step.value) {
      case 2:
        return 'Verifikasi OTP';
      case 3:
        return 'Buat Kata Sandi Baru';
      default:
        return 'Lupa Kata Sandi?';
    }
  }

  String _stepSubtitle() {
    switch (controller.step.value) {
      case 2:
        return 'Masukkan 6 digit kode yang dikirim ke\n${controller.email.value}';
      case 3:
        return 'Buat kata sandi baru yang kuat dan\nmudah diingat';
      default:
        return 'Masukkan email terdaftar Anda untuk\nmenerima kode verifikasi OTP';
    }
  }

  Widget _buildStepBody(BuildContext context) {
    switch (controller.step.value) {
      case 2:
        return _buildOtpStep(context);
      case 3:
        return _buildNewPasswordStep(context);
      default:
        return _buildEmailStep(context);
    }
  }

  // --------- Step 1: Email -----------
  Widget _buildEmailStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EMAIL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'nama@gmail.com',
                    hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(Icons.mail_outline, color: Color(0xFF94A3B8), size: 18),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.sendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              disabledBackgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Kirim Kode OTP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        )),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: RichText(
              text: const TextSpan(
                text: 'Ingat kata sandi? ',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                children: [
                  TextSpan(
                    text: 'Masuk',
                    style: TextStyle(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --------- Step 2: OTP verification -----------
  Widget _buildOtpStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // OTP boxes row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _buildOtpBox(i)),
        ),
        const SizedBox(height: 8),

        // Hidden text field for OTP input behind the UI
        Opacity(
          opacity: 0,
          child: SizedBox(
            height: 0,
            child: TextField(
              controller: controller.otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
            ),
          ),
        ),

        // Actual visible OTP input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KODE OTP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    letterSpacing: 12,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'â€¢ â€¢ â€¢ â€¢ â€¢ â€¢',
                    hintStyle: TextStyle(
                      color: Colors.black26,
                      fontSize: 22,
                      letterSpacing: 8,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(Icons.pin_outlined, color: Color(0xFF94A3B8), size: 18),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Resend
        Row(
          children: [
            const Text(
              'Tidak menerima kode? ',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            GestureDetector(
              onTap: controller.sendOtp,
              child: const Text(
                'Kirim ulang',
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              disabledBackgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Verifikasi Kode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        )),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return Obx(() {
      final otp = controller.otpController.text;
      final hasChar = otp.length > index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 52,
        decoration: BoxDecoration(
          color: hasChar ? AppColors.primaryTeal.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasChar ? AppColors.primaryTeal : Colors.grey.shade200,
            width: hasChar ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            hasChar ? 'â€¢' : '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTeal,
            ),
          ),
        ),
      );
    });
  }

  // --------- Step 3: New Password -----------
  Widget _buildNewPasswordStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Password fields card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // New password
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KATA SANDI BARU',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() => TextField(
                      controller: controller.newPasswordController,
                      obscureText: controller.isNewPasswordHidden.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Minimal 8 karakter',
                        hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        suffixIcon: GestureDetector(
                          onTap: () => controller.isNewPasswordHidden.toggle(),
                          child: Icon(
                            controller.isNewPasswordHidden.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF94A3B8),
                            size: 18,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE2E8F0)),
              // Confirm password
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KONFIRMASI KATA SANDI BARU',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() => TextField(
                      controller: controller.confirmPasswordController,
                      obscureText: controller.isConfirmPasswordHidden.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Ulangi kata sandi baru',
                        hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        suffixIcon: GestureDetector(
                          onTap: () => controller.isConfirmPasswordHidden.toggle(),
                          child: Icon(
                            controller.isConfirmPasswordHidden.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF94A3B8),
                            size: 18,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Kekuatan kata sandi card
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                'Kekuatan Kata Sandi: ${controller.strengthLabel}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              )),
              const SizedBox(height: 10),
              Obx(() => Row(
                children: List.generate(4, (i) {
                  final filled = i < controller.passwordStrength.value;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      height: 5,
                      decoration: BoxDecoration(
                        color: filled ? controller.strengthColor : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              )),
              const SizedBox(height: 8),
              Obx(() {
                final pw = controller.newPasswordController.text;
                return pw.isNotEmpty && pw.length < 8
                    ? Text(
                        'Minimal 8 karakter',
                        style: TextStyle(
                          fontSize: 11,
                          color: controller.strengthColor,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : const SizedBox.shrink();
              }),
            ],
          ),
        ),
        const SizedBox(height: 28),

        Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              disabledBackgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        )),
      ],
    );
  }
}
