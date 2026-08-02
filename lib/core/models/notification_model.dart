class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  bool isRead;
  final DateTime sentAt;
  final String timeAgo;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.sentAt,
    required this.timeAgo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      sentAt: DateTime.parse(json['sent_at'] as String),
      timeAgo: json['time_ago'] as String? ?? '',
    );
  }

  String get formattedDateTime {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final dayName = days[sentAt.weekday - 1];
    final monthName = months[sentAt.month - 1];
    final hour = sentAt.hour.toString().padLeft(2, '0');
    final minute = sentAt.minute.toString().padLeft(2, '0');
    return '$dayName, ${sentAt.day} $monthName ${sentAt.year} • $hour:$minute WIB';
  }

  String get badgeLabel {
    switch (type) {
      case 'emergency_alert':
        return 'SIAGA 1 (BAHAYA)';
      case 'flood_alert':
        return 'SIAGA 2 (WASPADA)';
      case 'report_update':
        return 'STATUS LAPORAN';
      default:
        return 'SIARAN INFORMASI';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'is_read': isRead,
      'sent_at': sentAt.toIso8601String(),
      'time_ago': timeAgo,
    };
  }
}
