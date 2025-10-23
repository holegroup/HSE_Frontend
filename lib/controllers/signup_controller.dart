import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/config/api_connection_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString selectedRole = 'inspector'.obs;
  final String baseUrl = Constants.baseUrl;

  Future<void> signup() async {
    // First check API connection
    try {
      final connectionStatus = await ApiConnectionTest.checkConnection();
      if (!connectionStatus['connected']) {
        Get.snackbar(
          "Connection Error",
          "Unable to connect to server: ${connectionStatus['error']}",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 4),
        );
        return;
      }
    } catch (e) {
      Get.snackbar(
        "Connection Error",
        "Failed to check server connection. Please try again.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // Validation for required fields
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your name",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    // Additional validation for super admin
    if (selectedRole.value == 'superadmin') {
      try {
        print('Checking if superadmin exists...');
        final validateResponse = await http.get(
          Uri.parse("$baseUrl/api/users/check-superadmin"),
          headers: {"Content-Type": "application/json"},
        ).timeout(const Duration(seconds: 10));

        print('Superadmin check response: ${validateResponse.body}');
        if (validateResponse.statusCode == 200) {
          final validateData = jsonDecode(validateResponse.body);
          if (validateData['superAdminExists'] == true) {
            Get.snackbar(
              "Registration Error",
              "A Super Admin already exists in the system. Only one Super Admin is allowed.",
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
              duration: const Duration(seconds: 5),
            );
            return;
          } else {
            print('No superadmin exists, proceeding with registration...');
          }
        }
      } catch (e) {
        print("Super admin validation error: $e");
        Get.snackbar(
          "Error",
          "Unable to validate Super Admin status. Please try again.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }
    }
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter your email",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid email address",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please enter a password",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        "Validation Error",
        "Password must be at least 6 characters long",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Validation Error",
        "Passwords do not match",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    isLoading.value = true;

    try {
      print('Attempting registration with role: ${selectedRole.value}');

      final Map<String, dynamic> requestBody = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'role': selectedRole.value,
        'registeredAt': DateTime.now().toIso8601String(),
        'isActive': true,
      };

      print('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
        Uri.parse('$baseUrl/api/users/register'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.body.isEmpty) {
        Get.snackbar(
          "Error",
          "Server is not responding. Please try again later.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        Get.snackbar(
          "Error",
          "Invalid response from server. Please try again.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true || response.statusCode == 201) {
          Get.snackbar(
            "Registration Successful!",
            data['message'] ?? "Account created successfully!",
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900,
            duration: const Duration(seconds: 4),
          );

          // Clear form
          nameController.clear();
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          selectedRole.value = 'inspector'; // Reset to default

          // Navigate to login after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            Get.offNamed('/login');
          });
        } else {
          Get.snackbar(
            "Registration Failed",
            data['message'] ?? "Registration failed. Please try again.",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
            duration: const Duration(seconds: 4),
          );
        }
      } else if (response.statusCode == 400) {
        Get.snackbar(
          "Registration Failed",
          data['message'] ?? "User already exists or invalid data",
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          "Registration Failed",
          data['message'] ?? "An error occurred during registration",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print("Signup error: $e");

      if (e.toString().contains('Connection timeout')) {
        Get.snackbar(
          "Connection Timeout",
          "Server is taking too long to respond. Please try again.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          "Registration Error",
          "Unable to create account. Please check your connection and try again.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      isLoading.value = false;
    }
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
