import 'user_model.dart';

class ReportModel {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final String address;
  final String description;
  final String? photoUrl;
  final String severity;
  final String status;
  final String category;
  final DateTime reportedAt;
  final String timeAgo;
  int likesCount;
  int commentsCount;
  bool isLiked;
  final UserModel? user;

  ReportModel({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.description,
    this.photoUrl,
    required this.severity,
    required this.status,
    required this.category,
    required this.reportedAt,
    required this.timeAgo,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    this.user,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      address: json['address'] as String,
      description: json['description'] as String,
      photoUrl: json['photo_url'] as String?,
      severity: json['severity'] as String,
      status: json['status'] as String,
      category: json['category'] as String? ?? 'Bencana',
      reportedAt: DateTime.parse(json['reported_at'] as String),
      timeAgo: json['time_ago'] as String? ?? '',
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'description': description,
      'photo_url': photoUrl,
      'severity': severity,
      'status': status,
      'category': category,
      'reported_at': reportedAt.toIso8601String(),
      'time_ago': timeAgo,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
      'user': user?.toJson(),
    };
  }
}
