import 'package:get/get.dart';
import '../../../core/models/report_model.dart';

class ReportDetailController extends GetxController {
  final Rxn<ReportModel> report = Rxn<ReportModel>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ReportModel) {
      report.value = Get.arguments as ReportModel;
    }
  }
}
