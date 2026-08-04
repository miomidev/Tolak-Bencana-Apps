import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kaliwedi_apps/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/deep_link_service.dart';
import '../../../core/models/report_model.dart';
import '../../../core/models/comment_model.dart';
import '../../../core/models/dashboard_stats_model.dart';
import '../../../routes/app_routes.dart';

class DashboardController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isCommentsLoading = false.obs;
  
  final Rxn<DashboardStatsModel> stats = Rxn<DashboardStatsModel>();
  final RxList<ReportModel> allReports = <ReportModel>[].obs;
  final RxList<ReportModel> filteredReports = <ReportModel>[].obs;
  final RxList<CommentModel> currentComments = <CommentModel>[].obs;
  
  final RxString sortBy = 'Terbaru'.obs; // Terbaru or Terdekat
  final RxString searchQuery = ''.obs;
  final RxBool isOffline = false.obs;

  // Report id that should stay pinned at the top of the feed
  // (set when the app is opened from a shared/deep link).
  final RxnString pinnedReportId = RxnString();

  final commentTextController = TextEditingController();

  bool _handledInitialDeepLink = false;

  void toggleOfflineMode() {
    isOffline.value = !isOffline.value;
    if (isOffline.value) {
      Get.snackbar(
        'Mode Offline',
        'Koneksi dinonaktifkan untuk simulasi offline.',
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Mode Online',
        'Koneksi diaktifkan kembali.',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      fetchDashboardData();
    }
  }
  
  Position? userPosition;

  @override
  void onInit() {
    super.onInit();
    _loadCachedDashboardData();
    fetchDashboardData();
    _determinePosition();
  }

  Future<void> _loadCachedDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString('cached_dashboard');
      if (cachedString != null) {
        final data = jsonDecode(cachedString);
        
        // Parse stats
        if (data['stats'] != null) {
          stats.value = DashboardStatsModel.fromJson(data['stats'] as Map<String, dynamic>);
        }
        
        // Parse reports
        if (data['reports'] != null) {
          final List<dynamic> reportsJson = data['reports'] as List;
          final reports = reportsJson.map((json) => ReportModel.fromJson(json as Map<String, dynamic>)).toList();
          allReports.assignAll(reports);
          applyFiltersAndSort();
        }
      }
    } catch (_) {
      // Ignored cache load error
    }
  }

  Future<void> fetchDashboardData() async {
    if (isOffline.value) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiClient.dio.get('/dashboard');
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Parse stats
        stats.value = DashboardStatsModel.fromJson(data['stats'] as Map<String, dynamic>);
        
        // Parse reports
        final List<dynamic> reportsJson = data['reports'] as List;
        final reports = reportsJson.map((json) => ReportModel.fromJson(json as Map<String, dynamic>)).toList();
        
        // Check if there are new reports
        bool hasNewData = false;
        if (allReports.length != reports.length) {
          hasNewData = true;
        } else {
          for (int i = 0; i < reports.length; i++) {
            if (allReports[i].id != reports[i].id || 
                allReports[i].likesCount != reports[i].likesCount || 
                allReports[i].commentsCount != reports[i].commentsCount) {
              hasNewData = true;
              break;
            }
          }
        }
        
        allReports.assignAll(reports);
        applyFiltersAndSort();

        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_dashboard', jsonEncode(data));

        if (hasNewData) {
          Get.snackbar(
            'Sinkronisasi',
            'Data laporan terbaru berhasil disinkronkan dari server.',
            backgroundColor: AppColors.primaryTeal,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } on DioException catch (e) {
      if (allReports.isEmpty) {
        Get.snackbar(
          'Gagal Memuat Data',
          e.response?.data['message'] ?? 'Terjadi kesalahan jaringan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Mode Offline / Terbatas',
          'Gagal menyambung ke server. Menampilkan data cache lokal.',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
      if (!_handledInitialDeepLink) {
        _handledInitialDeepLink = true;
        handleSharedReport();
      }
    }
  }

  /// Opens the report that came from a shared/deep link and pins it
  /// at the top of the feed.
  Future<void> handleSharedReport() async {
    final reportId = DeepLinkService.to.pendingReportId.value;
    if (reportId == null || reportId.isEmpty) return;
    DeepLinkService.to.pendingReportId.value = null;

    pinnedReportId.value = reportId;

    ReportModel? report;
    try {
      report = allReports.firstWhere((r) => r.id == reportId);
    } catch (_) {
      report = null;
    }

    if (report == null) {
      try {
        final response = await ApiClient.dio.get('/reports/$reportId');
        report = ReportModel.fromJson(response.data['report'] as Map<String, dynamic>);
        allReports.insert(0, report);
      } catch (_) {
        pinnedReportId.value = null;
        Get.snackbar(
          'Gagal Memuat Laporan',
          'Laporan yang dibagikan tidak dapat ditemukan.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    applyFiltersAndSort();

    if (Get.currentRoute != Routes.reportDetail) {
      Get.toNamed(Routes.reportDetail, arguments: report);
    }
  }

  void applyFiltersAndSort() {
    List<ReportModel> result = List.from(allReports);

    // Apply Search
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((report) {
        return report.description.toLowerCase().contains(query) ||
               report.address.toLowerCase().contains(query) ||
               report.category.toLowerCase().contains(query) ||
               (report.user?.name.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply Sort
    if (sortBy.value == 'Terbaru') {
      result.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    } else if (sortBy.value == 'Terdekat' && userPosition != null) {
      // Sort by distance to user position
      result.sort((a, b) {
        final distA = Geolocator.distanceBetween(
          userPosition!.latitude, userPosition!.longitude, a.latitude, a.longitude);
        final distB = Geolocator.distanceBetween(
          userPosition!.latitude, userPosition!.longitude, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });
    } else if (sortBy.value == 'Terdekat') {
      // Fallback if location not ready yet, keep original
    }

    // Keep the shared/deep-linked report pinned at the very top
    final pinnedId = pinnedReportId.value;
    if (pinnedId != null) {
      final idx = result.indexWhere((r) => r.id == pinnedId);
      if (idx > 0) {
        final pinned = result.removeAt(idx);
        result.insert(0, pinned);
      }
    }

    filteredReports.assignAll(result);
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applyFiltersAndSort();
  }

  void updateSortBy(String sort) {
    sortBy.value = sort;
    applyFiltersAndSort();
  }

  // Toggle Like API Call with optimistic updates
  Future<void> toggleLike(ReportModel report) async {
    final originalIsLiked = report.isLiked;
    final originalLikesCount = report.likesCount;

    // Optimistic UI Update
    report.isLiked = !report.isLiked;
    report.likesCount = report.isLiked ? report.likesCount + 1 : report.likesCount - 1;
    filteredReports.refresh();

    try {
      final response = await ApiClient.dio.post('/reports/${report.id}/like');
      if (response.statusCode == 200) {
        final data = response.data;
        report.isLiked = data['is_liked'] as bool;
        report.likesCount = data['likes_count'] as int;
        filteredReports.refresh();
      }
    } catch (e) {
      // Revert on failure
      report.isLiked = originalIsLiked;
      report.likesCount = originalLikesCount;
      filteredReports.refresh();
      Get.snackbar(
        'Gagal',
        'Tidak dapat menyukai laporan saat ini.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Comments Handling
  Future<void> fetchComments(String reportId) async {
    isCommentsLoading.value = true;
    currentComments.clear();
    try {
      final response = await ApiClient.dio.get('/reports/$reportId/comments');
      if (response.statusCode == 200) {
        final List<dynamic> commentsJson = response.data['comments'] as List;
        final comments = commentsJson.map((json) => CommentModel.fromJson(json as Map<String, dynamic>)).toList();
        currentComments.assignAll(comments);
      }
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat komentar.');
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> addComment(ReportModel report) async {
    final text = commentTextController.text.trim();
    if (text.isEmpty) return;

    commentTextController.clear();
    
    // Add temporary comment to list for instant feel
    try {
      final response = await ApiClient.dio.post(
        '/reports/${report.id}/comments',
        data: {'comment': text},
      );
      if (response.statusCode == 201) {
        final newComment = CommentModel.fromJson(response.data['comment'] as Map<String, dynamic>);
        currentComments.add(newComment);
        
        // Update comments count on the report card
        report.commentsCount += 1;
        filteredReports.refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Gagal Mengirim',
        'Gagal mengirim komentar.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    } 

    try {
      userPosition = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      if (sortBy.value == 'Terdekat') {
        applyFiltersAndSort();
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    commentTextController.dispose();
    super.onClose();
  }
}
