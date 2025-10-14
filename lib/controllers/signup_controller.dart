import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString selectedRole = 'inspector'.obs;
  
  final String baseUrl = Constants.baseUrl;

  Future<void> signup() async {
    // Validation
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error", 
        "Please enter your name",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
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
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/register"),
        headers: {"Content-Type": "application/json"},
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
        Get.snackbar(
          "Registration Successful!", 
          data['message'] ?? "Account created successfully!",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: Duration(seconds: 4),
        );
        
        // Clear form
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        selectedRole.value = 'inspector'; // Reset to default
        
        // Navigate to login after a short delay
        Future.delayed(Duration(seconds: 1), () {
          Get.offNamed('/login');
        });
      } else if (response.statusCode == 400) {
        Get.snackbar(
          "Registration Failed", 
          data['message'] ?? "User already exists or invalid data",
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          duration: Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          "Registration Failed", 
          data['message'] ?? "An error occurred during registration",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: Duration(seconds: 4),
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
          duration: Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          "Registration Error", 
          "Unable to create account. Please check your connection and try again.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: Duration(seconds: 4),
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
