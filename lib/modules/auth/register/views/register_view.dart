import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryTeal,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                      onTap: controller.goToLogin,
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
                    'Buat Akun Baru',
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
                    'Bergabung dan pantau banjir di indramayu',
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
                      _buildTextField(
                        label: 'Nama Lengkap',
                        hint: 'nama sesuai ktp',
                        controller: controller.nameController,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Username',
                        hint: 'contoh: udin123',
                        controller: controller.usernameController,
                        icon: Icons.alternate_email,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Alamat Email',
                        hint: 'nama@gmail.com',
                        controller: controller.emailController,
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Nomor Telepon',
                        hint: '+62 81x-xxx-xxx',
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        label: 'Kata Sandi',
                        hint: 'Masukkan kata sandi',
                        controller: controller.passwordController,
                        isHidden: controller.isPasswordHidden,
                        toggleVisibility: controller.togglePasswordVisibility,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        label: 'Ulangi Kata Sandi',
                        hint: 'Masukkan kata sandi',
                        controller: controller.confirmPasswordController,
                        isHidden: controller.isConfirmPasswordHidden,
                        toggleVisibility: controller.toggleConfirmPasswordVisibility,
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black45, fontSize: 10, height: 1.5),
                            children: [
                              const TextSpan(text: 'Dengan mendaftar, kamu menyetujui '),
                              TextSpan(
                                text: 'Syarat & Ketentuan',
                                style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()..onTap = () {},
                              ),
                              const TextSpan(text: ' serta '),
                              TextSpan(
                                text: 'Kebijakan Privasi',
                                style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()..onTap = () {},
                              ),
                              const TextSpan(text: '\nKALIWEDI.'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isFormValid.value && !controller.isLoading.value
                                ? controller.register
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
                                    'Daftar',
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun? ',
                            style: TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: controller.goToLogin,
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
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
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            prefixIcon: icon != null ? Icon(icon, color: Colors.black38) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required RxBool isHidden,
    required VoidCallback toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextField(
            controller: controller,
            obscureText: isHidden.value,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.black38),
              suffixIcon: IconButton(
                icon: Icon(
                  isHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.black38,
                ),
                onPressed: toggleVisibility,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      ],
    );
  }
}
