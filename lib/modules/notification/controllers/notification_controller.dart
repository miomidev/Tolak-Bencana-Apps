import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/models/notification_model.dart';

class NotificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final isGuest = await AuthService.isGuest();
    if (isGuest) return;

    isLoading.value = true;
    try {
      final response = await ApiClient.dio.get('/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['notifications'] as List;
        final list = jsonList
            .map((json) =>
                NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
        notifications.assignAll(list);

        // Sync unread count to NotificationService badge
        if (Get.isRegistered<NotificationService>()) {
          NotificationService.to.unreadCount.value =
              list.where((n) => !n.isRead).length;
        }
      }
    } catch (e) {
      // Quiet fail or snackbar
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    // Optimistic UI update
    notification.isRead = true;
    notifications.refresh();

    // Update badge count
    if (Get.isRegistered<NotificationService>()) {
      final unread = notifications.where((n) => !n.isRead).length;
      NotificationService.to.unreadCount.value = unread;
    }

    try {
      await ApiClient.dio.post('/notifications/${notification.id}/read');
    } catch (e) {
      // Revert on failure
      notification.isRead = false;
      notifications.refresh();
      if (Get.isRegistered<NotificationService>()) {
        final unread = notifications.where((n) => !n.isRead).length;
        NotificationService.to.unreadCount.value = unread;
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final unread = notifications.where((n) => !n.isRead).toList();
    for (final n in unread) {
      await markAsRead(n);
    }
  }

  /// Refresh from NotificationService (triggers a fresh poll)
  Future<void> refreshFromService() async {
    if (Get.isRegistered<NotificationService>()) {
      await NotificationService.to.refresh();
    }
    await fetchNotifications();
  }
}
