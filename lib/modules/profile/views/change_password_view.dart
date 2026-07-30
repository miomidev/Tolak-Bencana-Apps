import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 18),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ),
        title: const Text(
          'Ubah Kata Sandi',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Fields Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPasswordField(
                      label: 'KATA SANDI SEKARANG',
                      controller: controller.currentPasswordController,
                      hintText: 'Masukkan kata sandi lama',
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F5F9)),
                    _buildPasswordField(
                      label: 'KATA SANDI BARU',
                      controller: controller.newPasswordController,
                      hintText: 'Min. 8 karakter',
                      showStrengthIndicator: true,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F5F9)),
                    _buildPasswordField(
                      label: 'KONFIRMASI KATA SANDI BARU',
                      controller: controller.confirmPasswordController,
                      hintText: 'Ulangi kata sandi baru',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primaryTeal.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Simpan Kata Sandi',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool showStrengthIndicator = false,
  }) {
    final RxBool isObscured = true.obs;

    return Obx(() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: isObscured.value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: hintText,
                      hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => isObscured.toggle(),
                  child: Icon(
                    isObscured.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ),
              ],
            ),
            if (showStrengthIndicator) ...[
              const SizedBox(height: 8),
              _buildStrengthIndicator(),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildStrengthIndicator() {
    final controller = Get.find<ChangePasswordController>();
    return Obx(() {
      final strength = controller.passwordStrength.value;
      
      // Determine colors and labels
      Color color1 = Colors.grey.shade300;
      Color color2 = Colors.grey.shade300;
      Color color3 = Colors.grey.shade300;
      String label = 'Terlalu Pendek';
      Color labelColor = Colors.grey.shade500;

      if (controller.newPasswordController.text.isNotEmpty) {
        if (strength == 0) {
          color1 = Colors.red.shade400;
          label = 'Lemah';
          labelColor = Colors.red.shade600;
        } else if (strength == 1) {
          color1 = Colors.orange.shade400;
          color2 = Colors.orange.shade400;
          label = 'Sedang';
          labelColor = Colors.orange.shade700;
        } else if (strength == 2) {
          color1 = Colors.green.shade500;
          color2 = Colors.green.shade500;
          color3 = Colors.green.shade500;
          label = 'Kuat';
          labelColor = Colors.green.shade700;
        }
      }

      return Row(
        children: [
          Expanded(child: _bar(color1)),
          const SizedBox(width: 4),
          Expanded(child: _bar(color2)),
          const SizedBox(width: 4),
          Expanded(child: _bar(color3)),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: labelColor,
            ),
          ),
        ],
      );
    });
  }

  Widget _bar(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
