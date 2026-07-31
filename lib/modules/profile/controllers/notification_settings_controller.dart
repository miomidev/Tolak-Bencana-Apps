import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsController extends GetxController {
  final RxBool pushNotifications = true.obs;
  final RxBool floodAlerts = true.obs;
  final RxBool announcements = true.obs;
  final RxBool reportUpdates = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    pushNotifications.value = prefs.getBool('pref_push_notifications') ?? true;
    floodAlerts.value = prefs.getBool('pref_flood_alerts') ?? true;
    announcements.value = prefs.getBool('pref_announcements') ?? true;
    reportUpdates.value = prefs.getBool('pref_report_updates') ?? true;
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void togglePushNotifications(bool val) {
    pushNotifications.value = val;
    _saveSetting('pref_push_notifications', val);
    
    // Jika push notification dimatikan, matikan juga semua turunannya secara UI
    if (!val) {
      floodAlerts.value = false;
      announcements.value = false;
      reportUpdates.value = false;
      _saveSetting('pref_flood_alerts', false);
      _saveSetting('pref_announcements', false);
      _saveSetting('pref_report_updates', false);
    }
  }

  void toggleFloodAlerts(bool val) {
    floodAlerts.value = val;
    _saveSetting('pref_flood_alerts', val);
    _checkMasterSwitch();
  }

  void toggleAnnouncements(bool val) {
    announcements.value = val;
    _saveSetting('pref_announcements', val);
    _checkMasterSwitch();
  }

  void toggleReportUpdates(bool val) {
    reportUpdates.value = val;
    _saveSetting('pref_report_updates', val);
    _checkMasterSwitch();
  }

  void _checkMasterSwitch() {
    // Jika salah satu aktif, pastikan master switch aktif
    if (floodAlerts.value || announcements.value || reportUpdates.value) {
      if (!pushNotifications.value) {
        pushNotifications.value = true;
        _saveSetting('pref_push_notifications', true);
      }
    }
  }
}
