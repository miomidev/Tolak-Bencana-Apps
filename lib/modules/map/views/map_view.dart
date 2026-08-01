import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart' hide MapController;
import 'package:flutter_map/flutter_map.dart' as fm show MapController;
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/report_model.dart';
import '../../../core/models/saved_location_model.dart';
import '../../../core/models/shelter_model.dart';
import '../controllers/map_controller.dart';
import '../../main_navigation/controllers/main_navigation_controller.dart';
import '../../../routes/app_routes.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  MapView â€“ main entry
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class MapView extends StatefulWidget {
  const MapView({super.key});
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapController get controller => Get.find<MapController>();
  final fm.MapController _mapController = fm.MapController();
  bool _hasInitialCentered = false;

  @override
  void initState() {
    super.initState();
    _autoCenterOnce();
  }

  void _autoCenterOnce() {
    ever(controller.currentLat, (_) {
      if (!_hasInitialCentered && !controller.isLoadingLocation.value) {
        _hasInitialCentered = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(
            LatLng(controller.currentLat.value, controller.currentLng.value),
            _mapController.camera.zoom,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
        children: [
          _TealHeader(controller: controller),
          Expanded(
            child: Stack(
              children: [
                // â”€â”€ Map â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      controller.currentLat.value,
                      controller.currentLng.value,
                    ),
                    initialZoom: 14.0,
                    onTap: (_, _) => controller.dismissPopup(),
                    onPositionChanged: (camera, hasGesture) {
                      controller.currentZoom.value = camera.zoom;
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.kaliwedi.app',
                    ),
                    Obx(() => MarkerLayer(markers: _buildAllMarkers())),
                  ],
                ),

                // â”€â”€ Filter chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _FilterBar(controller: controller),

                // â”€â”€ Status summary â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _StatusSummary(controller: controller),

                // â”€â”€ Zoom controls â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _ZoomControls(controller: controller, mapController: _mapController),

                // â”€â”€ Marker popup card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _MarkerPopupCard(controller: controller),

                // â”€â”€ Bottom flood alert panel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _FloodAlertPanel(controller: controller),

                // ── Evacuation Button ─────────────────────────────
                // Positioned at bottom-left, above the flood alert panel
                // but BELOW the marker popup card (which sits at bottom: 200)
                Obx(() {
                  // Hide button when popup is visible to avoid overlap
                  final hasPopup = controller.selectedPopup.value != null;
                  return Positioned(
                    left: 16,
                    bottom: hasPopup ? 8 : 210,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 200),
                      offset: Offset.zero,
                      child: GestureDetector(
                        onTap: () => Get.toNamed(Routes.evacuation),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emergency, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Jalur Evakuasi',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // â”€â”€ Loading indicator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Obx(() => controller.isLoadingMarkers.value
                  ? const Positioned(
                      top: 8, right: 8,
                      child: _LoadingChip(),
                    )
                  : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  List<Marker> _buildAllMarkers() {
    final markers = <Marker>[];

    // User location
    markers.add(Marker(
      point: LatLng(controller.currentLat.value, controller.currentLng.value),
      width: 60, height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.2),
            ),
          ),
          Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
          ),
          Container(
            width: 14, height: 14,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    ));

    // Report markers (flood points)
    if (controller.showBanjir.value || controller.showAman.value) {
      for (final r in controller.reports) {
        final isFlood = r.severity == 'critical' || r.severity == 'high' || r.severity == 'medium';
        if (isFlood && !controller.showBanjir.value) continue;
        if (!isFlood && !controller.showAman.value) continue;
        markers.add(_reportMarker(r));
      }
    }

    // Saved locations (Selalu tampil, terpisah dari Pos Air)
    for (final loc in controller.savedLocations) {
      markers.add(_savedLocMarker(loc));
    }

    // Shelters (shown as aman/green)
    if (controller.showAman.value) {
      for (final s in controller.shelters) {
        markers.add(_shelterMarker(s));
      }
    }

    return markers;
  }

  Marker _reportMarker(ReportModel r) {
    final color = _severityColor(r.severity);
    final label = _severityLabel(r.severity);
    final zoom = controller.currentZoom.value;

    if (zoom < 9) {
      if (r.severity != 'critical' && r.severity != 'high') {
        return Marker(point: LatLng(r.latitude, r.longitude), width: 0, height: 0, child: const SizedBox.shrink());
      }
      return Marker(
        point: LatLng(r.latitude, r.longitude),
        width: 12, height: 12,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)],
          ),
        ),
      );
    }

    final popupData = MapPopupData(
      title: r.address,
      statusLabel: label.toUpperCase(),
      statusLevel: _severityToLevel(r.severity),
      waterLevel: '${_severityCm(r.severity)} CM',
      description: r.description,
      canReport: true,
      canViewAlert: true,
    );

    if (zoom < 12.5) {
      return Marker(
        point: LatLng(r.latitude, r.longitude),
        width: 28, height: 28,
        child: GestureDetector(
          onTap: () => controller.showMarkerPopup(popupData),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2.5),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Icon(Icons.water_drop, color: color, size: 16),
          ),
        ),
      );
    }

    return Marker(
      point: LatLng(r.latitude, r.longitude),
      width: 64, height: 60,
      child: GestureDetector(
        onTap: () => controller.showMarkerPopup(popupData),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
              ),
              child: Text(label.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 2),
            Icon(Icons.water_drop, color: color, size: 28, shadows: const [Shadow(color: Colors.black26, blurRadius: 4)]),
          ],
        ),
      ),
    );
  }

  Marker _savedLocMarker(SavedLocationModel loc) {
    IconData icon;
    if (loc.iconType == 'home') {
      icon = Icons.home;
    } else if (loc.iconType == 'work') {
      icon = Icons.work;
    } else {
      icon = Icons.bookmark;
    }

    final zoom = controller.currentZoom.value;
    
    if (zoom < 9) {
      return Marker(point: LatLng(loc.latitude, loc.longitude), width: 0, height: 0, child: const SizedBox.shrink());
    }

    final popupData = MapPopupData(
      title: loc.placeName,
      statusLabel: 'LOKASI TERSIMPAN',
      statusLevel: 'aman',
      description: loc.address,
      waterLevel: '',
      canReport: false,
      canViewAlert: false,
    );

    if (zoom < 12.5) {
      return Marker(
        point: LatLng(loc.latitude, loc.longitude),
        width: 18, height: 18,
        child: GestureDetector(
          onTap: () => controller.showMarkerPopup(popupData),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.indigo.shade500,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: 10),
          ),
        ),
      );
    }

    return Marker(
      point: LatLng(loc.latitude, loc.longitude),
      width: 38, height: 38,
      child: GestureDetector(
        onTap: () => controller.showMarkerPopup(popupData),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.indigo.shade500,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.indigo.withValues(alpha: 0.4), blurRadius: 6)],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Marker _shelterMarker(ShelterModel s) {
    final zoom = controller.currentZoom.value;
    
    if (zoom < 9) {
      return Marker(point: LatLng(s.latitude, s.longitude), width: 0, height: 0, child: const SizedBox.shrink());
    }

    final popupData = MapPopupData(
      title: s.name,
      statusLabel: 'AMAN',
      statusLevel: 'aman',
      description: s.address,
      canReport: false,
      canViewAlert: false,
    );

    if (zoom < 12.5) {
      return Marker(
        point: LatLng(s.latitude, s.longitude),
        width: 18, height: 18,
        child: GestureDetector(
          onTap: () => controller.showMarkerPopup(popupData),
          child: Container(
            decoration: BoxDecoration(color: Colors.green.shade600, shape: BoxShape.circle),
            child: const Icon(Icons.safety_check, color: Colors.white, size: 10),
          ),
        ),
      );
    }

    return Marker(
      point: LatLng(s.latitude, s.longitude),
      width: 38, height: 38,
      child: GestureDetector(
        onTap: () => controller.showMarkerPopup(popupData),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.4), blurRadius: 6)],
          ),
          child: const Icon(Icons.safety_check, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Color _severityColor(String s) {
    switch (s) {
      case 'critical': return const Color(0xFFDC2626);
      case 'high':     return Colors.deepOrange;
      case 'medium':   return Colors.amber.shade700;
      default:         return Colors.green;
    }
  }

  String _severityLabel(String s) {
    switch (s) {
      case 'critical': return 'Kritis';
      case 'high':     return 'Waspada';
      case 'medium':   return 'Pantau';
      default:         return 'Aman';
    }
  }

  String _severityToLevel(String s) {
    switch (s) {
      case 'critical': return 'kritis';
      case 'high':     return 'waspada';
      case 'medium':   return 'pantau';
      default:         return 'aman';
    }
  }

  String _severityCm(String s) {
    switch (s) {
      case 'critical': return '80â€“120';
      case 'high':     return '50â€“80';
      case 'medium':   return '30â€“50';
      default:         return '< 30';
    }
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  Teal header (matches dashboard style)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _TealHeader extends StatelessWidget {
  final MapController controller;
  const _TealHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryTeal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Row(
                children: [
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.gps_fixed,
                          color: controller.isLoadingLocation.value
                              ? Colors.white54 : Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.isLoadingLocation.value ? 'Memuat...' : 'Aktif',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(width: 8),
                  _headerIconButton(
                    icon: Icons.notifications_none_outlined,
                    onTap: () {
                      if (Get.isRegistered<MainNavigationController>()) {
                        Get.find<MainNavigationController>().changeTab(3);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _headerIconButton(
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
          _SearchBar(controller: controller),
        ],
      ),
    );
  }

  Widget _headerIconButton({required IconData icon, required VoidCallback onTap}) {
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  Search bar with suggestions
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _SearchBar extends StatelessWidget {
  final MapController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Input
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(Icons.search, color: Colors.grey.shade400, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Cari lokasi...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              Obx(() => controller.isSearchActive.value
                ? GestureDetector(
                    onTap: controller.clearSearch,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.close, color: Colors.grey.shade400, size: 18),
                    ),
                  )
                : const SizedBox(width: 10),
              ),
            ],
          ),
        ),
        // Suggestions dropdown
        Obx(() {
          if (controller.searchSuggestions.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: controller.searchSuggestions.map((s) => InkWell(
                onTap: () => controller.selectSuggestion(s),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: AppColors.primaryTeal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(s, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          );
        }),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  Filter chips row (Banjir / Pos Air / Aman)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _FilterBar extends StatelessWidget {
  final MapController controller;
  const _FilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8, left: 12, right: 12,
      child: Obx(() => Row(
        children: [
          _Chip(
            label: 'Banjir',
            color: const Color(0xFFDC2626),
            active: controller.showBanjir.value,
            onTap: controller.toggleBanjir,
          ),
          const SizedBox(width: 6),
          _Chip(
            label: 'Pos Air',
            color: Colors.amber.shade700,
            active: controller.showPosAir.value,
            onTap: controller.togglePosAir,
          ),
          const SizedBox(width: 6),
          _Chip(
            label: 'Aman',
            color: Colors.green.shade600,
            active: controller.showAman.value,
            onTap: controller.toggleAman,
          ),
        ],
      ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.color, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 1))],
          border: Border.all(color: active ? color : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: active ? Colors.white : color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? Colors.white : color)),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  Status summary bar (Banjir: N / Waspada: N)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _StatusSummary extends StatelessWidget {
  final MapController controller;
  const _StatusSummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 44, left: 12,
      child: Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatBadge(label: 'Banjir', count: controller.banjirCount.value, color: const Color(0xFFDC2626)),
            const SizedBox(width: 10),
            _StatBadge(label: 'Waspada', count: controller.waspataCount.value, color: Colors.amber.shade700),
          ],
        ),
      )),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatBadge({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color, height: 1.1),
        ),
        Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  Zoom + Locate controls (right side)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ZoomControls extends StatelessWidget {
  final MapController controller;
  final fm.MapController mapController;
  const _ZoomControls({required this.controller, required this.mapController});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12, top: 80,
      child: Column(
        children: [
          _MapBtn(
            icon: Icons.add,
            onTap: () {
              final zoom = mapController.camera.zoom + 1;
              mapController.move(mapController.camera.center, zoom);
            },
          ),
          const SizedBox(height: 6),
          _MapBtn(
            icon: Icons.remove,
            onTap: () {
              final zoom = mapController.camera.zoom - 1;
              mapController.move(mapController.camera.center, zoom);
            },
          ),
          const SizedBox(height: 12),
          _MapBtn(
            icon: Icons.my_location,
            onTap: () async {
              await controller.centerOnUserLocation();
              mapController.move(
                LatLng(controller.currentLat.value, controller.currentLng.value),
                mapController.camera.zoom,
              );
            },
            color: AppColors.primaryTeal,
          ),
        ],
      ),
    );
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _MapBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: color ?? Colors.black54),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  Marker popup card (shown when a marker is tapped)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MarkerPopupCard extends StatelessWidget {
  final MapController controller;
  const _MarkerPopupCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final popup = controller.selectedPopup.value;
      if (popup == null) return const SizedBox.shrink();

      final color = _levelColor(popup.statusLevel);
      final bgColor = _levelBg(popup.statusLevel);

      return Positioned(
        left: 12, right: 12,
        bottom: 200, // above flood panel
        child: Material(
          borderRadius: BorderRadius.circular(14),
          elevation: 8,
          shadowColor: Colors.black26,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          popup.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: controller.dismissPopup,
                        icon: const Icon(Icons.close, size: 18, color: Colors.black38),
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                // Status badge + water level
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                        child: Text(popup.statusLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      if (popup.waterLevel.isNotEmpty) ...[ 
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
                          child: Text(popup.waterLevel,
                            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
                // Description
                if (popup.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
                    child: Text(
                      popup.description,
                      maxLines: 3, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5),
                    ),
                  ),
                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                  child: Row(
                    children: [
                      if (popup.canReport)
                        _PopupBtn(
                          label: 'Tambah Laporan',
                          icon: Icons.add_circle_outline,
                          color: AppColors.primaryTeal,
                          onTap: () {
                            controller.dismissPopup();
                            Get.toNamed(Routes.reportFlood);
                          },
                        ),
                      if (popup.canReport && popup.canViewAlert) const SizedBox(width: 8),
                      if (popup.canViewAlert)
                        _PopupBtn(
                          label: 'Lihat Info Bencana',
                          icon: Icons.info_outline,
                          color: Colors.blue.shade700,
                          onTap: () => controller.dismissPopup(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'kritis':   return const Color(0xFFDC2626);
      case 'waspada':  return Colors.deepOrange;
      case 'pantau':   return Colors.amber.shade700;
      case 'posair':   return Colors.blue.shade700;
      default:         return Colors.green.shade600;
    }
  }

  Color _levelBg(String level) {
    switch (level) {
      case 'kritis':   return const Color(0xFFFEE2E2);
      case 'waspada':  return const Color(0xFFFFF0EB);
      case 'pantau':   return const Color(0xFFFEF9C3);
      default:         return const Color(0xFFDCFCE7);
    }
  }
}

class _PopupBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _PopupBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  Flood alert bottom panel
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _FloodAlertPanel extends StatelessWidget {
  final MapController controller;
  const _FloodAlertPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Obx(() {
        final expanded = controller.isAlertPanelExpanded.value;
        final alerts = controller.floodAlerts;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row (always visible)
              GestureDetector(
                onTap: controller.toggleAlertPanel,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 6),
                      const Text(
                        'Peringatan Banjir',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const Spacer(),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_up, color: Colors.grey.shade400, size: 20),
                      ),
                    ],
                  ),
                ),
              ),

              // Alert list (collapsed/expanded)
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (alerts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text('Tidak ada peringatan banjir saat ini.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      )
                    else
                      ...alerts.map((a) => _AlertItem(alert: a)),
                    const SizedBox(height: 8),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
              ),

              // Bottom safe area padding
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      }),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final FloodAlert alert;
  const _AlertItem({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(alert.level);
    final label = _levelLabel(alert.level);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.location,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      _LevelBadge(label: label, color: color),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    alert.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'kritis':  return const Color(0xFFDC2626);
      case 'waspada': return Colors.deepOrange;
      case 'pantau':  return Colors.amber.shade700;
      default:        return Colors.green;
    }
  }

  String _levelLabel(String level) {
    switch (level) {
      case 'kritis':  return 'KRITIS';
      case 'waspada': return 'WASPADA';
      case 'pantau':  return 'PANTAU';
      default:        return 'AMAN';
    }
  }
}

class _LevelBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _LevelBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  Loading chip
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _LoadingChip extends StatelessWidget {
  const _LoadingChip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: const SizedBox(
        width: 16, height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
      ),
    );
  }
}
