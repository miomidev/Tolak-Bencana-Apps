import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/notification_model.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Peringatan & Siaran',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          Obx(() {
            final unreadCount =
                controller.notifications.where((n) => !n.isRead).length;
            if (unreadCount > 0) {
              return IconButton(
                icon: const Icon(Icons.done_all_rounded),
                tooltip: 'Tandai Semua Dibaca',
                onPressed: () async {
                  await controller.markAllAsRead();
                  Get.snackbar(
                    'Berhasil',
                    'Semua notifikasi telah ditandai sebagai dibaca',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primaryTeal,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Perbarui',
            onPressed: () => controller.fetchNotifications(),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryTeal),
                  SizedBox(height: 16),
                  Text(
                    'Memuat notifikasi...',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Belum Ada Notifikasi',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pemberitahuan siaga bencana dan pembaruan laporan Anda akan muncul di sini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => controller.fetchNotifications(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Perbarui Sekarang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchNotifications(),
            color: AppColors.primaryTeal,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final notif = controller.notifications[index];
                return _buildNotificationCard(context, notif, controller);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notif,
      NotificationController controller) {
    Color borderAccent;
    IconData iconData;
    String badgeText;

    switch (notif.type) {
      case 'emergency_alert':
        borderAccent = const Color(0xFFE11D48);
        iconData = Icons.warning_rounded;
        badgeText = 'SIAGA 1 (BAHAYA)';
        break;
      case 'flood_alert':
        borderAccent = const Color(0xFFEA580C);
        iconData = Icons.warning_amber_rounded;
        badgeText = 'SIAGA 2 (WASPADA)';
        break;
      case 'report_update':
        borderAccent = const Color(0xFF16A34A);
        iconData = Icons.verified_outlined;
        badgeText = 'STATUS LAPORAN';
        break;
      default:
        borderAccent = const Color(0xFF0284C7);
        iconData = Icons.campaign_outlined;
        badgeText = 'SIARAN INFORMASI';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: notif.isRead ? 0.03 : 0.06),
            blurRadius: notif.isRead ? 6 : 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: notif.isRead
              ? const Color(0xFFE2E8F0)
              : borderAccent.withValues(alpha: 0.4),
          width: notif.isRead ? 1.0 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            controller.markAsRead(notif);
            _showNotificationDetail(context, notif);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  children: [
                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: borderAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(iconData, size: 13, color: borderAccent),
                          const SizedBox(width: 4),
                          Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: borderAccent,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Time Ago & Unread indicator
                    Text(
                      notif.timeAgo,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!notif.isRead) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEA580C),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  notif.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        notif.isRead ? FontWeight.w600 : FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Body snippet
                Text(
                  notif.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom bar inside card: "Klik untuk lihat detail"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notif.formattedDateTime,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Detail',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: borderAccent,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: borderAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows the full notification & broadcast message detail in a clean bottom sheet
  void _showNotificationDetail(BuildContext context, NotificationModel notif) {
    Color borderAccent;
    IconData iconData;
    String badgeText;
    Color bgGradientStart;

    switch (notif.type) {
      case 'emergency_alert':
        borderAccent = const Color(0xFFE11D48);
        iconData = Icons.emergency_rounded;
        badgeText = 'SIAGA 1 (BAHAYA)';
        bgGradientStart = const Color(0xFFFFF1F2);
        break;
      case 'flood_alert':
        borderAccent = const Color(0xFFEA580C);
        iconData = Icons.warning_amber_rounded;
        badgeText = 'SIAGA 2 (WASPADA)';
        bgGradientStart = const Color(0xFFFFF7ED);
        break;
      case 'report_update':
        borderAccent = const Color(0xFF16A34A);
        iconData = Icons.verified_outlined;
        badgeText = 'STATUS LAPORAN';
        bgGradientStart = const Color(0xFFF0FDF4);
        break;
      default:
        borderAccent = const Color(0xFF0284C7);
        iconData = Icons.campaign_outlined;
        badgeText = 'SIARAN INFORMASI';
        bgGradientStart = const Color(0xFFF0F9FF);
    }

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Top Category Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: bgGradientStart,
                border: Border(
                  bottom: BorderSide(
                    color: borderAccent.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: borderAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: borderAccent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: borderAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pusat Siaga & Informasi Tolak Bencana',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    tooltip: 'Tutup',
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    SelectableText(
                      notif.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Timestamp pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule,
                              size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text(
                            notif.formattedDateTime,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Label: Isi Pesan
                    const Text(
                      'ISI PESAN / INFORMASI:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Body Message Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: SelectableText(
                        notif.body,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFF1F5F9)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: '${notif.title}\n\n${notif.body}',
                        ));
                        Get.snackbar(
                          'Tersalin',
                          'Isi notifikasi berhasil disalin ke clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF1E293B),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(16),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Salin Pesan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
