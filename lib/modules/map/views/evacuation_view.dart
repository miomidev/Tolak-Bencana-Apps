import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/evacuation_controller.dart';
import '../../../routes/app_routes.dart';

class EvacuationView extends StatelessWidget {
  const EvacuationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EvacuationController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDC2626),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emergency, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Jalur Evakuasi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.loadEvacuationRoutes,
            tooltip: 'Perbarui',
          ),
        ],
      ),
      body: Column(
        children: [
          // Emergency Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFDC2626),
                  Colors.red.shade800,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.yellow, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'REKOMENDASI SHELTER TERDEKAT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Diurutkan berdasarkan jarak terdekat dari lokasi Anda saat ini. Pergi ke shelter yang masih tersedia.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFDC2626)),
                      SizedBox(height: 16),
                      Text('Menghitung jalur terdekat...', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              if (controller.errorMessage.isNotEmpty && controller.results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off_outlined, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: controller.loadEvacuationRoutes,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFFDC2626),
                onRefresh: controller.loadEvacuationRoutes,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.results.length,
                  itemBuilder: (_, i) => _ShelterCard(
                    result: controller.results[i],
                    rank: i + 1,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ShelterCard extends StatelessWidget {
  final EvacuationResult result;
  final int rank;

  const _ShelterCard({required this.result, required this.rank});

  @override
  Widget build(BuildContext context) {
    final shelter = result.shelter;
    final isAvailable = result.remainingCapacity > 0;
    final occupancyPercent =
        shelter.capacity > 0 ? shelter.currentOccupancy / shelter.capacity : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: rank == 1 && isAvailable
            ? Border.all(color: Colors.green.shade400, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: rank == 1 && isAvailable
                        ? Colors.green.shade600
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: rank == 1 && isAvailable
                        ? const Icon(Icons.star, color: Colors.white, size: 18)
                        : Text(
                            '#$rank',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              shelter.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (rank == 1 && isAvailable)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: const Text(
                                'Terdekat',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              shelter.address,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Info strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _InfoChip(
                  icon: Icons.route,
                  label: '${result.distanceKm.toStringAsFixed(1)} km',
                  color: result.distanceKm < 3 ? AppColors.primaryTeal : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.people,
                  label: '${result.remainingCapacity} sisa',
                  color: result.statusColor,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: result.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result.statusLabel,
                    style: TextStyle(
                      color: result.statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Occupancy progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kapasitas Terisi',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    Text(
                      '${shelter.currentOccupancy}/${shelter.capacity} orang',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: occupancyPercent.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      occupancyPercent >= 1.0
                          ? Colors.red.shade700
                          : occupancyPercent > 0.8
                              ? Colors.orange.shade600
                              : Colors.green.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                if (shelter.contact != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.snackbar(
                          'Hubungi Shelter',
                          'Nomor: ${shelter.contact}',
                          snackPosition: SnackPosition.BOTTOM,
                          icon: const Icon(Icons.phone, color: Colors.white),
                          backgroundColor: AppColors.primaryTeal,
                          colorText: Colors.white,
                        );
                      },
                      icon: const Icon(Icons.phone_outlined, size: 16),
                      label: const Text('Hubungi', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryTeal,
                        side: BorderSide(color: AppColors.primaryTeal.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                // "Lihat Rute" button – opens route map
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        'Shelter Ditandai',
                        '${shelter.name} telah ditandai di peta.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.shade700,
                        colorText: Colors.white,
                      );
                    },
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Peta', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isAvailable
                        ? () async {
                            final ctrl = Get.find<EvacuationController>();
                            await ctrl.showRouteToShelter(result);
                            Get.toNamed(Routes.evacuationRoute);
                          }
                        : null,
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Lihat Rute', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAvailable ? const Color(0xFFDC2626) : Colors.grey,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
