import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/report_model.dart';
import '../../../core/models/saved_location_model.dart';
import '../../../core/models/shelter_model.dart';

// â”€â”€ Map filter state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
enum MapFilter { banjir, posAir, aman }

// â”€â”€ Selected location popup model â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class MapPopupData {
  final String title;
  final String statusLabel;   // e.g. "BANJIR", "AMAN", "WASPADA"
  final String statusLevel;   // e.g. "kritis", "waspada", "pantau", "aman"
  final String waterLevel;    // e.g. "50â€“80 CM"  (empty if aman)
  final String description;
  final bool canReport;       // show Tambah Laporan button
  final bool canViewAlert;    // show Lihat Info Bencana button

  const MapPopupData({
    required this.title,
    required this.statusLabel,
    required this.statusLevel,
    this.waterLevel = '',
    this.description = '',
    this.canReport = false,
    this.canViewAlert = false,
  });
}

// â”€â”€ Flood alert model for bottom panel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class FloodAlert {
  final String location;
  final String level;        // kritis | waspada | pantau
  final String waterHeight;  // e.g. "50â€“80 CM"
  final String description;

  const FloodAlert({
    required this.location,
    required this.level,
    required this.waterHeight,
    required this.description,
  });
}

class MapController extends GetxController {
  // â”€â”€ Location â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final RxDouble currentLat = (-6.3262).obs;
  final RxDouble currentLng = (108.3243).obs;
  final RxDouble currentZoom = 13.0.obs;
  final RxBool isLoadingLocation = false.obs;
  final RxBool isLoadingMarkers = false.obs;
  StreamSubscription<Position>? _positionSubscription;

  // â”€â”€ Data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final RxList<ReportModel> reports = <ReportModel>[].obs;
  final RxList<SavedLocationModel> savedLocations = <SavedLocationModel>[].obs;
  final RxList<ShelterModel> shelters = <ShelterModel>[].obs;
  final RxList<FloodAlert> floodAlerts = <FloodAlert>[].obs;

  // â”€â”€ Filters â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final RxBool showBanjir = true.obs;
  final RxBool showPosAir = true.obs;
  final RxBool showAman   = true.obs;

  // â”€â”€ UI state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final RxBool isAlertPanelExpanded = true.obs;
  final Rxn<MapPopupData> selectedPopup = Rxn<MapPopupData>();

  // â”€â”€ Search â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final searchController = TextEditingController();
  final RxBool isSearchActive = false.obs;
  final RxList<String> searchSuggestions = <String>[].obs;

