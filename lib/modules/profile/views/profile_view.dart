import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_helper.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_routes.dart';
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
        // ── Guest Mode: show login prompt ──────────────────────────────────
        if (controller.isGuest.value) {
          return _GuestProfilePrompt();
        }

        final user = controller.currentUser.value;
        final avatar = () {
          final url = resolveImageUrl(user?.avatarUrl);
          return url.isNotEmpty ? url : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.name ?? "User")}&background=0D8ABC&color=fff';
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
                      user?.name ?? 'Pengguna',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Username/Email
                    Text(
                      user?.email ?? '${user?.username ?? "pengguna"}@email.com',
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
                        title: 'Pengaturan Notifikasi',
                        onTap: () {
                          Get.toNamed(Routes.notificationSettings);
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

// ── Guest Profile Prompt ──────────────────────────────────────────────────────
class _GuestProfilePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
        return SingleChildScrollView(
          child: Column(
          children: [
            // Teal header (same style as logged-in)
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
              // Guest avatar placeholder
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.white38, width: 2),
                ),
                child: const Icon(Icons.person_outline, size: 54, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mode Tamu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Anda belum masuk ke akun',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Info card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, size: 36, color: AppColors.primaryTeal),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Login untuk Akses Penuh',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masuk atau daftar akun untuk mengakses profil, riwayat laporan, lokasi tersimpan, dan pengaturan notifikasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                // Feature list
                _FeatureRow(icon: Icons.person_outline, label: 'Edit profil & foto'),
                const SizedBox(height: 8),
                _FeatureRow(icon: Icons.assignment_outlined, label: 'Riwayat laporan bencana'),
                const SizedBox(height: 8),
                _FeatureRow(icon: Icons.place_outlined, label: 'Simpan lokasi favorit'),
                const SizedBox(height: 8),
                _FeatureRow(icon: Icons.notifications_none_outlined, label: 'Pengaturan notifikasi'),
                const SizedBox(height: 24),
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(Routes.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Masuk ke Akun',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Register button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.toNamed(Routes.register),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryTeal,
                      side: const BorderSide(color: AppColors.primaryTeal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Daftar Akun Baru',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // About & Help (still accessible for guests)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _GuestMenuItem(
                  icon: Icons.info_outline,
                  iconColor: const Color(0xFFE0F2FE),
                  iconAccent: Colors.blue.shade700,
                  title: 'Tentang Aplikasi',
                  onTap: () => Get.to(() => const AboutView()),
                ),
                Divider(color: Colors.grey.shade100, height: 1, indent: 60),
                _GuestMenuItem(
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

        const SizedBox(height: 24),
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
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryTeal),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
      ],
    );
  }
}

class _GuestMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconAccent;
  final String title;
  final VoidCallback onTap;

  const _GuestMenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconAccent,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}
