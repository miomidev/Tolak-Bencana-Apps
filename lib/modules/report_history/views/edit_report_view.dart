import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/report_model.dart';
import '../../../core/network/api_client.dart';
import '../controllers/report_history_controller.dart';

class EditReportView extends StatefulWidget {
  const EditReportView({super.key});

  @override
  State<EditReportView> createState() => _EditReportViewState();
}

class _EditReportViewState extends State<EditReportView> {
  late ReportModel report;
  late TextEditingController _descController;
  late String _selectedCategory;
  late int _selectedHeight;
  File? _newPhoto;
  bool _isLoading = false;

  final List<String> _categories = ['Banjir', 'Longsor', 'Genangan', 'Darurat', 'Lainnya'];
  final List<Map<String, dynamic>> _heightOptions = [
    {'label': '< 10 cm (Ringan)', 'value': 5},
    {'label': '10 – 20 cm', 'value': 15},
    {'label': '20 – 35 cm (Sedang)', 'value': 27},
    {'label': '35 – 50 cm (Tinggi)', 'value': 42},
    {'label': '> 50 cm (Kritis)', 'value': 60},
  ];

  @override
  void initState() {
    super.initState();
    report = Get.arguments as ReportModel;
    _descController = TextEditingController(text: report.description);
    _selectedCategory = _categories.contains(report.category) ? report.category : _categories[0];
    _selectedHeight = 15;
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _newPhoto = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_descController.text.trim().isEmpty) {
      Get.snackbar('Gagal', 'Deskripsi wajib diisi!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final formData = FormData.fromMap({
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'height': _selectedHeight,
        '_method': 'PUT',
        if (_newPhoto != null)
          'photo': await MultipartFile.fromFile(_newPhoto!.path, filename: 'photo.jpg'),
      });

      final response = await ApiClient.dio.post('/reports/${report.id}', data: formData);

      if (response.statusCode == 200) {
        // Refresh list jika controller terdaftar
        if (Get.isRegistered<ReportHistoryController>()) {
          Get.find<ReportHistoryController>().fetchReportHistory();
        }
        Get.back();
        Get.snackbar(
          'Berhasil',
          'Laporan berhasil diperbarui!',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Gagal memperbarui laporan.';
      Get.snackbar('Gagal', msg, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Laporan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Laporan hanya bisa diedit selama masih dalam status Menunggu.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Original location (readonly)
            _SectionLabel(label: 'Lokasi Laporan'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.grey.shade500, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.address,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Tidak bisa diubah', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category
            _SectionLabel(label: 'Kategori'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val ?? _selectedCategory),
              ),
            ),
            const SizedBox(height: 20),

            // Tinggi banjir
            _SectionLabel(label: 'Estimasi Tinggi Air'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonFormField<int>(
                initialValue: _selectedHeight,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _heightOptions
                    .map((h) => DropdownMenuItem<int>(value: h['value'] as int, child: Text(h['label'] as String)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedHeight = val ?? _selectedHeight),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            _SectionLabel(label: 'Deskripsi'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _descController,
                maxLines: 4,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Jelaskan kondisi banjir secara detail...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Photo
            _SectionLabel(label: 'Foto Banjir (opsional)'),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _newPhoto != null ? AppColors.primaryTeal : Colors.grey.shade200,
                    width: _newPhoto != null ? 2 : 1,
                  ),
                ),
                child: _newPhoto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(_newPhoto!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : report.photoUrl != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: CachedNetworkImage(
                                  imageUrl: report.photoUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Container(color: Colors.grey.shade200),
                                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                                ),
                              ),
                              Positioned(
                                bottom: 8, right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                                  child: const Text('Ketuk untuk ganti', style: TextStyle(color: Colors.white, fontSize: 10)),
                                ),
                              ),
                            ],
                          )
                        : _photoPlaceholder(),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text('Ketuk untuk pilih foto', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
      ),
    );
  }
}
