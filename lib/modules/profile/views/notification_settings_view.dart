import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/notification_settings_controller.dart';

class NotificationSettingsView extends GetView<NotificationSettingsController> {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller jika belum
    Get.put(NotificationSettingsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Master Switch
            Container(
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
                    child: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Izinkan Notifikasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Terima pemberitahuan push di perangkat Anda',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.pushNotifications.value,
                    onChanged: controller.togglePushNotifications,
                    activeThumbColor: AppColors.primaryTeal,
                    activeTrackColor: AppColors.primaryTeal.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'KATEGORI NOTIFIKASI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            
            // Notification Categories List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.red.shade100,
                    iconAccent: Colors.red.shade700,
                    title: 'Peringatan Dini Banjir',
                    subtitle: 'Info mendesak tentang potensi dan status banjir di sekitarmu',
                    value: controller.floodAlerts.value,
                    onChanged: controller.toggleFloodAlerts,
                    enabled: controller.pushNotifications.value,
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.update,
                    iconColor: Colors.blue.shade50,
                    iconAccent: Colors.blue.shade700,
                    title: 'Pembaruan Laporan',
                    subtitle: 'Status laporan yang kamu buat atau ikuti',
                    value: controller.reportUpdates.value,
                    onChanged: controller.toggleReportUpdates,
                    enabled: controller.pushNotifications.value,
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.campaign_outlined,
                    iconColor: Colors.amber.shade50,
                    iconAccent: Colors.amber.shade700,
                    title: 'Info & Pengumuman',
                    subtitle: 'Berita, update sistem, dan panduan mitigasi',
                    value: controller.announcements.value,
                    onChanged: controller.toggleAnnouncements,
                    enabled: controller.pushNotifications.value,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required Color iconAccent,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: enabled ? iconColor : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: enabled ? iconAccent : Colors.grey, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: enabled ? AppColors.textDark : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.primaryTeal,
            activeTrackColor: AppColors.primaryTeal.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade100,
      height: 1,
      indent: 64, // sejajar dengan text
    );
  }
}
