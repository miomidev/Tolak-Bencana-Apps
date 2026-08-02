import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart' hide MapController;
import 'package:flutter_map/flutter_map.dart' as fm show MapController;
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/map_launcher_helper.dart';
import '../controllers/evacuation_controller.dart';
import '../controllers/map_controller.dart';

/// Full-screen map view showing the route from user location to a shelter.
/// Opened from EvacuationView when user taps "Lihat Rute".
class EvacuationRouteView extends StatefulWidget {
  const EvacuationRouteView({super.key});

  @override
  State<EvacuationRouteView> createState() => _EvacuationRouteViewState();
}

class _EvacuationRouteViewState extends State<EvacuationRouteView> {
  late final EvacuationController _ctrl;
  final fm.MapController _mapController = fm.MapController();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<EvacuationController>();
    // Auto-fit map once route is loaded
    ever(_ctrl.routePoints, (points) {
      if (points.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds(points));
      }
    });
    // If route already loaded, fit immediately
    if (_ctrl.routePoints.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds(_ctrl.routePoints));
    }
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDC2626),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _ctrl.clearRoute();
            Get.back();
          },
        ),
        title: Obx(() {
          final shelter = _ctrl.activeRoute.value?.shelter;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rute Evakuasi',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (shelter != null)
                Text(
                  shelter.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          );
        }),
      ),
      body: Obx(() {
        final userLat = Get.isRegistered<MapController>()
            ? Get.find<MapController>().currentLat.value
            : -6.3262;
        final userLng = Get.isRegistered<MapController>()
            ? Get.find<MapController>().currentLng.value
            : 108.3243;
        final shelter = _ctrl.activeRoute.value?.shelter;
        final routePoints = _ctrl.routePoints.toList();
        final isLoading = _ctrl.isRoutingLoading.value;

        return Stack(
          children: [
            // ── Map ──────────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(userLat, userLng),
                initialZoom: 14.0,
                minZoom: 10.5,
                maxZoom: 18.0,
                cameraConstraint: CameraConstraint.containCenter(
                  bounds: LatLngBounds(
                    const LatLng(-6.6500, 107.8800),
                    const LatLng(-6.1800, 108.5500),
                  ),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kaliwedi.app',
                ),
                // Route polyline
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 5.0,
                        color: const Color(0xFFDC2626),
                      ),
                    ],
                  ),
                // Markers
                MarkerLayer(
                  markers: [
                    // User location
                    Marker(
                      point: LatLng(userLat, userLng),
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withValues(alpha: 0.2),
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                          ),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Shelter destination marker
                    if (shelter != null)
                      Marker(
                        point: LatLng(shelter.latitude, shelter.longitude),
                        width: 50,
                        height: 60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.home_outlined, color: Colors.white, size: 18),
                            ),
                            Container(
                              width: 2,
                              height: 8,
                              color: const Color(0xFFDC2626),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // ── Loading overlay ───────────────────────────────────────────
            if (isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFDC2626)),
                      SizedBox(height: 12),
                      Text(
                        'Menghitung rute...',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Route info card (bottom) ──────────────────────────────────
            if (!isLoading && shelter != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _RouteInfoCard(ctrl: _ctrl, shelter: shelter),
              ),

            // ── Fit bounds button ─────────────────────────────────────────
            if (!isLoading && routePoints.isNotEmpty)
              Positioned(
                right: 16,
                bottom: 200,
                child: FloatingActionButton.small(
                  heroTag: 'fit_bounds',
                  backgroundColor: Colors.white,
                  onPressed: () => _fitBounds(routePoints),
                  child: const Icon(Icons.fit_screen, color: Colors.black54),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _RouteInfoCard extends StatelessWidget {
  final EvacuationController ctrl;
  final dynamic shelter;

  const _RouteInfoCard({required this.ctrl, required this.shelter});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Destination name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home_outlined, color: Color(0xFFDC2626), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shelter.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      shelter.address,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Distance & Duration chips
          Obx(() => Row(
            children: [
              _InfoPill(
                icon: Icons.route,
                label: ctrl.routeDistance.value.isNotEmpty
                    ? ctrl.routeDistance.value
                    : '...',
                color: AppColors.primaryTeal,
              ),
              const SizedBox(width: 12),
              _InfoPill(
                icon: Icons.access_time,
                label: ctrl.routeDuration.value.isNotEmpty
                    ? ctrl.routeDuration.value
                    : '...',
                color: Colors.orange.shade700,
              ),
            ],
          )),

          const SizedBox(height: 16),

          // Open in Google Maps button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                MapLauncherHelper.openInGoogleMaps(
                  latitude: shelter.latitude,
                  longitude: shelter.longitude,
                  destinationName: shelter.name,
                );
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Buka di Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
