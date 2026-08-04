import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/report_model.dart';

class ReportDetailController extends GetxController {
  final Rxn<ReportModel> report = Rxn<ReportModel>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromArguments();
  }

  void _loadFromArguments() {
    final args = Get.arguments;
    if (args is ReportModel) {
      report.value = args;
    } else if (args is String) {
      fetchReport(args);
    }
  }

  /// Updates the page when navigated again with different arguments.
  void applyArguments(dynamic args) {
    if (args is ReportModel && report.value?.id != args.id) {
      report.value = args;
      isLoading.value = false;
    } else if (args is String && report.value?.id != args) {
      fetchReport(args);
    }
  }

  Future<void> fetchReport(String id) async {
    isLoading.value = true;
    try {
      final response = await ApiClient.dio.get('/reports/$id');
      if (response.statusCode == 200) {
        report.value = ReportModel.fromJson(response.data['report'] as Map<String, dynamic>);
      }
    } catch (_) {
      // Keep existing value; page will show "Laporan tidak ditemukan"
    } finally {
      isLoading.value = false;
    }
  }
}
