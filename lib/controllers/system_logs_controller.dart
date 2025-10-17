import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class SystemLogsController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final String baseUrl = Constants.baseUrl;
  
  // Observable variables
  final RxList<Map<String, dynamic>> allLogs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredLogs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedLogLevel = 'all'.obs;
  
  final List<String> logLevels = ['all', 'info', 'warning', 'error', 'debug'];

  @override
  void onInit() {
    super.onInit();
    loadLogs();
    
    // Listen to search text changes
    searchController.addListener(() {
      filterLogs();
    });
  }

  Future<void> loadLogs() async {
    isLoading.value = true;
    try {
      // Generate sample logs for demonstration
      await _generateSampleLogs();
      filterLogs();
    } catch (e) {
      print('Error loading logs: $e');
      _showErrorSnackbar('Failed to load system logs');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _generateSampleLogs() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final sampleLogs = [
      {
        'id': '1',
        'level': 'info',
        'message': 'User login successful',
        'fullMessage': 'User john.doe@example.com logged in successfully from IP 192.168.1.100',
        'timestamp': '2024-10-17 14:30:25',
        'source': 'AuthController',
        'userId': 'user_123',
        'ipAddress': '192.168.1.100',
        'stackTrace': null,
      },
      {
        'id': '2',
        'level': 'warning',
        'message': 'High API usage detected',
        'fullMessage': 'API endpoint /api/users/get-all-users has been called 150 times in the last minute, approaching rate limit',
        'timestamp': '2024-10-17 14:28:15',
        'source': 'RateLimiter',
        'userId': null,
        'ipAddress': '192.168.1.50',
        'stackTrace': null,
      },
      {
        'id': '3',
        'level': 'error',
        'message': 'Database connection failed',
        'fullMessage': 'Failed to connect to MongoDB database: Connection timeout after 30 seconds',
        'timestamp': '2024-10-17 14:25:10',
        'source': 'DatabaseService',
        'userId': null,
        'ipAddress': null,
        'stackTrace': 'Error: Connection timeout\n    at DatabaseService.connect (/app/services/database.js:45)\n    at async Server.start (/app/index.js:23)',
      },
      {
        'id': '4',
        'level': 'info',
        'message': 'New user registration',
        'fullMessage': 'New user registered: jane.smith@example.com with role inspector',
        'timestamp': '2024-10-17 14:20:45',
        'source': 'UserController',
        'userId': 'user_124',
        'ipAddress': '192.168.1.75',
        'stackTrace': null,
      },
      {
        'id': '5',
        'level': 'debug',
        'message': 'Cache invalidation triggered',
        'fullMessage': 'User cache invalidated for user_123 due to profile update',
        'timestamp': '2024-10-17 14:18:30',
        'source': 'CacheService',
        'userId': 'user_123',
        'ipAddress': null,
        'stackTrace': null,
      },
      {
        'id': '6',
        'level': 'error',
        'message': 'Failed to send notification',
        'fullMessage': 'Email notification failed to send to user@example.com: SMTP server unreachable',
        'timestamp': '2024-10-17 14:15:20',
        'source': 'NotificationService',
        'userId': 'user_125',
        'ipAddress': null,
        'stackTrace': 'Error: SMTP connection failed\n    at NotificationService.sendEmail (/app/services/notification.js:78)\n    at async TaskController.notifyUser (/app/controllers/task.js:156)',
      },
      {
        'id': '7',
        'level': 'warning',
        'message': 'Disk space running low',
        'fullMessage': 'Server disk space is at 85% capacity. Consider cleaning up old logs or expanding storage.',
        'timestamp': '2024-10-17 14:10:00',
        'source': 'SystemMonitor',
        'userId': null,
        'ipAddress': null,
        'stackTrace': null,
      },
      {
        'id': '8',
        'level': 'info',
        'message': 'Backup completed successfully',
        'fullMessage': 'Daily database backup completed successfully. Backup size: 2.3GB, Duration: 45 minutes',
        'timestamp': '2024-10-17 02:00:00',
        'source': 'BackupService',
        'userId': null,
        'ipAddress': null,
        'stackTrace': null,
      },
      {
        'id': '9',
        'level': 'error',
        'message': 'Invalid API request',
        'fullMessage': 'Invalid request to /api/users/create-user: Missing required field "email"',
        'timestamp': '2024-10-17 13:45:30',
        'source': 'ValidationMiddleware',
        'userId': 'user_126',
        'ipAddress': '192.168.1.200',
        'stackTrace': null,
      },
      {
        'id': '10',
        'level': 'info',
        'message': 'System startup completed',
        'fullMessage': 'HSE Inspection System started successfully on port 5000. All services initialized.',
        'timestamp': '2024-10-17 08:00:00',
        'source': 'Server',
        'userId': null,
        'ipAddress': null,
        'stackTrace': null,
      },
    ];
    
    allLogs.value = sampleLogs;
  }

  void filterLogs() {
    List<Map<String, dynamic>> filtered = List.from(allLogs);
    
    // Filter by log level
    if (selectedLogLevel.value != 'all') {
      filtered = filtered.where((log) => log['level'] == selectedLogLevel.value).toList();
    }
    
    // Filter by search text
    final searchText = searchController.text.toLowerCase().trim();
    if (searchText.isNotEmpty) {
      filtered = filtered.where((log) {
        final message = (log['message'] ?? '').toString().toLowerCase();
        final fullMessage = (log['fullMessage'] ?? '').toString().toLowerCase();
        final source = (log['source'] ?? '').toString().toLowerCase();
        return message.contains(searchText) || 
               fullMessage.contains(searchText) || 
               source.contains(searchText);
      }).toList();
    }
    
    // Sort by timestamp (newest first)
    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });
    
    filteredLogs.value = filtered;
  }

  Future<void> refreshLogs() async {
    await loadLogs();
    Get.snackbar(
      'Refreshed',
      'System logs have been updated',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> clearLogs() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all system logs? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              
              // Show loading
              Get.dialog(
                const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Clearing logs...'),
                    ],
                  ),
                ),
                barrierDismissible: false,
              );

              // Simulate clearing
              await Future.delayed(const Duration(seconds: 2));
              
              allLogs.clear();
              filteredLogs.clear();
              
              Get.back(); // Close loading dialog
              
              Get.snackbar(
                'Success',
                'All system logs have been cleared',
                backgroundColor: Colors.green.shade100,
                colorText: Colors.green.shade900,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> exportLogs() async {
    try {
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting logs...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Simulate export
      await Future.delayed(const Duration(seconds: 3));
      
      Get.back(); // Close loading dialog
      
      Get.snackbar(
        'Export Complete',
        'System logs exported successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      _showErrorSnackbar('Failed to export logs');
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 4),
    );
  }

  // Get log statistics
  Map<String, int> getLogStatistics() {
    final stats = {
      'total': allLogs.length,
      'info': 0,
      'warning': 0,
      'error': 0,
      'debug': 0,
    };

    for (final log in allLogs) {
      final level = log['level'] as String?;
      if (level != null && stats.containsKey(level)) {
        stats[level] = (stats[level] ?? 0) + 1;
      }
    }

    return stats;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
