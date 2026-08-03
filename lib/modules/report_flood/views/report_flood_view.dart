import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/report_flood_controller.dart';

class ReportFloodView extends GetView<ReportFloodController> {
  const ReportFloodView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportFloodController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Lapor Banjir',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Photo Proof Upload Area
              const Text(
                'Foto Bukti',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showPhotoPickerBottomSheet(context, controller),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                      style: BorderStyle.solid, // simulated dash via clean styling
                    ),
                  ),
                  child: controller.photoPath.isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.black38),
                              SizedBox(height: 8),
                              Text(
                                'Ambil atau Pilih Foto Bukti',
                                style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                              ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(controller.photoPath.value),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 120,
                          ),
                        ),
                ),
              ),



              const SizedBox(height: 16),

              // 3. Location Picker Button
              _buildLabel('Lokasi'),
              GestureDetector(
                onTap: controller.openLocationPicker,
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: controller.locationController,
                    hintText: 'Lokasi saat ini',
                    prefixIcon: const Icon(Icons.location_on, color: Colors.black38),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildLabel('Perkiraan Tinggi Air (cm)'),
              _buildTextField(
                controller: controller.heightController,
                hintText: 'Contoh: 50',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.height, color: Colors.black38),
              ),

              const SizedBox(height: 16),

              // 5. Flood Category Dropdown
              _buildLabel('Kategori Banjir'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: controller.selectedCategory.value,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    prefixIcon: Icon(Icons.water_drop_outlined, color: Colors.black38),
                  ),
                  hint: const Text('Pilih kategori banjir', style: TextStyle(color: Colors.black38, fontSize: 13)),
                  items: ['genangan air', 'banjir sedang', 'banjir bandang']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category, style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (value) => controller.selectedCategory.value = value,
                ),
              ),

              const SizedBox(height: 16),

              // 6. Situation Detail
              _buildLabel('Ceritakan Situasinya'),
              _buildTextField(
                controller: controller.situationController,
                hintText: 'Deskripsikan kondisi terkini, misal: Air merendam separuh ban motor...',
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // 7. Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Kirim Laporan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showPhotoPickerBottomSheet(BuildContext context, ReportFloodController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  controller.pickPhotoFromCamera();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  controller.pickPhotoFromGallery();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    Widget? prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
          prefixIcon: prefixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}
