import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_colors.dart';

class LocationPickerMapController extends GetxController {
  final Rx<LatLng> currentCenter = const LatLng(
    -6.3262,
    108.3248,
  ).obs; // Indramayu Center
  final RxString currentAddress = 'Menarik lokasi...'.obs;
  final RxBool isGeocoding = false.obs;
  final fm.MapController mapController = fm.MapController();

  @override
  void onInit() {
    super.onInit();
    // Fetch address for initial position
    resolveAddress(currentCenter.value);
  }

  Timer? _debounce;

  void updateCenter(LatLng newCenter) {
    currentCenter.value = newCenter;
    currentAddress.value = 'Mencari alamat...';
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      resolveAddress(newCenter);
    });
  }

  Future<void> resolveAddress(LatLng position) async {
    isGeocoding.value = true;
    try {
      // Try to retrieve address via geocoding
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final parts = [
          if (pm.street != null && pm.street!.isNotEmpty) pm.street,
          if (pm.subLocality != null && pm.subLocality!.isNotEmpty)
            pm.subLocality,
          if (pm.locality != null && pm.locality!.isNotEmpty) pm.locality,
          if (pm.subAdministrativeArea != null &&
              pm.subAdministrativeArea!.isNotEmpty)
            pm.subAdministrativeArea,
        ];
        currentAddress.value = parts.join(', ');
      } else {
        currentAddress.value =
            'Indramayu, Jawa Barat (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      }
    } catch (_) {
      // Offline / fallback
      currentAddress.value =
          'Desa Kaliwedi, Kec. Indramayu, Indramayu (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
    } finally {
      isGeocoding.value = false;
    }
  }

  void confirmSelection() {
    Get.back(
      result: {
        'latitude': currentCenter.value.latitude,
        'longitude': currentCenter.value.longitude,
        'address': currentAddress.value,
      },
    );
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> goToCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('GPS Nonaktif', 'Silakan aktifkan layanan lokasi GPS Anda.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Izin Ditolak', 'Izin lokasi tidak diberikan.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Izin Ditolak', 'Izin lokasi ditolak secara permanen. Buka pengaturan aplikasi.');
      return;
    }

    try {
      isGeocoding.value = true;
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      LatLng newPos = LatLng(position.latitude, position.longitude);
      mapController.move(newPos, 16.0);
      updateCenter(newPos);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapatkan lokasi saat ini.');
    } finally {
      isGeocoding.value = false;
    }
  }
}

class LocationPickerMapView extends StatelessWidget {
  const LocationPickerMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LocationPickerMapController());
    final title = Get.arguments?['title'] ?? 'Pilih Lokasi';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. OSM Map View
          fm.FlutterMap(
            mapController: controller.mapController,
            options: fm.MapOptions(
              initialCenter: controller.currentCenter.value,
              initialZoom: 14.0,
              minZoom: 10.5,
              maxZoom: 18.0,
              cameraConstraint: fm.CameraConstraint.containCenter(
                bounds: fm.LatLngBounds(
                  const LatLng(-6.6500, 107.8800),
                  const LatLng(-6.1800, 108.5500),
                ),
              ),
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  controller.updateCenter(camera.center);
                }
              },
            ),
            children: [
              fm.TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.kaliwedi_apps',
              ),
            ],
          ),

          // 2. Fixed Center Marker Pin Overlay
          const Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 36.0,
              ), // offset pin tip to point at center
              child: Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ),

          // Current Location FAB
          Positioned(
            bottom: 150,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'current_location_fab',
              backgroundColor: Colors.white,
              onPressed: controller.goToCurrentLocation,
              child: const Icon(Icons.my_location, color: AppColors.primaryTeal),
            ),
          ),

          // 3. Location info & confirmation card at bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi Terpilih',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(() {
                    return Row(
                      children: [
                        const Icon(
                          Icons.pin_drop_outlined,
                          size: 16,
                          color: Colors.black45,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.currentAddress.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (controller.isGeocoding.value)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  // Confirmation Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Pilih Lokasi Ini',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
