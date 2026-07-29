import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart' hide MapController;
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/map_controller.dart';

class MapView extends GetView<MapController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KALIWEDI Map'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: Obx(() {
        if (controller.isLoadingLocation.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(
              controller.currentLat.value,
              controller.currentLng.value,
            ),
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.kaliwedi_apps',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                    controller.currentLat.value,
                    controller.currentLng.value,
                  ),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.my_location,
                    color: AppColors.primaryBlue,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Buka halaman Lapor Banjir (segera dibuat)
          Get.snackbar('Info', 'Fitur Lapor akan segera dibuat', 
            backgroundColor: AppColors.primaryOrange, 
            colorText: AppColors.white
          );
        },
        label: const Text('Lapor Banjir', style: TextStyle(color: AppColors.white)),
        icon: const Icon(Icons.report_problem, color: AppColors.white),
        backgroundColor: AppColors.dangerRed,
      ),
    );
  }
}
