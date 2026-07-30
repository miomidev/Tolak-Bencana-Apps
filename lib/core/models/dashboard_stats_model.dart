class DashboardStatsModel {
  final int activeReports;
  final int totalReports;
  final int percentageVerified;

  DashboardStatsModel({
    required this.activeReports,
    required this.totalReports,
    required this.percentageVerified,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      activeReports: json['laporan_aktif'] as int? ?? 0,
      totalReports: json['total_laporan'] as int? ?? 0,
      percentageVerified: json['persentase_terverifikasi'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'laporan_aktif': activeReports,
      'total_laporan': totalReports,
      'persentase_terverifikasi': percentageVerified,
    };
  }
}
