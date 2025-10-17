import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class SuperAdminController extends GetxController {
  final String baseUrl = Constants.baseUrl;
  
  // Observable variables
  final RxInt totalUsers = 0.obs;
  final RxInt totalSuperAdmins = 0.obs;
  final RxInt totalSupervisors = 0.obs;
  final RxInt totalInspectors = 0.obs;
  final RxList<Map<String, dynamic>> recentUsers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchAllUsers(),
        fetchUsersByRole('superadmin'),
        fetchUsersByRole('supervisor'),
        fetchUsersByRole('inspector'),
      ]);
    } catch (e) {
      print('Error loading dashboard data: $e');
      _showErrorSnackbar('Failed to load dashboard data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
    Get.snackbar(
      'Refreshed',
      'Dashboard data has been updated',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> fetchAllUsers() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse("$baseUrl/api/users/get-all-users"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = List<Map<String, dynamic>>.from(data['data'] ?? []);
        
        totalUsers.value = users.length;
        recentUsers.value = users.take(10).toList();
      } else if (response.statusCode == 404) {
        totalUsers.value = 0;
        recentUsers.clear();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all users: $e');
      _showErrorSnackbar('Failed to fetch users data');
    }
  }

  Future<void> fetchUsersByRole(String role) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return;

      String endpoint;
      switch (role) {
        case 'superadmin':
          endpoint = 'get-all-superadmins';
          break;
        case 'supervisor':
          endpoint = 'get-all-supervisors';
          break;
        case 'inspector':
          endpoint = 'get-all-inspectors';
          break;
        default:
          return;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/api/users/$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = List<Map<String, dynamic>>.from(data['data'] ?? []);
        
        switch (role) {
          case 'superadmin':
            totalSuperAdmins.value = users.length;
            break;
          case 'supervisor':
            totalSupervisors.value = users.length;
            break;
          case 'inspector':
            totalInspectors.value = users.length;
            break;
        }
      } else if (response.statusCode == 404) {
        switch (role) {
          case 'superadmin':
            totalSuperAdmins.value = 0;
            break;
          case 'supervisor':
            totalSupervisors.value = 0;
            break;
          case 'inspector':
            totalInspectors.value = 0;
            break;
        }
      } else {
        throw Exception('Failed to fetch $role users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching $role users: $e');
    }
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    isLoading.value = true;
    try {
      final token = await _getAuthToken();
      if (token == null) {
        _showErrorSnackbar('Authentication required');
        return false;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/users/create-user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'User created successfully',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        
        // Refresh data after creating user
        await loadDashboardData();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _showErrorSnackbar(data['message'] ?? 'Failed to create user');
        return false;
      }
    } catch (e) {
      print('Error creating user: $e');
      _showErrorSnackbar('Failed to create user. Please try again.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> validateSuperAdminAccess() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse("$baseUrl/api/users/validate-super-admin"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isValid'] == true;
      }
      return false;
    } catch (e) {
      print('Error validating super admin access: $e');
      return false;
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

  // Navigation helpers
  void navigateToCreateUser() {
    Get.toNamed('/create-user');
  }

  void navigateToManageUsers() {
    Get.toNamed('/manage-users');
  }

  void navigateToSystemSettings() {
    Get.toNamed('/system-settings');
  }

  void navigateToReports() {
    Get.toNamed('/reports');
  }

  @override
  void onClose() {
    super.onClose();
  }
}
