import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/report_model.dart';
import '../controllers/report_history_controller.dart';

class ReportHistoryView extends GetView<ReportHistoryController> {
  const ReportHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 18),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ),
        title: const Text(
          'Riwayat Laporan',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allReports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final grouped = controller.groupedReports;

        return Column(
          children: [
            const SizedBox(height: 10),
            // 1. Filter Tabs Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFilterTab(controller, 'Semua'),
                  _buildFilterTab(controller, 'Proses'),
                  _buildFilterTab(controller, 'Selesai'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. Warning Info Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB), // light amber
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFEF3C7)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.amber.shade800, size: 16),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Riwayat otomatis dihapus setelah 3 bulan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Chronological Reports Feed
            Expanded(
              child: grouped.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_late_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text(
                            'Belum ada riwayat laporan',
                            style: TextStyle(fontSize: 14, color: Colors.black45),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                      itemCount: grouped.keys.length,
                      itemBuilder: (context, sectionIndex) {
                        final sectionTitle = grouped.keys.elementAt(sectionIndex);
                        final reports = grouped[sectionTitle]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    sectionTitle,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '${reports.length} laporan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Section Cards
                            ...reports.map((report) => _buildReportHistoryCard(context, report)),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterTab(ReportHistoryController controller, String label) {
    final bool isActive = controller.activeFilter.value == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeFilter(label),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryTeal : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? AppColors.primaryTeal : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportHistoryCard(BuildContext context, ReportModel report) {
    final bool isResolved = report.status.toLowerCase() == 'resolved' || report.status.toLowerCase() == 'verified';
    final reportCode = 'LP-2026-${report.id.substring(0, 3).toUpperCase()}';
    final dateStr = '${report.reportedAt.day} ${_getMonthName(report.reportedAt.month)} ${report.reportedAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  report.description.length > 50 
                      ? '${report.description.substring(0, 50)}...' 
                      : report.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isResolved ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isResolved ? Icons.check_circle_outline : Icons.access_time,
                      color: isResolved ? Colors.green.shade600 : Colors.orange.shade600,
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isResolved ? 'Selesai' : 'Diproses',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isResolved ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Subtitle: LP ID, Category, Date
          Text(
            '$reportCode · ${report.category}\n$dateStr',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Actions
          if (!isResolved)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showReportDetailBottomSheet(context, report);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE2F2F5),
                      foregroundColor: AppColors.primaryTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showReportDetailBottomSheet(context, report);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFF6FF),
                      foregroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Pantau',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showReportDetailBottomSheet(context, report);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2F2F5),
                  foregroundColor: AppColors.primaryTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showReportDetailBottomSheet(BuildContext context, ReportModel report) {
    final bool isResolved = report.status.toLowerCase() == 'resolved' || report.status.toLowerCase() == 'verified';
    final reportCode = 'LP-2026-${report.id.substring(0, 3).toUpperCase()}';
    final dateStr = '${report.reportedAt.day} ${_getMonthName(report.reportedAt.month)} ${report.reportedAt.year}';
    final dateNextDayStr = '${report.reportedAt.day + 1} ${_getMonthName(report.reportedAt.month)} ${report.reportedAt.year}';

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$reportCode · ${report.category}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isResolved ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isResolved ? Icons.check_circle_outline : Icons.access_time,
                          color: isResolved ? Colors.green.shade600 : Colors.orange.shade600,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isResolved ? 'Selesai' : 'Diproses',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isResolved ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 16),

              // Info Table Container Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Nomor Laporan', reportCode),
                    const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE2E8F0)),
                    _buildInfoRow('Kategori', report.category),
                    const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE2E8F0)),
                    _buildInfoRow('Tanggal Laporan', dateStr),
                    const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE2E8F0)),
                    _buildInfoRow('Status', isResolved ? 'Selesai ditangani' : 'Sedang Diproses'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Progres Penanganan Section Header
              const Text(
                'PROGRES PENANGANAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Timeline
              _buildTimelineItem(
                title: 'Laporan Dikirim',
                time: dateStr,
                isCompleted: true,
                isLast: false,
                isNextLineTeal: true,
              ),
              _buildTimelineItem(
                title: 'Laporan Diterima',
                time: dateNextDayStr,
                isCompleted: true,
                isLast: false,
                isNextLineTeal: isResolved,
              ),
              _buildTimelineItem(
                title: 'Sedang Ditinjau',
                time: isResolved ? dateNextDayStr : '',
                isCompleted: isResolved,
                isLast: false,
                isNextLineTeal: isResolved,
              ),
              _buildTimelineItem(
                title: 'Selesai Ditangani',
                time: isResolved ? dateNextDayStr : '',
                isCompleted: isResolved,
                isLast: true,
                isNextLineTeal: false,
              ),
              const SizedBox(height: 24),

              // Tutup Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String time,
    required bool isCompleted,
    required bool isLast,
    required bool isNextLineTeal,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primaryTeal : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.primaryTeal : Colors.grey.shade300,
                  width: isCompleted ? 1 : 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2.5,
                height: 38,
                color: isNextLineTeal ? AppColors.primaryTeal : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? AppColors.textDark : Colors.grey.shade500,
                ),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }
}
