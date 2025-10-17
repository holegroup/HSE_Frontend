import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class ManageUsersController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  
  // Observable variables
  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredUsers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedRoleFilter = 'all'.obs;
  
  final String baseUrl = Constants.baseUrl;

  @override
  void onInit() {
    super.onInit();
    loadAllUsers();
    
    // Listen to search text changes
    searchController.addListener(() {
      filterUsers();
    });
  }

  Future<void> loadAllUsers() async {
    isLoading.value = true;
    try {
      final token = await _getAuthToken();
      if (token == null) {
        _showErrorSnackbar('Authentication required. Please login again.');
        return;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/api/users/get-all-users"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      print('Get all users response status: ${response.statusCode}');
      print('Get all users response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = List<Map<String, dynamic>>.from(data['data'] ?? []);
        
        allUsers.value = users;
        filterUsers(); // Apply current filters
        
      } else if (response.statusCode == 404) {
        allUsers.clear();
        filteredUsers.clear();
      } else if (response.statusCode == 401) {
        _showErrorSnackbar('Session expired. Please login again.');
        Get.offAllNamed('/login');
      } else if (response.statusCode == 403) {
        _showErrorSnackbar('Access denied. Super admin privileges required.');
      } else {
        final data = jsonDecode(response.body);
        _showErrorSnackbar(data['message'] ?? 'Failed to load users');
      }
    } catch (e) {
      print('Error loading users: $e');
      if (e.toString().contains('Connection timeout')) {
        _showErrorSnackbar('Server is taking too long to respond. Please try again.');
      } else {
        _showErrorSnackbar('Failed to load users. Please check your connection.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void filterUsers() {
    List<Map<String, dynamic>> filtered = List.from(allUsers);
    
    // Filter by role
    if (selectedRoleFilter.value != 'all') {
      filtered = filtered.where((user) => user['role'] == selectedRoleFilter.value).toList();
    }
    
    // Filter by search text
    final searchText = searchController.text.toLowerCase().trim();
    if (searchText.isNotEmpty) {
      filtered = filtered.where((user) {
        final name = (user['name'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        return name.contains(searchText) || email.contains(searchText);
      }).toList();
    }
    
    // Sort by creation date (newest first)
    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });
    
    filteredUsers.value = filtered;
  }

  Future<void> refreshUsers() async {
    await loadAllUsers();
    Get.snackbar(
      'Refreshed',
      'User list has been updated',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> deleteUser(String userId) async {
    if (userId.isEmpty) {
      _showErrorSnackbar('Invalid user ID');
      return;
    }

    try {
      final token = await _getAuthToken();
      if (token == null) {
        _showErrorSnackbar('Authentication required. Please login again.');
        return;
      }

      final response = await http.delete(
        Uri.parse("$baseUrl/api/users/delete-user/$userId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'User deleted successfully',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        
        // Refresh the user list
        await loadAllUsers();
      } else {
        final data = jsonDecode(response.body);
        _showErrorSnackbar(data['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      print('Error deleting user: $e');
      _showErrorSnackbar('Failed to delete user. Please try again.');
    }
  }

  Future<void> resetUserPassword(String userId) async {
    if (userId.isEmpty) {
      _showErrorSnackbar('Invalid user ID');
      return;
    }

    try {
      final token = await _getAuthToken();
      if (token == null) {
        _showErrorSnackbar('Authentication required. Please login again.');
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/users/reset-password"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"userId": userId}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Get.dialog(
          AlertDialog(
            title: const Text('Password Reset'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Password has been reset successfully!'),
                const SizedBox(height: 12),
                const Text('New temporary password:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    data['temporaryPassword'] ?? 'newpassword123',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please share this with the user and ask them to change it on first login.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        _showErrorSnackbar(data['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      print('Error resetting password: $e');
      _showErrorSnackbar('Failed to reset password. Please try again.');
    }
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

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 4),
    );
  }

  // Get user statistics
  Map<String, int> getUserStatistics() {
    final stats = {
      'total': allUsers.length,
      'superadmin': 0,
      'supervisor': 0,
      'inspector': 0,
    };

    for (final user in allUsers) {
      final role = user['role'] as String?;
      if (role != null && stats.containsKey(role)) {
        stats[role] = (stats[role] ?? 0) + 1;
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
