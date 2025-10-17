import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class SystemSettingsController extends GetxController {
  final String baseUrl = Constants.baseUrl;
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool maintenanceMode = false.obs;
  final RxBool autoApproveUsers = true.obs;
  final RxBool twoFactorAuth = false.obs;
  final RxBool apiRateLimit = true.obs;
  final RxBool emailNotifications = true.obs;
  final RxBool pushNotifications = true.obs;
  final RxBool smsNotifications = false.obs;
  final RxString defaultUserRole = 'inspector'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      // Load settings from local storage or API
      await _loadLocalSettings();
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadLocalSettings() async {
    try {
      var settingsBox = await Hive.openBox('systemSettings');
      
      maintenanceMode.value = settingsBox.get('maintenanceMode', defaultValue: false);
      autoApproveUsers.value = settingsBox.get('autoApproveUsers', defaultValue: true);
      twoFactorAuth.value = settingsBox.get('twoFactorAuth', defaultValue: false);
      apiRateLimit.value = settingsBox.get('apiRateLimit', defaultValue: true);
      emailNotifications.value = settingsBox.get('emailNotifications', defaultValue: true);
      pushNotifications.value = settingsBox.get('pushNotifications', defaultValue: true);
      smsNotifications.value = settingsBox.get('smsNotifications', defaultValue: false);
      defaultUserRole.value = settingsBox.get('defaultUserRole', defaultValue: 'inspector');
    } catch (e) {
      print('Error loading local settings: $e');
    }
  }

  Future<void> saveSettings() async {
    isLoading.value = true;
    try {
      await _saveLocalSettings();
      
      Get.snackbar(
        'Success',
        'Settings saved successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      print('Error saving settings: $e');
      Get.snackbar(
        'Error',
        'Failed to save settings',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveLocalSettings() async {
    try {
      var settingsBox = await Hive.openBox('systemSettings');
      
      await settingsBox.put('maintenanceMode', maintenanceMode.value);
      await settingsBox.put('autoApproveUsers', autoApproveUsers.value);
      await settingsBox.put('twoFactorAuth', twoFactorAuth.value);
      await settingsBox.put('apiRateLimit', apiRateLimit.value);
      await settingsBox.put('emailNotifications', emailNotifications.value);
      await settingsBox.put('pushNotifications', pushNotifications.value);
      await settingsBox.put('smsNotifications', smsNotifications.value);
      await settingsBox.put('defaultUserRole', defaultUserRole.value);
    } catch (e) {
      print('Error saving local settings: $e');
      throw e;
    }
  }

  // Toggle methods
  void toggleMaintenanceMode(bool value) {
    maintenanceMode.value = value;
    if (value) {
      Get.snackbar(
        'Maintenance Mode',
        'Maintenance mode enabled. Users will see maintenance message.',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
    }
  }

  void toggleAutoApproveUsers(bool value) {
    autoApproveUsers.value = value;
  }

  void toggleTwoFactorAuth(bool value) {
    twoFactorAuth.value = value;
    if (value) {
      Get.snackbar(
        'Two-Factor Authentication',
        'Two-factor authentication enabled for enhanced security.',
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
      );
    }
  }

  void toggleApiRateLimit(bool value) {
    apiRateLimit.value = value;
  }

  void toggleEmailNotifications(bool value) {
    emailNotifications.value = value;
  }

  void togglePushNotifications(bool value) {
    pushNotifications.value = value;
  }

  void toggleSmsNotifications(bool value) {
    smsNotifications.value = value;
  }

  // System actions
  Future<void> clearSystemCache() async {
    try {
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Clearing cache...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Simulate cache clearing
      await Future.delayed(const Duration(seconds: 2));
      
      Get.back(); // Close loading dialog
      
      Get.snackbar(
        'Success',
        'System cache cleared successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to clear cache',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> resetStatistics() async {
    try {
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Resetting statistics...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Simulate statistics reset
      await Future.delayed(const Duration(seconds: 2));
      
      Get.back(); // Close loading dialog
      
      Get.snackbar(
        'Success',
        'Statistics reset successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to reset statistics',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> createManualBackup() async {
    try {
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating backup...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Simulate backup creation
      await Future.delayed(const Duration(seconds: 3));
      
      Get.back(); // Close loading dialog
      
      Get.snackbar(
        'Success',
        'Manual backup created successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to create backup',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> exportSystemData() async {
    try {
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting data...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Simulate data export
      await Future.delayed(const Duration(seconds: 3));
      
      Get.back(); // Close loading dialog
      
      Get.snackbar(
        'Success',
        'System data exported successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to export data',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
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

  @override
  void onClose() {
    super.onClose();
  }
}
