import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/report_model.dart';

class ReportHistoryController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<ReportModel> allReports = <ReportModel>[].obs;
  final RxString activeFilter = 'Semua'.obs; // 'Semua', 'Proses', 'Selesai'

  @override
  void onInit() {
    super.onInit();
    _loadCachedHistory();
    fetchReportHistory();
  }

  Future<void> _loadCachedHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString('cached_my_reports');
      if (cachedString != null) {
        final List data = jsonDecode(cachedString);
        allReports.value = data.map((json) => ReportModel.fromJson(json)).toList();
      }
    } catch (_) {}
  }

  Future<void> fetchReportHistory() async {
    final isGuest = await AuthService.isGuest();
    if (isGuest) return;

    isLoading.value = true;
    try {
      final response = await ApiClient.dio.get('/my-reports');
      if (response.statusCode == 200) {
        final List data = response.data['reports'] ?? [];
        allReports.value = data.map((json) => ReportModel.fromJson(json)).toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_my_reports', jsonEncode(response.data['reports']));
      }
    } catch (e) {
      // Offline fallback is already handled by _loadCachedHistory
    } finally {
      isLoading.value = false;
    }
  }

  List<ReportModel> get filteredReports {
    if (activeFilter.value == 'Semua') {
      return allReports;
    } else if (activeFilter.value == 'Proses') {
      return allReports.where((r) => r.status.toLowerCase() != 'resolved' && r.status.toLowerCase() != 'verified').toList();
    } else {
      // Selesai
      return allReports.where((r) => r.status.toLowerCase() == 'resolved' || r.status.toLowerCase() == 'verified').toList();
    }
  }

  void changeFilter(String filter) {
    activeFilter.value = filter;
  }

  Map<String, List<ReportModel>> get groupedReports {
    final Map<String, List<ReportModel>> grouped = {
      'MINGGU INI': [],
      'MINGGU LALU': [],
      '2 MINGGU LALU': [],
      'LEBIH LAMA': [],
    };

    final now = DateTime.now();
    for (var report in filteredReports) {
      final diff = now.difference(report.reportedAt).inDays;
      if (diff < 7) {
        grouped['MINGGU INI']!.add(report);
      } else if (diff < 14) {
        grouped['MINGGU LALU']!.add(report);
      } else if (diff < 21) {
        grouped['2 MINGGU LALU']!.add(report);
      } else {
        grouped['LEBIH LAMA']!.add(report);
      }
    }

    // Remove empty groups to avoid rendering empty sections
    grouped.removeWhere((key, list) => list.isEmpty);
    return grouped;
  }
}
