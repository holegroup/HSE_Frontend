import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class CreateUserController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Text Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString selectedRole = 'inspector'.obs;
  
  final String baseUrl = Constants.baseUrl;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> createUser() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Additional validation
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Validation Error",
        "Passwords do not match",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (selectedRole.value.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please select a role",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    isLoading.value = true;

    try {
      final token = await _getAuthToken();
      if (token == null) {
        _showErrorSnackbar('Authentication required. Please login again.');
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/users/create-user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text,
          "role": selectedRole.value,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('Create user response status: ${response.statusCode}');
      print('Create user response body: ${response.body}');

      if (response.body.isEmpty) {
        _showErrorSnackbar('Server is not responding. Please try again later.');
        return;
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        _showErrorSnackbar('Invalid response from server. Please try again.');
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success!",
          "User '${nameController.text.trim()}' created successfully as ${selectedRole.value}",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 4),
        );

        // Clear form
        _clearForm();

        // Navigate back to dashboard after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          Get.back();
        });

      } else if (response.statusCode == 400) {
        _showErrorSnackbar(data['message'] ?? 'User already exists or invalid data');
      } else if (response.statusCode == 401) {
        _showErrorSnackbar('Unauthorized. Please login again.');
        // Navigate to login
        Get.offAllNamed('/login');
      } else if (response.statusCode == 403) {
        _showErrorSnackbar('Access denied. Super admin privileges required.');
      } else {
        _showErrorSnackbar(data['message'] ?? 'An error occurred while creating user');
      }

    } catch (e) {
      print("Create user error: $e");

      if (e.toString().contains('Connection timeout')) {
        _showErrorSnackbar('Server is taking too long to respond. Please try again.');
      } else if (e.toString().contains('SocketException')) {
        _showErrorSnackbar('Unable to connect to server. Please check your connection.');
      } else {
        _showErrorSnackbar('Failed to create user. Please try again.');
      }
    } finally {
      isLoading.value = false;
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

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedRole.value = 'inspector';
    obscurePassword.value = true;
    obscureConfirmPassword.value = true;
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email address';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Check if user has super admin privileges
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

  @override
  void onInit() {
    super.onInit();
    // Validate super admin access when controller initializes
    validateSuperAdminAccess().then((isValid) {
      if (!isValid) {
        Get.snackbar(
          'Access Denied',
          'Super admin privileges required to create users',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        Get.back();
      }
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
