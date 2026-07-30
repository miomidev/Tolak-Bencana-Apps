import 'user_model.dart';

class CommentModel {
  final String id;
  final String userId;
  final String reportId;
  final String comment;
  final DateTime createdAt;
  final String timeAgo;
  final UserModel? user;

  CommentModel({
    required this.id,
    required this.userId,
    required this.reportId,
    required this.comment,
    required this.createdAt,
    required this.timeAgo,
    this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      reportId: json['report_id'] as String,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      timeAgo: json['time_ago'] as String? ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'report_id': reportId,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'time_ago': timeAgo,
      'user': user?.toJson(),
    };
  }
}
