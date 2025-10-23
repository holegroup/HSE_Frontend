import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString selectedRole = 'inspector'.obs;
  final String baseUrl = Constants.baseUrl;

  Future<http.Response?> _attemptLogin(String url, String email, String password) async {
    try {
      return await http.post(
        Uri.parse("$url/api/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password.trim(),
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );
    } catch (e) {
      print("Failed to connect to $url: $e");
      return null;
    }
  }

  Future<void> login() async {
    // Input validation
    if (emailController.text.trim().isEmpty) {
      Get.snackbar("Validation Error", "Please enter your email");
      return;
    }
    
    if (passwordController.text.trim().isEmpty) {
      Get.snackbar("Validation Error", "Please enter your password");
      return;
    }
    
    // Basic email format validation
    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar("Validation Error", "Please enter a valid email address");
      return;
    }

    isLoading.value = true;

    try {
      // Auto-detect available server
      String serverUrl = await Constants.detectAvailableServer();
      print('📡 Using server: $serverUrl');
      
      // Try detected server
      http.Response? response = await _attemptLogin(
        serverUrl, 
        emailController.text, 
        passwordController.text
      );
      
      // If detected server fails, try the other one
      if (response == null) {
        print("Detected server failed, trying alternative...");
        String alternativeUrl = serverUrl == Constants.productionUrl 
            ? Constants.localUrl 
            : Constants.productionUrl;
        
        response = await _attemptLogin(
          alternativeUrl, 
          emailController.text, 
          passwordController.text
        );
      }
      
      // If all servers fail
      if (response == null) {
        Get.snackbar(
          "Connection Failed",
          "Cannot connect to any server. Please check your internet connection and try again.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      // Check if response body is empty or invalid
      if (response.body.isEmpty) {
        Get.snackbar("Connection Error", "Server is not responding. Please try again later.");
        return;
      }
      
      // Try to decode JSON with error handling
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        Get.snackbar("Response Error", "Invalid response from server. Please try again.");
        return;
      }

      if (response.statusCode == 200) {
        // Check if the user's role matches the selected role
        String userRole = data['user']["role"];
        
        if (userRole != selectedRole.value) {
          Get.snackbar(
            "Role Mismatch", 
            "Your account role is '$userRole' but you selected '${selectedRole.value}'. Please select the correct role.",
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade900,
          );
          return;
        }
        
        if (userRole == "inspector" || userRole == "supervisor" || userRole == "superadmin") {
          var userBox = await Hive.openBox('userBox');
          userBox.put('userData', data); // Store the complete response data for future access

          // Navigate based on role
          if (userRole == "inspector") {
            Get.snackbar(
              "Login Success", 
              "Welcome back, ${data['user']['name']}!",
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade900,
            );
            Get.offAllNamed('/');
          } else if (userRole == "supervisor") {
            Get.snackbar(
              "Login Success", 
              "Welcome back, ${data['user']['name']}!",
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade900,
            );
            Get.offAllNamed('/supervisor-dashboard');
          } else if (userRole == "superadmin") {
            Get.snackbar(
              "Login Success", 
              "Welcome back, Super Admin ${data['user']['name']}!",
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade900,
            );
            Get.offAllNamed('/superadmin-dashboard');
          }
        } else {
          Get.snackbar(
            "Login Error", 
            "You are not an authorised member",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
        }
      } else if (response.statusCode == 401) {
        Get.snackbar("Login Failed", data['message'] ?? "Invalid credentials");
      } else if (response.statusCode == 500) {
        Get.snackbar("Server Error", "Internal server error. Please try again later.");
      } else if (response.statusCode == 503) {
        Get.snackbar("Service Unavailable", "Server is currently unavailable. Please try again later.");
      } else {
        Get.snackbar("Login Failed", data['message'] ?? "An error occurred during login");
      }
    } catch (e) {
      print("Login error: $e");
      if (e.toString().contains('timeout')) {
        Get.snackbar("Connection Timeout", "Please check your internet connection and try again.");
      } else if (e.toString().contains('SocketException')) {
        Get.snackbar("Network Error", "Unable to connect to server. Please check your internet connection.");
      } else if (e.toString().contains('FormatException')) {
        Get.snackbar("Server Error", "Invalid response from server. Please try again later.");
      } else {
        Get.snackbar("Error", "An unexpected error occurred. Please try again.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    var userBox = await Hive.openBox('userBox');
    await userBox.clear();
    Get.offAllNamed('/login'); 
  }

  Future<String?> getToken() async {
    try {
      var userBox = await Hive.openBox('userBox');
      final userData = userBox.get('userData');
      if (userData != null && userData['token'] != null) {
        return userData['token'];
      }
      return null;
    } catch (e) {
      Get.snackbar("Error", "Failed to retrieve token: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      var userBox = await Hive.openBox('userBox');
      final userData = userBox.get('userData');
      // print('user data: ${userData}');
      if (userData != null) {
        // Return the data in a map
        return {
          'name': userData['user']['name'],
          // 'image': userData['profileImage'],
          'email': userData['user']['email'],
          'role': userData['user']['role'],
          'id': userData['user']['_id'],
        };
      }
      return null;
    } catch (e) {
      Get.snackbar("Error", "Failed to retrieve user data: $e");
      return null;
    }
  }

  Future<bool> testServerConnection() async {
    try {
      // Test primary server
      final response = await http.get(
        Uri.parse("${Constants.baseUrl}/api/health"),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return true;
      }
      
      // Test fallback server
      final fallbackResponse = await http.get(
        Uri.parse("${Constants.fallbackUrl}/api/health"),
      ).timeout(const Duration(seconds: 10));
      
      return fallbackResponse.statusCode == 200;
    } catch (e) {
      print("Server connectivity test failed: $e");
      return false;
    }
  }

  void _showServerInstructions() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Backend Server Setup'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'To fix the connection error, please start the backend server:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Step 1: Navigate to the backend folder'),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'c:\\Users\\USER\\Downloads\\HSE\\hse_buddy_backend-main',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const Text('Step 2: Run the startup script'),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Double-click: START_BACKEND_SERVER.bat',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const Text('Step 3: Wait for server to start'),
              Text(
                'You should see: "Server is listening on port 5000"',
                style: TextStyle(fontSize: 12, color: Colors.green.shade700),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Ready to Try Again?',
                'If you\'ve started the backend server, you can now try logging in.',
                backgroundColor: Colors.blue.shade100,
                colorText: Colors.blue.shade900,
              );
            },
            child: const Text('I\'ve Started the Server'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    // emailController.dispose();
    // passwordController.dispose();
    super.onClose();
  }
}