  // â”€â”€ Stats â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final RxInt banjirCount  = 2.obs;
  final RxInt waspataCount = 2.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLocationPermission();
    fetchMapData();
  }

  // â”€â”€ Filter toggles â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void toggleBanjir() => showBanjir.toggle();
  void togglePosAir() => showPosAir.toggle();
  void toggleAman()   => showAman.toggle();
  void toggleAlertPanel() => isAlertPanelExpanded.toggle();

  void dismissPopup() => selectedPopup.value = null;

  void showMarkerPopup(MapPopupData data) {
    selectedPopup.value = data;
  }

  // â”€â”€ Search â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void onSearchChanged(String query) {
    if (query.isEmpty) {
      searchSuggestions.clear();
      isSearchActive.value = false;
      return;
    }
    isSearchActive.value = true;
    // Filter location names from reports / saved locations
    final matches = <String>[];
    for (final r in reports) {
      if (r.address.toLowerCase().contains(query.toLowerCase()) &&
          !matches.contains(r.address)) {
        matches.add(r.address);
      }
    }
    for (final s in savedLocations) {
      if (s.placeName.toLowerCase().contains(query.toLowerCase()) &&
          !matches.contains(s.placeName)) {
        matches.add(s.placeName);
      }
    }
    // Add static suggestions
    final statics = [
      'Jl. Jenderal Sudirman, Kaliwedi',
      'Jl. Lerabeng, Cirebon',
      'Jl. Jl. Iwanal Cirebon',
      'Taman Kaliwedi',
      'RSUD Kaliwedi',
      'Kantor Kecamatan Kaliwedi',
    ].where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();
    matches.addAll(statics.where((s) => !matches.contains(s)));
    searchSuggestions.assignAll(matches.take(6));
  }

  void selectSuggestion(String suggestion) {
    searchController.text = suggestion;
    isSearchActive.value = false;
    searchSuggestions.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void clearSearch() {
    searchController.clear();
    searchSuggestions.clear();
    isSearchActive.value = false;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // â”€â”€ Location â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _checkLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    _getCurrentLocation();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      currentLat.value = position.latitude;
      currentLng.value = position.longitude;
    }, onError: (_) {
      // ignore
    });
  }

  Future<void> _getCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      currentLat.value = position.latitude;
      currentLng.value = position.longitude;
    } catch (_) {
      // keep default
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> centerOnUserLocation() async {
    await _getCurrentLocation();
  }

  // â”€â”€ Fetch data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> fetchMapData() async {
    isLoadingMarkers.value = true;
    try {
      final response = await ApiClient.dio.get('/map-data');
      if (response.statusCode == 200) {
        final data = response.data;
        reports.assignAll(
          (data['reports'] as List).map((j) => ReportModel.fromJson(j as Map<String, dynamic>)),
        );
        savedLocations.assignAll(
          (data['saved_locations'] as List).map((j) => SavedLocationModel.fromJson(j as Map<String, dynamic>)),
        );
        shelters.assignAll(
          (data['shelters'] as List).map((j) => ShelterModel.fromJson(j as Map<String, dynamic>)),
        );
        _buildFloodAlerts();
        _updateStats();
      }
    } on DioException catch (_) {
      // keep offline demo data
      _loadOfflineDemo();
    } finally {
      isLoadingMarkers.value = false;
    }
  }

  void _buildFloodAlerts() {
    final alerts = <FloodAlert>[];
    for (final r in reports) {
      if (r.severity == 'critical' || r.severity == 'high' || r.severity == 'medium') {
        alerts.add(FloodAlert(
          location: r.address,
          level: _severityToLevel(r.severity),
          waterHeight: '${_randCm(r.severity)} CM',
          description: r.description,
        ));
      }
    }
    floodAlerts.assignAll(alerts.take(6));
  }

  String _severityToLevel(String s) {
    switch (s) {
      case 'critical': return 'kritis';
      case 'high':     return 'waspada';
      case 'medium':   return 'pantau';
      default:         return 'aman';
    }
  }

  String _randCm(String s) {
    switch (s) {
      case 'critical': return '80â€“120';
      case 'high':     return '50â€“80';
      case 'medium':   return '30â€“50';
      default:         return '< 30';
    }
  }

  void _updateStats() {
    banjirCount.value = reports.where((r) => r.severity == 'critical' || r.severity == 'high').length;
    waspataCount.value = reports.where((r) => r.severity == 'medium').length;
  }

  void _loadOfflineDemo() {
    reports.assignAll([
      ReportModel.fromJson({
        'id': 'demo-1', 'user_id': 'demo-u1',
        'latitude': -6.3262, 'longitude': 108.3243,
        'address': 'Jl. Jenderal Sudirman, Kaliwedi',
        'description': 'Banjir tinggi di 30-80 cm, jangan melewati jalan ini.',
        'severity': 'critical', 'status': 'pending',
        'category': 'Banjir', 'reported_at': DateTime.now().toIso8601String(),
        'time_ago': 'Baru saja', 'likes_count': 0, 'comments_count': 0, 'is_liked': false,
        'user': {'id': 'demo-u1', 'name': 'Warga', 'username': 'warga'},
      }),
      ReportModel.fromJson({
        'id': 'demo-2', 'user_id': 'demo-u2',
        'latitude': -6.3300, 'longitude': 108.3200,
        'address': 'Jl. Surabaya, Kaliwedi',
        'description': 'Banjir tinggi 30-50 cm, hati-hati saat melintas.',
        'severity': 'high', 'status': 'verified',
        'category': 'Banjir', 'reported_at': DateTime.now().toIso8601String(),
        'time_ago': '1 jam lalu', 'likes_count': 2, 'comments_count': 1, 'is_liked': false,
        'user': {'id': 'demo-u2', 'name': 'Petugas', 'username': 'petugas'},
      }),
      ReportModel.fromJson({
        'id': 'demo-3', 'user_id': 'demo-u3',
        'latitude': -6.3220, 'longitude': 108.3280,
        'address': 'Jl. Urip Sumoharjo, Kaliwedi',
        'description': 'Banjir tinggi 10-20 cm, kondisi normal.',
        'severity': 'low', 'status': 'resolved',
        'category': 'Banjir', 'reported_at': DateTime.now().toIso8601String(),
        'time_ago': '3 jam lalu', 'likes_count': 5, 'comments_count': 2, 'is_liked': true,
        'user': {'id': 'demo-u3', 'name': 'Relawan', 'username': 'relawan'},
      }),
    ]);

    savedLocations.assignAll([
      SavedLocationModel.fromJson({
        'id': 'loc-1', 'user_id': 'demo-u1',
        'place_name': 'Rumah', 'address': 'Jl. Kaliwedi No. 1',
        'latitude': -6.3280, 'longitude': 108.3220,
        'is_primary': true, 'icon_type': 'home',
      }),
      SavedLocationModel.fromJson({
        'id': 'loc-2', 'user_id': 'demo-u1',
        'place_name': 'Kantor Kecamatan', 'address': 'Jl. Raya Kecamatan',
        'latitude': -6.3240, 'longitude': 108.3260,
        'is_primary': false, 'icon_type': 'work',
      }),
    ]);

    shelters.assignAll([
      ShelterModel.fromJson({
        'id': 'sh-1', 'name': 'Balai Desa Kaliwedi',
        'latitude': -6.3250, 'longitude': 108.3230,
        'address': 'Jl. Balai Desa No. 1, Kaliwedi',
        'capacity': 200, 'current_occupancy': 45,
        'status': 'active', 'contact': '08123456789',
      }),
    ]);

    floodAlerts.assignAll([
      const FloodAlert(
        location: 'Jl. Jenderal Sudirman',
        level: 'kritis',
        waterHeight: '50â€“80',
        description: 'Banjir tinggi di 30â€“80 cm, jangan melewati jalan ini.',
      ),
      const FloodAlert(
        location: 'Jl. Surabaya',
        level: 'waspada',
        waterHeight: '30â€“50',
        description: 'Banjir tinggi 30â€“50 cm, hati-hati saat melintas.',
      ),
      const FloodAlert(
        location: 'Jl. Urip Sumoharjo',
        level: 'pantau',
        waterHeight: '< 30',
        description: 'PAR-PAR, banjir tinggi 10â€“20 cm, harap berhati-hati, kondisi normal.',
      ),
      const FloodAlert(
        location: 'Jl. Pemuda',
        level: 'waspada',
        waterHeight: '30â€“50',
        description: 'PAR-PAR, Waspada gangguan Tubhes sadfehmemser.',
      ),
    ]);
    banjirCount.value = 2;
    waspataCount.value = 2;
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
