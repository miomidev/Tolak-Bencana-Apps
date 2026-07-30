import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../map/views/map_view.dart';
import '../../notification/views/notification_view.dart';
import '../controllers/main_navigation_controller.dart';
import '../../map/controllers/map_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../profile/views/profile_view.dart';
import '../../../routes/app_routes.dart';

class MainNavigationView extends GetView<MainNavigationController> {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject required controllers for child tabs if not already present
    if (!Get.isRegistered<MapController>()) {
      Get.lazyPut<MapController>(() => MapController());
    }
    if (!Get.isRegistered<DashboardController>()) {
      Get.lazyPut<DashboardController>(() => DashboardController());
    }
    if (!Get.isRegistered<NotificationController>()) {
      Get.lazyPut<NotificationController>(() => NotificationController());
    }

    final List<Widget> screens = [
      const DashboardView(),
      const MapView(),
      const SizedBox(), // Spacer for center FAB
      const NotificationView(),
      const ProfileView(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: screens,
          )),
      bottomNavigationBar: Obx(() {
        final int currentIdx = controller.currentIndex.value;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Beranda',
                    isActive: currentIdx == 0,
                    onTap: () => controller.changeTab(0),
                  ),
                  _buildNavItem(
                    icon: Icons.map_outlined,
                    activeIcon: Icons.map,
                    label: 'Peta',
                    isActive: currentIdx == 1,
                    onTap: () => controller.changeTab(1),
                  ),
                  // Middle: + button
                  InkWell(
                    onTap: () {
                      Get.toNamed(Routes.reportFlood);
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  _buildNavItem(
                    icon: Icons.notifications_none_outlined,
                    activeIcon: Icons.notifications,
                    label: 'Notifikasi',
                    isActive: currentIdx == 3,
                    onTap: () => controller.changeTab(3),
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profil',
                    isActive: currentIdx == 4,
                    onTap: () => controller.changeTab(4),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color color = isActive ? AppColors.primaryTeal : Colors.black45;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

