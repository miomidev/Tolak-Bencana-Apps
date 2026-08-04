import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import '../../../core/models/shelter_model.dart';
import '../../../core/network/api_client.dart';
import '../../map/controllers/map_controller.dart';

class EvacuationResult {
  final ShelterModel shelter;
  final double distanceKm;
  final int remainingCapacity;
  final String statusLabel;
  final Color statusColor;

  EvacuationResult({
    required this.shelter,
    required this.distanceKm,
    required this.remainingCapacity,
    required this.statusLabel,
    required this.statusColor,
  });
}

class EvacuationController extends GetxController {
  final RxList<EvacuationResult> results = <EvacuationResult>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Route state ──────────────────────────────────────────────────────────
  /// The shelter currently being routed to (null = none)
  final Rxn<EvacuationResult> activeRoute = Rxn<EvacuationResult>();
  /// Decoded polyline points from OSRM
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool isRoutingLoading = false.obs;
  final RxString routeDistance = ''.obs;
  final RxString routeDuration = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvacuationRoutes();
  }

  /// Haversine formula – menghitung jarak dua koordinat dalam KM
  double _haversineDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const R = 6371.0; // radius bumi dalam km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  Future<void> loadEvacuationRoutes() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Ambil lokasi user dari MapController
      double userLat = -6.3262;
      double userLng = 108.3243;
      if (Get.isRegistered<MapController>()) {
        final mapCtrl = Get.find<MapController>();
        userLat = mapCtrl.currentLat.value;
        userLng = mapCtrl.currentLng.value;
      }

      // Ambil data shelter dari API atau gunakan yang sudah ada di MapController
      List<ShelterModel> shelters = [];
      if (Get.isRegistered<MapController>() &&
          Get.find<MapController>().shelters.isNotEmpty) {
        shelters = Get.find<MapController>().shelters.toList();
      } else {
        final response = await ApiClient.dio.get('/shelters');
        if (response.statusCode == 200) {
          final data = response.data;
          final list = data['data'] as List? ?? [];
          shelters =
              list.map((j) => ShelterModel.fromJson(j as Map<String, dynamic>)).toList();
        }
      }

      // Hitung jarak ke tiap shelter & filter yang aktif
      final List<EvacuationResult> computed = [];
      for (final s in shelters) {
        if (s.status != 'active') continue;

        final dist = _haversineDistance(userLat, userLng, s.latitude, s.longitude);
        final remaining = s.capacity - s.currentOccupancy;

        String statusLabel;
        Color statusColor;

        if (remaining <= 0) {
          statusLabel = 'Penuh';
          statusColor = Colors.red.shade700;
        } else if (remaining < 20) {
          statusLabel = 'Hampir Penuh';
          statusColor = Colors.orange.shade700;
        } else {
          statusLabel = 'Tersedia';
          statusColor = Colors.green.shade700;
        }

        computed.add(EvacuationResult(
          shelter: s,
          distanceKm: dist,
          remainingCapacity: remaining,
          statusLabel: statusLabel,
          statusColor: statusColor,
        ));
      }

      // Urutkan: yang tidak penuh dulu, lalu berdasarkan jarak
      computed.sort((a, b) {
        if (a.remainingCapacity > 0 && b.remainingCapacity <= 0) return -1;
        if (a.remainingCapacity <= 0 && b.remainingCapacity > 0) return 1;
        return a.distanceKm.compareTo(b.distanceKm);
      });

      results.assignAll(computed);

      if (computed.isEmpty) {
        errorMessage.value = 'Tidak ada shelter aktif yang ditemukan.';
      }
    } catch (e) {
      // Fallback demo data jika offline
      _loadOfflineDemo();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadOfflineDemo() {
    double userLat = -6.3262;
    double userLng = 108.3243;
    if (Get.isRegistered<MapController>()) {
      userLat = Get.find<MapController>().currentLat.value;
      userLng = Get.find<MapController>().currentLng.value;
    }

    final demoShelters = [
      ShelterModel(
        id: 'sh-1', name: 'Balai Desa Kaliwedi',
        latitude: -6.3250, longitude: 108.3230,
        address: 'Jl. Balai Desa No. 1, Kaliwedi',
        capacity: 200, currentOccupancy: 45, status: 'active', contact: '08123456789',
      ),
      ShelterModel(
        id: 'sh-2', name: 'Gedung Sekolah SDN Kaliwedi',
        latitude: -6.3210, longitude: 108.3300,
        address: 'Jl. Pendidikan No. 5, Kaliwedi',
        capacity: 150, currentOccupancy: 140, status: 'active', contact: '08234567890',
      ),
      ShelterModel(
        id: 'sh-3', name: 'Masjid Agung Indramayu',
        latitude: -6.3400, longitude: 108.3150,
        address: 'Jl. Masjid Agung, Indramayu',
        capacity: 300, currentOccupancy: 50, status: 'active', contact: null,
      ),
    ];

    final List<EvacuationResult> computed = [];
    for (final s in demoShelters) {
      final dist = _haversineDistance(userLat, userLng, s.latitude, s.longitude);
      final remaining = s.capacity - s.currentOccupancy;

      String statusLabel;
      Color statusColor;
      if (remaining <= 0) {
        statusLabel = 'Penuh';
        statusColor = Colors.red.shade700;
      } else if (remaining < 20) {
        statusLabel = 'Hampir Penuh';
        statusColor = Colors.orange.shade700;
      } else {
        statusLabel = 'Tersedia';
        statusColor = Colors.green.shade700;
      }

      computed.add(EvacuationResult(
        shelter: s,
        distanceKm: dist,
        remainingCapacity: remaining,
        statusLabel: statusLabel,
        statusColor: statusColor,
      ));
    }

    computed.sort((a, b) {
      if (a.remainingCapacity > 0 && b.remainingCapacity <= 0) return -1;
      if (a.remainingCapacity <= 0 && b.remainingCapacity > 0) return 1;
      return a.distanceKm.compareTo(b.distanceKm);
    });

    results.assignAll(computed);
  }

  // ── Routing via OSRM ─────────────────────────────────────────────────────
  /// Fetch turn-by-turn route from OSRM public API and navigate to route view
  Future<void> showRouteToShelter(EvacuationResult result) async {
    activeRoute.value = result;
    routePoints.clear();
    routeDistance.value = '';
    routeDuration.value = '';
    isRoutingLoading.value = true;

    double userLat = -6.3262;
    double userLng = 108.3243;
    if (Get.isRegistered<MapController>()) {
      userLat = Get.find<MapController>().currentLat.value;
      userLng = Get.find<MapController>().currentLng.value;
    }

    final shelter = result.shelter;

    try {
      // OSRM public routing API (driving profile)
      final osrmUrl =
          'https://router.project-osrm.org/route/v1/driving/'
          '${userLng.toStringAsFixed(6)},${userLat.toStringAsFixed(6)};'
          '${shelter.longitude.toStringAsFixed(6)},${shelter.latitude.toStringAsFixed(6)}'
          '?overview=full&geometries=geojson&steps=false';

      final dio = Dio();
      final response = await dio.get(osrmUrl);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes[0] as Map<String, dynamic>;
          final geometry = route['geometry'] as Map<String, dynamic>;
          final coords = geometry['coordinates'] as List;

          final points = coords.map<LatLng>((c) {
            final lng = (c[0] as num).toDouble();
            final lat = (c[1] as num).toDouble();
            return LatLng(lat, lng);
          }).toList();

          routePoints.assignAll(points);

          // Distance & duration
          final distanceM = (route['distance'] as num).toDouble();
          final durationS = (route['duration'] as num).toDouble();
          routeDistance.value = distanceM >= 1000
              ? '${(distanceM / 1000).toStringAsFixed(1)} km'
              : '${distanceM.toInt()} m';
          final mins = (durationS / 60).ceil();
          routeDuration.value = mins >= 60
              ? '${(mins / 60).floor()} jam ${mins % 60} menit'
              : '$mins menit';
        }
      }
    } catch (_) {
      // Fallback: straight line between user and shelter
      routePoints.assignAll([
        LatLng(userLat, userLng),
        LatLng(shelter.latitude, shelter.longitude),
      ]);
      routeDistance.value = '${result.distanceKm.toStringAsFixed(1)} km (lurus)';
      routeDuration.value = 'Estimasi tidak tersedia';
    } finally {
      isRoutingLoading.value = false;
    }
  }

  void clearRoute() {
    activeRoute.value = null;
    routePoints.clear();
    routeDistance.value = '';
    routeDuration.value = '';
  }
}
