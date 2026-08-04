import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncherHelper {
  /// Opens external Google Maps app or web maps (default: motor / two-wheeler)
  static Future<void> openInGoogleMaps({
    required double latitude,
    required double longitude,
    String? destinationName,
    String mode = 'l', // 'l' = two-wheeler (motor), 'd' = driving (mobil), 'w' = walking
  }) async {
    // 1. Google Navigation intent (mode=l is two-wheeler / motor in Google Maps)
    final googleNavUri = Uri.parse('google.navigation:q=$latitude,$longitude&mode=$mode');

    // 2. Geo URI scheme
    final geoUri = Uri.parse(
      destinationName != null && destinationName.isNotEmpty
          ? 'geo:$latitude,$longitude?q=$latitude,$longitude(${Uri.encodeComponent(destinationName)})'
          : 'geo:$latitude,$longitude?q=$latitude,$longitude',
    );

    // 3. Universal Google Maps Directions Web URL
    final travelMode = mode == 'l'
        ? 'two-wheeler'
        : (mode == 'w'
            ? 'walking'
            : (mode == 'b' ? 'bicycling' : 'driving'));
    final webMapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=$travelMode',
    );

    try {
      if (await canLaunchUrl(googleNavUri)) {
        await launchUrl(googleNavUri, mode: LaunchMode.externalApplication);
        return;
      }

      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }

      if (await canLaunchUrl(webMapsUri)) {
        await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
        return;
      }

      await launchUrl(webMapsUri, mode: LaunchMode.platformDefault);
    } catch (e) {
      try {
        await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
      } catch (err) {
        Get.snackbar(
          'Gagal Membuka Peta',
          'Tidak dapat membuka aplikasi Google Maps: $err',
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
