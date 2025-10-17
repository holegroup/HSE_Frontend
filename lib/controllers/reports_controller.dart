import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class ReportsController extends GetxController {
  final String baseUrl = Constants.baseUrl;
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString fromDate = ''.obs;
  final RxString toDate = ''.obs;
  
  // Statistics
  final RxInt totalInspections = 0.obs;
  final RxInt activeUsers = 0.obs;
  final RxInt completedTasks = 0.obs;
  final RxDouble systemUptime = 99.5.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDates();
    loadReportData();
  }

  void _initializeDates() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    fromDate.value = _formatDate(firstDayOfMonth);
    toDate.value = _formatDate(now);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> loadReportData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadInspectionData(),
        _loadUserData(),
        _loadTaskData(),
        _loadSystemData(),
      ]);
    } catch (e) {
      print('Error loading report data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadInspectionData() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      totalInspections.value = 156;
    } catch (e) {
      print('Error loading inspection data: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse("$baseUrl/api/users/get-all-users"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = List<Map<String, dynamic>>.from(data['data'] ?? []);
        activeUsers.value = users.length;
      } else {
        activeUsers.value = 0;
      }
    } catch (e) {
      print('Error loading user data: $e');
      activeUsers.value = 0;
    }
  }

  Future<void> _loadTaskData() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      completedTasks.value = 89;
    } catch (e) {
      print('Error loading task data: $e');
    }
  }

  Future<void> _loadSystemData() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 200));
      systemUptime.value = 99.8;
    } catch (e) {
      print('Error loading system data: $e');
    }
  }

  Future<void> refreshReports() async {
    await loadReportData();
    Get.snackbar(
      'Refreshed',
      'Reports have been updated',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 2),
    );
  }

  // Date selection methods
  Future<void> selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: _parseDate(fromDate.value),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      fromDate.value = _formatDate(picked);
      await loadReportData();
    }
  }

  Future<void> selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: _parseDate(toDate.value),
      firstDate: _parseDate(fromDate.value),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      toDate.value = _formatDate(picked);
      await loadReportData();
    }
  }

  DateTime _parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  void setToday() {
    final now = DateTime.now();
    fromDate.value = _formatDate(now);
    toDate.value = _formatDate(now);
    loadReportData();
  }

  void setThisWeek() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    fromDate.value = _formatDate(firstDayOfWeek);
    toDate.value = _formatDate(now);
    loadReportData();
  }

  void setThisMonth() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    fromDate.value = _formatDate(firstDayOfMonth);
    toDate.value = _formatDate(now);
    loadReportData();
  }

  // Report viewing methods
  void viewUserRegistrations() {
    Get.dialog(
      AlertDialog(
        title: const Text('User Registrations'),
        content: const Text('Detailed user registration report will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void viewUserActivity() {
    Get.dialog(
      AlertDialog(
        title: const Text('User Activity'),
        content: const Text('User activity patterns and usage statistics will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void viewRoleDistribution() {
    Get.dialog(
      AlertDialog(
        title: const Text('Role Distribution'),
        content: const Text('User role distribution chart will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void viewInspectionSummary() {
    Get.dialog(
      AlertDialog(
        title: const Text('Inspection Summary'),
        content: const Text('Comprehensive inspection summary report will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void viewComplianceReport() {
    Get.dialog(
      AlertDialog(
        title: const Text('Compliance Report'),
        content: const Text('Safety compliance metrics and analysis will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void viewIssueTracking() {
    Get.dialog(
      AlertDialog(
        title: const Text('Issue Tracking'),
        content: const Text('Open and resolved issues tracking report will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void viewApiUsage() {
    Get.dialog(
      AlertDialog(
        title: const Text('API Usage Statistics'),
        content: const Text('API endpoint usage and performance metrics will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void viewErrorLogs() {
    Get.dialog(
      AlertDialog(
        title: const Text('Error Logs'),
        content: const Text('System errors and warnings log will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void viewDatabasePerformance() {
    Get.dialog(
      AlertDialog(
        title: const Text('Database Performance'),
        content: const Text('Database query performance metrics will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void viewResponseTimes() {
    Get.dialog(
      AlertDialog(
        title: const Text('Response Times'),
        content: const Text('API response time analysis will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void viewResourceUsage() {
    Get.dialog(
      AlertDialog(
        title: const Text('Resource Usage'),
        content: const Text('CPU, Memory, and Storage usage metrics will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void viewLoadBalancing() {
    Get.dialog(
      AlertDialog(
        title: const Text('Load Balancing'),
        content: const Text('Server load distribution analysis will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Export methods
  Future<void> exportAllReports() async {
    _showExportDialog('All Reports', 'PDF');
  }

  Future<void> exportToPDF() async {
    _showExportDialog('Current Report', 'PDF');
  }

  Future<void> exportToExcel() async {
    _showExportDialog('Current Report', 'Excel');
  }

  Future<void> exportToCSV() async {
    _showExportDialog('Current Report', 'CSV');
  }

  Future<void> emailReport() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Email Report'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Email Sent',
                'Report has been sent successfully',
                backgroundColor: Colors.green.shade100,
                colorText: Colors.green.shade900,
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(String reportType, String format) {
    Get.dialog(
      const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Generating report...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
      Get.snackbar(
        'Export Complete',
        '$reportType exported to $format successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    });
  }

  Future<String?> _getAuthToken() async {
    try {
      var userBox = Hive.box('userBox');
      var userData = userBox.get('userData');
      return userData?['token'];
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
