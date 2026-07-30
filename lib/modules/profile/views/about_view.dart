import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/app_info_model.dart';
import '../../../core/network/api_client.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  AppInfoModel? _appInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppInfo();
  }

  Future<void> _fetchAppInfo() async {
    try {
      final response = await ApiClient.dio.get('/app-info');
      if (response.statusCode == 200) {
        setState(() {
          _appInfo = AppInfoModel.fromJson(response.data['data'] as Map<String, dynamic>);
          _isLoading = false;
        });
      }
    } on DioException {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Tentang Aplikasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),

                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryTeal.withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            _appInfo?.appName ?? 'Kaliwedi',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Versi 1.4.2 (Build 142)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),

                          _Card(
                            child: Column(
                              children: [
                                _InfoRow(label: 'Pengembang', value: _appInfo?.developer ?? '-'),
                                const _CardDivider(),
                                _InfoRow(label: 'Dirilis', value: '2026'),
                                const _CardDivider(),
                                _InfoRow(label: 'Diperbarui', value: '2026'),
                                const _CardDivider(),
                                _InfoRow(label: 'Platform', value: 'iOS & Android'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          _Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                _appInfo?.description ?? '',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.grey.shade600,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          _Card(
                            child: Column(
                              children: [
                                _LinkRow(
                                  icon: Icons.shield_outlined,
                                  iconColor: const Color(0xFF0F767E),
                                  iconBg: const Color(0xFFCCF0F2),
                                  title: 'Kebijakan Privasi',
                                  onTap: () => _showPrivacySheet(context),
                                ),
                                const _CardDivider(),
                                _LinkRow(
                                  icon: Icons.description_outlined,
                                  iconColor: const Color(0xFF7C3AED),
                                  iconBg: const Color(0xFFEDE9FE),
                                  title: 'Syarat & Ketentuan',
                                  onTap: () => _showTermsSheet(context),
                                ),
                                const _CardDivider(),
                                _LinkRow(
                                  icon: Icons.language_outlined,
                                  iconColor: const Color(0xFF059669),
                                  iconBg: const Color(0xFFD1FAE5),
                                  title: 'Website Resmi',
                                  subtitle: _appInfo?.website.replaceAll(RegExp(r'^https?://'), '') ?? '',
                                  onTap: () {
                                    Get.snackbar(
                                      'Website',
                                      'Membuka ${_appInfo?.website ?? ''}...',
                                      backgroundColor: AppColors.primaryTeal,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          Text(
                            'Â© 2026 Pemerintah Kabupaten Indramayu. Hak cipta dilindungi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySheet(BuildContext context) {
    final content = _appInfo?.privacyPolicyContent;
    if (content == null || content.isEmpty) {
      Get.snackbar('Info', 'Konten kebijakan privasi belum tersedia.');
      return;
    }

    Get.bottomSheet(
      _LegalSheet(
        title: 'Kebijakan Privasi',
        content: Text(
          content,
          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700, height: 1.6),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showTermsSheet(BuildContext context) {
    final content = _appInfo?.termsContent;
    if (content == null || content.isEmpty) {
      Get.snackbar('Info', 'Konten syarat & ketentuan belum tersedia.');
      return;
    }

    Get.bottomSheet(
      _LegalSheet(
        title: 'Syarat & Ketentuan',
        content: Text(
          content,
          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700, height: 1.6),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F5F9));
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textDark, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _LinkRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  if (subtitle != null)
                    Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LegalSheet extends StatelessWidget {
  final String title;
  final Widget content;
  const _LegalSheet({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
            child: SingleChildScrollView(child: content),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
