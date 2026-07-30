import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/user_model.dart';
import 'profile_controller.dart';

class EditProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString photoPath = ''.obs;
  final RxString currentPhotoUrl = ''.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Load initial user details from ProfileController if available
    if (Get.isRegistered<ProfileController>()) {
      final user = Get.find<ProfileController>().currentUser.value;
      if (user != null) {
        nameController.text = user.name;
        emailController.text = user.email ?? '';
        phoneController.text = user.phone ?? '';
        currentPhotoUrl.value = user.avatarUrl ?? '';
      }
    }
  }

  Future<void> pickPhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        photoPath.value = image.path;
        currentPhotoUrl.value = ''; // prioritize local path
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih foto: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> removePhoto() async {
    photoPath.value = '';
    currentPhotoUrl.value = '';
  }

  Future<void> saveChanges() async {
    if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
      Get.snackbar('Gagal', 'Nama Lengkap dan Email wajib diisi!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      // 1. If photo was deleted completely
      if (photoPath.isEmpty && currentPhotoUrl.isEmpty) {
        final profileUser = Get.find<ProfileController>().currentUser.value;
        if (profileUser?.avatarUrl != null && profileUser!.avatarUrl!.isNotEmpty) {
          await ApiClient.dio.delete('/user/profile/photo');
        }
      }

      // 2. Submit general profile updates
      final Map<String, dynamic> dataMap = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      if (photoPath.value.isNotEmpty) {
        dataMap['photo'] = await dio.MultipartFile.fromFile(
          photoPath.value,
          filename: photoPath.value.split('/').last,
        );
      }

      final formData = dio.FormData.fromMap(dataMap);
      final response = await ApiClient.dio.post('/user/profile', data: formData);

      if (response.statusCode == 200) {
        final updatedUser = UserModel.fromJson(response.data['user']);
        
        // Update ProfileController state
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().currentUser.value = updatedUser;
        }

        Get.snackbar(
          'Sukses',
          'Profil Anda berhasil diperbarui!',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.back(); // Return to profile
      }
    } on dio.DioException catch (e) {
      Get.snackbar(
        'Gagal Menyimpan',
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
