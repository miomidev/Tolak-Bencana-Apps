import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/saved_location_model.dart';
import '../../../routes/app_routes.dart';

class SavedLocationsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<SavedLocationModel> locations = <SavedLocationModel>[].obs;

  final placeNameController = TextEditingController();
  final addressController = TextEditingController();
  final RxString selectedAddress = ''.obs;
  final RxDouble editLatitude = 0.0.obs;
  final RxDouble editLongitude = 0.0.obs;
  final Rxn<SavedLocationModel> editingLocation = Rxn<SavedLocationModel>();

  @override
  void onInit() {
    super.onInit();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    isLoading.value = true;
    try {
      final response = await ApiClient.dio.get('/saved-locations');
      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data['data'] as List;
        final list = dataList.map((e) => SavedLocationModel.fromJson(e as Map<String, dynamic>)).toList();
        locations.assignAll(list);
      }
    } catch (e) {
      // Mock Fallback if offline
      locations.assignAll([
        SavedLocationModel(
          id: '1',
          userId: 'user-1',
          placeName: 'Rumah',
          latitude: -6.3262,
          longitude: 108.3248,
          address: 'Jl. Kemuning No. 12, Antapani, Bandung',
          isPrimary: true,
          iconType: 'home',
        ),
        SavedLocationModel(
          id: '2',
          userId: 'user-1',
          placeName: 'Kantor',
          latitude: -6.3282,
          longitude: 108.3298,
          address: 'Jl. Asia Afrika No. 8, Sumur Bandung',
          isPrimary: false,
          iconType: 'work',
        ),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteLocation(String id) async {
    try {
      final response = await ApiClient.dio.delete('/saved-locations/$id');
      if (response.statusCode == 200) {
        Get.snackbar(
          'Sukses',
          'Lokasi berhasil dihapus!',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        fetchLocations();
      }
    } catch (e) {
      locations.removeWhere((element) => element.id == id);
      Get.snackbar(
        'Sukses',
        'Lokasi berhasil dihapus (Lokal)!',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void startAddLocation() {
    editingLocation.value = null;
    placeNameController.clear();
    addressController.clear();
    selectedAddress.value = '';
    editLatitude.value = -6.3262; // Default Indramayu Center
    editLongitude.value = 108.3248;
  }

  void startEditLocation(SavedLocationModel loc) {
    editingLocation.value = loc;
    placeNameController.text = loc.placeName;
    addressController.text = loc.address;
    selectedAddress.value = loc.address;
    editLatitude.value = loc.latitude;
    editLongitude.value = loc.longitude;
  }

  Future<void> chooseLocationFromMap() async {
    final result = await Get.toNamed(Routes.addLocationMap, arguments: {
      'title': editingLocation.value == null ? 'Tambah Lokasi Baru' : 'Edit Lokasi'
    });
    if (result != null && result is Map<String, dynamic>) {
      selectedAddress.value = result['address'] ?? '';
      addressController.text = selectedAddress.value;
      editLatitude.value = result['latitude'] ?? 0.0;
      editLongitude.value = result['longitude'] ?? 0.0;
    }
  }

  Future<void> saveLocation() async {
    final name = placeNameController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Gagal', 'Nama Lokasi wajib diisi!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (address.isEmpty || address == 'Pilih lokasi dari peta...') {
      Get.snackbar('Gagal', 'Alamat wajib diisi via peta!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      if (editingLocation.value == null) {
        // Create new
        final response = await ApiClient.dio.post('/saved-locations', data: {
          'place_name': name,
          'address': address,
          'latitude': editLatitude.value,
          'longitude': editLongitude.value,
        });

        if (response.statusCode == 201) {
          Get.back(); // close bottom sheet
          Get.snackbar(
            'Sukses',
            'Lokasi berhasil disimpan!',
            backgroundColor: Colors.green.shade700,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          fetchLocations();
        }
      } else {
        // Update existing
        final response = await ApiClient.dio.put('/saved-locations/${editingLocation.value!.id}', data: {
          'place_name': name,
          'address': address,
          'latitude': editLatitude.value,
          'longitude': editLongitude.value,
        });

        if (response.statusCode == 200) {
          Get.back(); // close bottom sheet
          Get.snackbar(
            'Sukses',
            'Lokasi berhasil diperbarui!',
            backgroundColor: Colors.green.shade700,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          fetchLocations();
        }
      }
    } catch (e) {
      // Mock local add if offline
      if (editingLocation.value == null) {
        locations.insert(
          0,
          SavedLocationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'user-1',
            placeName: name,
            latitude: editLatitude.value,
            longitude: editLongitude.value,
            address: address,
            isPrimary: false,
            iconType: 'other',
          ),
        );
      } else {
        final idx = locations.indexWhere((loc) => loc.id == editingLocation.value!.id);
        if (idx != -1) {
          locations[idx] = SavedLocationModel(
            id: editingLocation.value!.id,
            userId: editingLocation.value!.userId,
            placeName: name,
            latitude: editLatitude.value,
            longitude: editLongitude.value,
            address: address,
            isPrimary: editingLocation.value!.isPrimary,
            iconType: editingLocation.value!.iconType,
          );
        }
      }
      Get.back(); // close bottom sheet
      Get.snackbar(
        'Sukses',
        'Lokasi disimpan secara lokal!',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    placeNameController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
