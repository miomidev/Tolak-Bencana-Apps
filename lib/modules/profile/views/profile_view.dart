import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_helper.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_routes.dart';
import '../../main_navigation/controllers/main_navigation_controller.dart';
import '../views/about_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller if not injected
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Obx(() {
        final user = controller.currentUser.value;
        final avatar = () {
          final url = resolveImageUrl(user?.avatarUrl);
          return url.isNotEmpty ? url : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.name ?? "kaliwedi")}&background=0D8ABC&color=fff';
        }();

        return SingleChildScrollView(
          child: Column(
            children: [
              // 1. Teal Header Block
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
                child: Column(
                  children: [
                    const Text(
                      'Profil Saya',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Avatar
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.white24,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(avatar),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      user?.name ?? 'kaliwedi',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Username/Email
                    Text(
                      '${user?.username ?? "kaliwedi"}@email.com',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Edit Profile Button
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed(Routes.editProfile),
                      icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                      label: const Text(
                        'Edit Profil',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. GPS Toggle Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.near_me_outlined, color: AppColors.primaryBlue, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GPS Selalu Aktif',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.gpsActive.value ? 'Lokasi aktif' : 'Lokasi tidak aktif',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: controller.gpsActive.value,
                        onChanged: controller.toggleGps,
                        activeThumbColor: AppColors.primaryTeal,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. First Action Group Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        iconColor: const Color(0xFFE0F2FE),
                        iconAccent: Colors.lightBlue.shade700,
                        title: 'Edit Profil',
                        onTap: () => Get.toNamed(Routes.editProfile),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.assignment_outlined,
                        iconColor: const Color(0xFFF3E8FF),
                        iconAccent: Colors.purple.shade700,
                        title: 'Riwayat Laporan',
                        onTap: () => Get.toNamed(Routes.reportHistory),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.place_outlined,
                        iconColor: const Color(0xFFDCFCE7),
                        iconAccent: Colors.green.shade700,
                        title: 'Lokasi Tersimpan',
                        onTap: () {
                          Get.toNamed(Routes.savedLocations);
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.notifications_none_outlined,
                        iconColor: const Color(0xFFFEF3C7),
                        iconAccent: Colors.amber.shade700,
                        title: 'Notifikasi',
                        onTap: () {
                          // Switch bottom tab index to Notif
                          if (Get.isRegistered<MainNavigationController>()) {
                            Get.find<MainNavigationController>().changeTab(3);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. Second Action Group Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.lock_outline,
                        iconColor: const Color(0xFFF3F4F6),
                        iconAccent: Colors.grey.shade700,
                        title: 'Ubah Kata Sandi',
                        onTap: () => Get.toNamed(Routes.changePassword),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        iconColor: const Color(0xFFE0F2FE),
                        iconAccent: Colors.blue.shade700,
                        title: 'Tentang Aplikasi',
                        onTap: () => Get.to(() => const AboutView()),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        iconColor: const Color(0xFFE2F0FD),
                        iconAccent: Colors.teal.shade700,
                        title: 'Bantuan',
                        onTap: () => Get.toNamed(Routes.help),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 5. Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(Routes.logout),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.shade100),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Version Footer
              Text(
                'Versi Aplikasi 1.4.2',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconAccent,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade100,
      height: 1,
      indent: 60,
    );
  }
}

