import 'package:flutter/material.dart';
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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Peringatan Dini'),
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchNotifications(),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'Tidak ada peringatan baru',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchNotifications(),
            color: AppColors.primaryTeal,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final notif = controller.notifications[index];
                return _buildNotificationCard(notif);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notif) {
    Color cardBg;
    Color borderAccent;
    String badgeText;

    switch (notif.type) {
      case 'emergency_alert':
        cardBg = const Color(0xFFFEF2F2); // very soft red
        borderAccent = AppColors.dangerRed;
        badgeText = 'SIAGA 1';
        break;
      case 'flood_alert':
        cardBg = const Color(0xFFFFF7ED); // soft orange
        borderAccent = AppColors.primaryOrange;
        badgeText = 'SIAGA 2';
        break;
      case 'report_update':
        cardBg = const Color(0xFFF0FDF4); // soft green
        borderAccent = Colors.green.shade700;
        badgeText = 'TERVERIFIKASI';
        break;
      default:
        cardBg = const Color(0xFFEFF6FF); // soft blue
        borderAccent = AppColors.primaryBlue;
        badgeText = 'INFO';
    }

    return GestureDetector(
      onTap: () => controller.markAsRead(notif),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border(
            left: BorderSide(color: borderAccent, width: 5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with Badge and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: borderAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: borderAccent,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      notif.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (!notif.isRead) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              notif.title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: notif.isRead ? Colors.black87 : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            // Body description
            Text(
              notif.body,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
