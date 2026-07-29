import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class MapController extends GetxController {
  final RxDouble currentLat = (-6.3262).obs; // Indramayu default
  final RxDouble currentLng = (108.3243).obs;
  final RxBool isLoadingLocation = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );
      currentLat.value = position.latitude;
      currentLng.value = position.longitude;
    } catch (e) {
      Get.snackbar('Error', 'Failed to get current location');
    } finally {
      isLoadingLocation.value = false;
    }
  }
}
