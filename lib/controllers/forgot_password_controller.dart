import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  final RxBool isLoading = false.obs;
  final RxBool showOtpSection = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  
  final String baseUrl = Constants.baseUrl;
  String resetToken = '';

  Future<void> sendResetLink() async {
    // Validation
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

    isLoading.value = true;

    try {
      // Note: This endpoint needs to be created in the backend
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
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

      if (response.statusCode == 200) {
        resetToken = data['token'] ?? '';
        showOtpSection.value = true;
        
        Get.snackbar(
          "Success", 
          "Reset instructions sent to your email!",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else if (response.statusCode == 404) {
        Get.snackbar(
          "Error", 
          "Email not found. Please check and try again.",
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
        );
      } else {
        Get.snackbar(
          "Error", 
          data['message'] ?? "Failed to send reset link",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } catch (e) {
      print("Forgot password error: $e");
      
      // For now, show a demo message since the endpoint doesn't exist
      Get.snackbar(
        "Demo Mode", 
        "Password reset functionality requires backend implementation. For demo, enter any 6-digit OTP.",
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
        duration: const Duration(seconds: 5),
      );
      
      // Show OTP section for demo
      showOtpSection.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    // Validation
    if (otpController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error", 
        "Please enter the OTP code",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }
    
    if (otpController.text.trim().length != 6) {
      Get.snackbar(
        "Validation Error", 
        "OTP must be 6 digits",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }
    
    if (newPasswordController.text.isEmpty) {
      Get.snackbar(
        "Validation Error", 
        "Please enter a new password",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }
    
    if (newPasswordController.text.length < 6) {
      Get.snackbar(
        "Validation Error", 
        "Password must be at least 6 characters long",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }
    
    if (newPasswordController.text != confirmPasswordController.text) {
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
      // Note: This endpoint needs to be created in the backend
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "otp": otpController.text.trim(),
          "newPassword": newPasswordController.text,
          "token": resetToken,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
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

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success", 
          "Password reset successfully! Please login with your new password.",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        
        // Clear form
        emailController.clear();
        otpController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        showOtpSection.value = false;
        
        // Navigate to login
        Get.offNamed('/login');
      } else if (response.statusCode == 400) {
        Get.snackbar(
          "Error", 
          data['message'] ?? "Invalid OTP or expired token",
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
        );
      } else {
        Get.snackbar(
          "Error", 
          data['message'] ?? "Failed to reset password",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } catch (e) {
      print("Reset password error: $e");
      
      // For demo purposes
      Get.snackbar(
        "Demo Success", 
        "In production, this would reset your password. For now, you can login with your existing credentials.",
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 5),
      );
      
      // Navigate to login for demo
      Future.delayed(const Duration(seconds: 2), () {
        Get.offNamed('/login');
      });
    } finally {
      isLoading.value = false;
    }
  }
  
  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
