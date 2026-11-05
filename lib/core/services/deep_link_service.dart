import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import '../../modules/dashboard/controllers/dashboard_controller.dart';

/// DeepLinkService
/// - Captures deep links of the form `kaliwedi://report/{id}`
///   or `https://<host>/report/{id}` (from the shared web page).
/// - Exposes [pendingReportId] so the dashboard can show the shared report.
class DeepLinkService extends GetxService {
  static DeepLinkService get to => Get.find<DeepLinkService>();

  final AppLinks _appLinks = AppLinks();

  // Report id coming from a shared/deep link (null when none).
  final RxnString pendingReportId = RxnString();

  late final Stream<Uri> _uriStream;
  StreamSubscription<Uri>? _sub;

  Future<DeepLinkService> init() async {
    // Link that launched the app (cold start).
    final initial = await _getInitialLink();
    if (initial != null) _handle(initial);

    // Link arriving while the app is already running.
    _uriStream = _appLinks.uriLinkStream;
    _sub = _uriStream.listen(_handle);

    return this;
  }

  Future<Uri?> _getInitialLink() async {
    try {
      return await _appLinks.getInitialLink();
    } catch (_) {
      return null;
    }
  }

  void _handle(Uri uri) {
    final id = _extractReportId(uri);
    if (id == null) return;

    pendingReportId.value = id;
    _notifyDashboard();
  }

  /// Parses `kaliwedi://report/{id}` or `https://.../report/{id}`.
  String? _extractReportId(Uri uri) {
    if ((uri.scheme == 'kaliwedi' || uri.scheme == 'tolakbencana') && uri.host == 'report') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }

    if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'report') {
      return uri.pathSegments[1];
    }

    return null;
  }

  void _notifyDashboard() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().handleSharedReport();
    }
  }

  /// Whether a report is waiting to be shown.
  bool get hasPending => pendingReportId.value != null;

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
