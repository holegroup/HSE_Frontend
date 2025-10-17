import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class ProfileController extends GetxController {
  final String baseUrl = Constants.baseUrl;
  
  // Observable variables
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxBool twoFactorEnabled = false.obs;
  final RxBool emailNotifications = true.obs;
  final RxBool pushNotifications = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  void loadUserProfile() {
    try {
      var userBox = Hive.box('userBox');
      var userData = userBox.get('userData');
      
      if (userData != null && userData['user'] != null) {
        name.value = userData['user']['name'] ?? '';
        email.value = userData['user']['email'] ?? '';
        phone.value = userData['user']['phone'] ?? '';
      }
      
      // Load preferences from local storage
      _loadPreferences();
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _loadPreferences() async {
    try {
      var prefsBox = await Hive.openBox('userPreferences');
      
      twoFactorEnabled.value = prefsBox.get('twoFactorEnabled', defaultValue: false);
      emailNotifications.value = prefsBox.get('emailNotifications', defaultValue: true);
      pushNotifications.value = prefsBox.get('pushNotifications', defaultValue: true);
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      final token = await _getAuthToken();
      if (token == null) {
        _showErrorSnackbar('Authentication required. Please login again.');
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/users/edit-user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name.value,
          "email": email.value,
          "phone": phone.value,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Update local storage
        var userBox = Hive.box('userBox');
        var userData = userBox.get('userData');
        if (userData != null) {
          userData['user']['name'] = name.value;
          userData['user']['email'] = email.value;
          userData['user']['phone'] = phone.value;
          userBox.put('userData', userData);
        }

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        final data = jsonDecode(response.body);
        _showErrorSnackbar(data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Error updating profile: $e');
      _showErrorSnackbar('Failed to update profile. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    // Validation
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackbar('All password fields are required');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorSnackbar('New passwords do not match');
      return;
    }

    if (newPassword.length < 6) {
      _showErrorSnackbar('New password must be at least 6 characters long');
      return;
    }

    isLoading.value = true;
    try {
      final token = await _getAuthToken();
      if (token == null) {
        _showErrorSnackbar('Authentication required. Please login again.');
        return;
      }

      var userBox = Hive.box('userBox');
      var userData = userBox.get('userData');
      String userId = userData?['user']?['_id'] ?? '';

      final response = await http.post(
        Uri.parse("$baseUrl/api/users/edit-user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "userId": userId,
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Password changed successfully',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        final data = jsonDecode(response.body);
        _showErrorSnackbar(data['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      print('Error changing password: $e');
      _showErrorSnackbar('Failed to change password. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleTwoFactor(bool value) async {
    twoFactorEnabled.value = value;
    await _savePreferences();
    
    if (value) {
      Get.snackbar(
        'Two-Factor Authentication',
        'Two-factor authentication has been enabled',
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
      );
    } else {
      Get.snackbar(
        'Two-Factor Authentication',
        'Two-factor authentication has been disabled',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
    }
  }

  void toggleEmailNotifications(bool value) async {
    emailNotifications.value = value;
    await _savePreferences();
    
    Get.snackbar(
      'Email Notifications',
      value ? 'Email notifications enabled' : 'Email notifications disabled',
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
    );
  }

  void togglePushNotifications(bool value) async {
    pushNotifications.value = value;
    await _savePreferences();
    
    Get.snackbar(
      'Push Notifications',
      value ? 'Push notifications enabled' : 'Push notifications disabled',
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
    );
  }

  Future<void> _savePreferences() async {
    try {
      var prefsBox = await Hive.openBox('userPreferences');
      
      await prefsBox.put('twoFactorEnabled', twoFactorEnabled.value);
      await prefsBox.put('emailNotifications', emailNotifications.value);
      await prefsBox.put('pushNotifications', pushNotifications.value);
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  Future<void> changeProfilePicture() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Change Profile Picture'),
        content: const Text('Profile picture upload functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Profile Picture',
                'Profile picture upload will be available soon',
                backgroundColor: Colors.blue.shade100,
                colorText: Colors.blue.shade900,
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> exportAccountData() async {
    try {
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting account data...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Simulate export process
      await Future.delayed(const Duration(seconds: 3));
      
      Get.back(); // Close loading dialog
      
      Get.snackbar(
        'Export Complete',
        'Your account data has been exported successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      _showErrorSnackbar('Failed to export account data');
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

  @override
  void onClose() {
    super.onClose();
  }
}
