import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../network/api_client.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';

/// NotificationService
/// - Polls the /notifications API every 30 seconds (when user is logged in)
/// - Shows a local notification for each new unread notification received
/// - Exposes [unreadCount] as a reactive observable for badge display
class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Reactive unread count for badge display in nav bar
  final RxInt unreadCount = 0.obs;

  // Track IDs we've already shown a local notification for
  final Set<String> _shownIds = {};

  Timer? _pollTimer;

  // ── Android notification channel ─────────────────────────────────────────
  static const _channelId = 'kaliwedi_broadcast';
  static const _channelName = 'Siaran Peringatan';
  static const _channelDesc =
      'Notifikasi siaran peringatan banjir dari admin KALIWEDI';

  // ── Initialise ────────────────────────────────────────────────────────────
  Future<NotificationService> init() async {
    if (kIsWeb) return this; // local notifications not supported on web

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create the Android notification channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Start polling if user is already logged in
    _maybeStartPolling();

    // React to login / logout events
    ever(AuthService.isLoggedInObs, (bool loggedIn) {
      if (loggedIn) {
        _maybeStartPolling();
      } else {
        _stopPolling();
        unreadCount.value = 0;
        _shownIds.clear();
      }
    });

    return this;
  }

  // ── Polling ───────────────────────────────────────────────────────────────
  void _maybeStartPolling() {
    if (_pollTimer != null && _pollTimer!.isActive) return;
    // Immediate first fetch
    _fetchAndNotify();
    // Then every 30 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchAndNotify();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _fetchAndNotify() async {
    final isGuest = await AuthService.isGuest();
    if (isGuest) return;

    try {
      final response = await ApiClient.dio.get('/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            response.data['notifications'] as List;
        final notifications = jsonList
            .map((j) =>
                NotificationModel.fromJson(j as Map<String, dynamic>))
            .toList();

        // Update unread count
        unreadCount.value =
            notifications.where((n) => !n.isRead).length;

        // Show local notification for each new unread item
        for (final notif in notifications) {
          if (!notif.isRead && !_shownIds.contains(notif.id)) {
            _shownIds.add(notif.id);
            await _showLocalNotification(notif);
          }
        }
      }
    } catch (_) {
      // Quiet fail – network may be unavailable
    }
  }

  // ── Show local notification ───────────────────────────────────────────────
  Future<void> _showLocalNotification(NotificationModel notif) async {
    if (kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(_typeColorValue(notif.type)),
      styleInformation: BigTextStyleInformation(notif.body),
    );

    final details = NotificationDetails(android: androidDetails);

    // Use a stable int ID derived from the UUID
    final intId = notif.id.hashCode.abs() % 100000;

    await _plugin.show(
      id: intId,
      title: notif.title,
      body: notif.body,
      notificationDetails: details,
      payload: notif.id,
    );
  }

  // ── Notification tap handler ──────────────────────────────────────────────
  void _onNotificationTap(NotificationResponse response) {
    // Navigate to notification tab
    Get.toNamed('/notifications');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  int _typeColorValue(String type) {
    switch (type) {
      case 'emergency_alert':
        return 0xFFDC2626; // red
      case 'flood_alert':
        return 0xFFF97316; // orange
      default:
        return 0xFF1E3A8A; // blue
    }
  }

  // ── Manual refresh (called by NotificationController) ────────────────────
  Future<void> refresh() => _fetchAndNotify();

  @override
  void onClose() {
    _stopPolling();
    super.onClose();
  }
}
