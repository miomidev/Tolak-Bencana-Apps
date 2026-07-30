import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../main_navigation/controllers/main_navigation_controller.dart';

class ReportFloodController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString photoPath = ''.obs;

  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final heightController = TextEditingController();
  final categoryController = TextEditingController(text: 'genangan air');
  final situationController = TextEditingController();

  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickPhotoFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        photoPath.value = image.path;
        Get.snackbar(
          'Foto Berhasil Dipilih',
          'Foto bukti berhasil diambil dari galeri!',
          backgroundColor: AppColors.primaryTeal,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal Memilih Foto',
        'Gagal mengambil foto dari galeri: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openLocationPicker() async {
    // Open Map Location Picker and wait for coordinate selection
    final result = await Get.toNamed(Routes.addLocationMap, arguments: {'title': 'Pilih Lokasi Banjir'});
    if (result != null && result is Map<String, dynamic>) {
      latitude.value = result['latitude'] ?? 0.0;
      longitude.value = result['longitude'] ?? 0.0;
      locationController.text = result['address'] ?? 'Koordinat: ${latitude.value}, ${longitude.value}';
    }
  }

  Future<void> submitReport() async {
    // Check offline status
    if (Get.isRegistered<DashboardController>()) {
      if (Get.find<DashboardController>().isOffline.value) {
        Get.snackbar(
          'Gagal Mengirim Laporan',
          'Anda sedang dalam Mode Offline. Silakan aktifkan koneksi kembali!',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    if (locationController.text.isEmpty ||
        heightController.text.isEmpty ||
        situationController.text.isEmpty) {
      Get.snackbar(
        'Form Tidak Lengkap',
        'Semua kolom isian wajib diisi!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final Map<String, dynamic> dataMap = {
        'latitude': latitude.value != 0.0 ? latitude.value : -6.3262, // Fallback to Indramayu center if empty
        'longitude': longitude.value != 0.0 ? longitude.value : 108.3248,
        'address': locationController.text,
        'description': situationController.text,
        'category': categoryController.text,
        'height': int.tryParse(heightController.text) ?? 0,
      };

      if (photoPath.value.isNotEmpty) {
        dataMap['photo'] = await dio.MultipartFile.fromFile(
          photoPath.value,
          filename: photoPath.value.split('/').last,
        );
      }

      final formData = dio.FormData.fromMap(dataMap);
      final response = await ApiClient.dio.post('/reports', data: formData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar(
          'Sukses',
          'Laporan banjir Anda berhasil dikirim ke server!',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // Refresh dashboard data
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchDashboardData();
        }

        // Navigate to Dashboard tab
        if (Get.isRegistered<MainNavigationController>()) {
          Get.find<MainNavigationController>().changeTab(0);
        }
        
        Get.back(); // return to previous view
      }
    } on dio.DioException catch (e) {
      Get.snackbar(
        'Gagal Mengirim Laporan',
        e.response?.data['message'] ?? 'Terjadi kesalahan server.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
