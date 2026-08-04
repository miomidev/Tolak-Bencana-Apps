import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool gpsActive = false.obs;
  final RxBool isGuest = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    _checkInitialGpsState();
    // Re-check guest state whenever the reactive observable changes
    // (e.g. after login from the guest login dialog)
    ever(AuthService.isGuestObs, (_) => fetchUserProfile());
  }

  Future<void> _checkInitialGpsState() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (serviceEnabled && 
          (permission == LocationPermission.always || permission == LocationPermission.whileInUse)) {
        gpsActive.value = true;
      } else {
        gpsActive.value = false;
      }
    } catch (_) {
      gpsActive.value = false;
    }
  }

  Future<void> fetchUserProfile() async {
    final guestMode = await AuthService.isGuest();
    isGuest.value = guestMode;
    if (guestMode) {
      currentUser.value = UserModel(
        id: 'guest',
        name: 'Tamu',
        username: 'guest_user',
        avatarUrl: null,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiClient.dio.get('/user');
      if (response.statusCode == 200) {
        currentUser.value = UserModel.fromJson(response.data);
      }
    } catch (e) {
      // Offline fallback
      currentUser.value = UserModel(
        id: 'offline-user',
        name: 'kaliwedi',
        username: 'kaliwedi',
        avatarUrl: null,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleGps(bool value) async {
    if (value) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'GPS Tidak Aktif',
          'Silakan aktifkan layanan lokasi (GPS) pada perangkat Anda!',
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        gpsActive.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Izin Ditolak',
            'Izin akses lokasi ditolak oleh pengguna.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          gpsActive.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Izin Ditolak Permanen',
          'Izin lokasi ditolak secara permanen. Aktifkan secara manual di pengaturan.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        gpsActive.value = false;
        return;
      }

      gpsActive.value = true;
      Get.snackbar(
        'GPS Aktif',
        'Layanan lokasi (GPS) telah dihubungkan dan aktif.',
        backgroundColor: AppColors.primaryTeal,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      gpsActive.value = false;
      Get.snackbar(
        'GPS Dinonaktifkan',
        'Koneksi lokasi (GPS) dinonaktifkan.',
        backgroundColor: Colors.grey.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await ApiClient.dio.post('/logout');
    } catch (_) {}

    // Clear session and update reactive state
    await AuthService.clearSession();

    isLoading.value = false;
    final username = currentUser.value?.username ?? 'kaliwedi';
    Get.offAllNamed(Routes.logoutSuccess, arguments: username);
  }
}
