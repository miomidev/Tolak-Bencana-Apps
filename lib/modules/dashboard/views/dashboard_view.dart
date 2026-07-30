import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/report_model.dart';
import '../../../core/utils/image_helper.dart';
import '../controllers/dashboard_controller.dart';
import '../../main_navigation/controllers/main_navigation_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate if not already injected
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchDashboardData(),
          color: AppColors.primaryTeal,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Header (Search and App Title)
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left Section: Logo + App Name with PELAPORAN BANJIR title
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 36,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PELAPORAN BANJIR',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    'KALIWEDI',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Right Section: Status, Notif, Profile
                          Row(
                            children: [
                              // Online/Offline Status Badge
                              Obx(() {
                                final isOffline = controller.isOffline.value;
                                return GestureDetector(
                                  onTap: controller.toggleOfflineMode,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isOffline 
                                          ? Colors.black.withValues(alpha: 0.2) 
                                          : Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isOffline ? Colors.white30 : Colors.white24, 
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isOffline ? Icons.wifi_off : Icons.wifi, 
                                          color: isOffline ? Colors.white70 : Colors.white, 
                                          size: 12,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          isOffline ? 'Offline' : 'Online',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isOffline ? Colors.white70 : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 8),
                              // Notification Button
                              _buildHeaderIconButton(
                                icon: Icons.notifications_none_outlined,
                                onTap: () {
                                  if (Get.isRegistered<MainNavigationController>()) {
                                    Get.find<MainNavigationController>().changeTab(3);
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              // Profile Button
                              _buildHeaderIconButton(
                                icon: Icons.person_outline,
                                onTap: () {
                                  if (Get.isRegistered<MainNavigationController>()) {
                                    Get.find<MainNavigationController>().changeTab(4);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: controller.updateSearchQuery,
                          decoration: const InputDecoration(
                            hintText: 'Cari laporan banjir...',
                            hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.black45),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 1.5 Conditional Offline Banner
              Obx(() {
                if (!controller.isOffline.value) return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xFFFEF3C7), // Light peach/orange background
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.orange.shade800, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'Mode Offline â€” Peta tidak tersedia',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // 2. Statistics Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Obx(() {
                    final stats = controller.stats.value;
                    final activeCount = stats?.activeReports ?? 0;
                    final totalCount = stats?.totalReports ?? 0;
                    final percent = stats?.percentageVerified ?? 0;

                    return _buildCombinedStatsCard(
                      activeValue: activeCount.toString(),
                      totalValue: totalCount.toString(),
                      verifiedValue: '$percent%',
                    );
                  }),
                ),
              ),

              // 3. Feed Header & Sort Dropdown
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Laporan Terbaru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Obx(() => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButton<String>(
                              value: controller.sortBy.value,
                              underline: const SizedBox(),
                              icon: const Icon(Icons.arrow_drop_down, size: 20, color: Colors.black54),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              onChanged: (val) {
                                if (val != null) controller.updateSortBy(val);
                              },
                              items: const [
                                DropdownMenuItem(value: 'Terbaru', child: Text('Terbaru')),
                                DropdownMenuItem(value: 'Terdekat', child: Text('Terdekat')),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              // 4. Reports Feed List
              Obx(() {
                if (controller.isLoading.value && controller.allReports.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (controller.filteredReports.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.report_gmailerrorred_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'Tidak ada laporan ditemukan',
                            style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final report = controller.filteredReports[index];
                        return ReportCard(
                          report: report,
                          onLike: () => controller.toggleLike(report),
                          onComment: () => _showCommentsBottomSheet(context, report),
                        );
                      },
                      childCount: controller.filteredReports.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombinedStatsCard({
    required String activeValue,
    required String totalValue,
    required String verifiedValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                value: activeValue,
                label: 'Laporan Aktif',
                valueColor: const Color(0xFF0F767E), // Teal
              ),
            ),
            VerticalDivider(color: Colors.grey.shade200, width: 1, thickness: 1),
            Expanded(
              child: _buildStatItem(
                value: totalValue,
                label: 'Total Laporan',
                valueColor: const Color(0xFF1E3A8A), // Dark blue
              ),
            ),
            VerticalDivider(color: Colors.grey.shade200, width: 1, thickness: 1),
            Expanded(
              child: _buildStatItem(
                value: verifiedValue,
                label: 'Terverifikasi',
                valueColor: Colors.green.shade600, // Green
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showCommentsBottomSheet(BuildContext context, ReportModel report) {
    controller.fetchComments(report.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Handle indicator
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Komentar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const Divider(),
                  
                  // Comment List
                  Expanded(
                    child: Obx(() {
                      if (controller.isCommentsLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.currentComments.isEmpty) {
                        return const Center(
                          child: Text(
                            'Belum ada komentar. Tulis komentar pertama!',
                            style: TextStyle(color: Colors.black45),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.currentComments.length,
                        itemBuilder: (context, index) {
                          final comment = controller.currentComments[index];
                    final avatar = () {
                      final url = resolveImageUrl(comment.user?.avatarUrl);
                      return url.isNotEmpty ? url : 'https://ui-avatars.com/api/?name=${urlencode(comment.user?.name ?? "User")}';
                    }();
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(avatar),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            comment.user?.name ?? 'Anonim',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            comment.timeAgo,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment.comment,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const Divider(height: 1),
                  // Text input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.commentTextController,
                            decoration: InputDecoration(
                              hintText: 'Tulis komentar...',
                              hintStyle: const TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              fillColor: Colors.grey.shade100,
                              filled: true,
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: AppColors.primaryTeal),
                          onPressed: () => controller.addComment(report),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
  
  String urlencode(String str) {
    return Uri.encodeComponent(str);
  }

  Widget _buildHeaderIconButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const ReportCard({
    super.key,
    required this.report,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = () {
      final url = resolveImageUrl(report.user?.avatarUrl);
      return url.isNotEmpty ? url : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(report.user?.name ?? "User")}';
    }();

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(avatar),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.user?.name ?? 'Anonim',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              report.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    report.timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Image Section with Badges
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: report.photoUrl != null && report.photoUrl!.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            resolveImageUrl(report.photoUrl),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildMockGradientCard(report),
                          ),
                          _reportBadges(report),
                        ],
                      )
                    : _buildMockGradientCard(report),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              report.description,
              style: const TextStyle(
                fontSize: 13.5,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Divider
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 8),

            // Likes and Comments Count & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Like button
                    InkWell(
                      onTap: onLike,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              report.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: report.isLiked ? Colors.red : Colors.grey.shade500,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              report.likesCount.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: report.isLiked ? Colors.red : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Comment button
                    InkWell(
                      onTap: onComment,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey.shade500,
                              size: 19,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              report.commentsCount.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Share action
                IconButton(
                  icon: Icon(Icons.share_outlined, color: Colors.grey.shade500, size: 19),
                  onPressed: () {
                    // Trigger simple sharing dialogue simulation
                    Get.snackbar(
                      'Bagikan Laporan',
                      'Tautan laporan berhasil disalin!',
                      backgroundColor: AppColors.primaryTeal,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockGradientCard(ReportModel report) {
    List<Color> gradientColors;

    switch (report.severity.toLowerCase()) {
      case 'critical':
        gradientColors = [const Color(0xFF1E3A8A), const Color(0xFF0284C7)];
        break;
      case 'high':
        gradientColors = [const Color(0xFF0F767E), const Color(0xFF0D9488)];
        break;
      case 'medium':
        gradientColors = [const Color(0xFF115E59), const Color(0xFF14B8A6)];
        break;
      default:
        gradientColors = [const Color(0xFF065F46), const Color(0xFF10B981)];
    }

    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 14,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 14,
                  height: 55,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 14,
                  height: 35,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            ),
          ),
          _reportBadges(report),
        ],
      ),
    );
  }

  Widget _reportBadges(ReportModel report) {
    Color badgeColor;
    String severityText;
    String heightText;

    switch (report.severity.toLowerCase()) {
      case 'critical':
        badgeColor = const Color(0xFFEA580C);
        severityText = 'Siaga';
        heightText = '50 cm';
        break;
      case 'high':
        badgeColor = const Color(0xFFF97316);
        severityText = 'Siaga';
        heightText = '45 cm';
        break;
      case 'medium':
        badgeColor = const Color(0xFFEAB308);
        severityText = 'Waspada';
        heightText = '25 cm';
        break;
      default:
        badgeColor = const Color(0xFF84CC16);
        severityText = 'Waspada';
        heightText = '15 cm';
    }

    return Stack(
      children: [
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              severityText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 12),
                SizedBox(width: 4),
                Text(
                  'Foto lapangan',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop_outlined, color: Colors.white70, size: 12),
                const SizedBox(width: 4),
                Text(
                  heightText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
