import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiConnectionTest {
  final String baseUrl = Constants.baseUrl;
  final String fallbackUrl = Constants.fallbackUrl;
  final String secondaryFallbackUrl = Constants.secondaryFallbackUrl;
  
  // Test results storage
  Map<String, bool> testResults = {};
  Map<String, String> errorMessages = {};
  
  // Get current active URL based on connectivity
  Future<String?> getActiveUrl() async {
    // Try primary URL
    if (await testUrl(baseUrl)) return baseUrl;
    // Try fallback URL
    if (await testUrl(fallbackUrl)) return fallbackUrl;
    // Try secondary fallback
    if (await testUrl(secondaryFallbackUrl)) return secondaryFallbackUrl;
    return null;
  }
  
  // Test if a URL is reachable
  Future<bool> testUrl(String url) async {
    try {
      final response = await http.get(
        Uri.parse("$url/api/health"),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Test all API endpoints
  Future<Map<String, dynamic>> testAllEndpoints() async {
    print("🔍 Starting API Connection Tests...\n");
    
    String? activeUrl = await getActiveUrl();
    if (activeUrl == null) {
      return {
        'success': false,
        'message': 'No server is reachable. Please ensure backend is running.',
        'activeUrl': null,
        'results': {}
      };
    }
    
    print("✅ Active Server: $activeUrl\n");
    
    // Test each endpoint group
    await testHealthEndpoints(activeUrl);
    await testUserEndpoints(activeUrl);
    await testTaskEndpoints(activeUrl);
    await testSiteEndpoints(activeUrl);
    await testProductEndpoints(activeUrl);
    await testFormEndpoints(activeUrl);
    await testSSEEndpoints(activeUrl);
    
    // Calculate success rate
    int successCount = testResults.values.where((v) => v).length;
    int totalTests = testResults.length;
    double successRate = (successCount / totalTests) * 100;
    
    return {
      'success': successRate > 80,
      'successRate': successRate,
      'activeUrl': activeUrl,
      'results': testResults,
      'errors': errorMessages,
      'summary': '$successCount/$totalTests endpoints working (${successRate.toStringAsFixed(1)}%)'
    };
  }
  
  // Test Health endpoints
  Future<void> testHealthEndpoints(String url) async {
    print("📋 Testing Health Endpoints:");
    
    // Test health check
    await testEndpoint(
      name: "Health Check",
      method: "GET",
      url: "$url/api/health",
    );
    
    // Test root
    await testEndpoint(
      name: "Root",
      method: "GET",
      url: "$url/",
    );
    
    print("");
  }
  
  // Test User endpoints
  Future<void> testUserEndpoints(String url) async {
    print("👤 Testing User Endpoints:");
    
    await testEndpoint(
      name: "Login",
      method: "POST",
      url: "$url/api/users/login",
      requiresAuth: false,
      testData: {
        "email": "test@test.com",
        "password": "test123"
      }
    );
    
    await testEndpoint(
      name: "Validate Super Admin",
      method: "GET",
      url: "$url/api/users/validate-super-admin",
    );
    
    await testEndpoint(
      name: "Search Users",
      method: "GET",
      url: "$url/api/users/search-users",
    );
    
    print("");
  }
  
  // Test Task endpoints
  Future<void> testTaskEndpoints(String url) async {
    print("📝 Testing Task Endpoints:");
    
    await testEndpoint(
      name: "Get All Tasks",
      method: "GET",
      url: "$url/api/tasks/get-all-tasks",
    );
    
    await testEndpoint(
      name: "Get Tasks",
      method: "GET",
      url: "$url/api/tasks/get-task",
      requiresAuth: true,
    );
    
    await testEndpoint(
      name: "Get Task Date Status",
      method: "GET",
      url: "$url/api/tasks/get-task-date-status",
    );
    
    await testEndpoint(
      name: "Get Recurring Tasks",
      method: "GET",
      url: "$url/api/tasks/get-all-recurring-task",
    );
    
    await testEndpoint(
      name: "Get Task Status Inspector",
      method: "GET",
      url: "$url/api/tasks/get-task-status-inspector",
    );
    
    await testEndpoint(
      name: "Get Task Status Supervisor",
      method: "GET",
      url: "$url/api/tasks/get-task-status-supervisor",
    );
    
    print("");
  }
  
  // Test Site endpoints
  Future<void> testSiteEndpoints(String url) async {
    print("🏢 Testing Site Endpoints:");
    
    await testEndpoint(
      name: "Fetch All Sites",
      method: "GET",
      url: "$url/api/sites/fetch-all-sites",
    );
    
    await testEndpoint(
      name: "Fetch All Temp Items",
      method: "GET",
      url: "$url/api/sites/fetch-all-temp-items",
    );
    
    await testEndpoint(
      name: "Fetch All Temp Parts",
      method: "GET",
      url: "$url/api/sites/fetch-all-temp-parts",
    );
    
    print("");
  }
  
  // Test Product endpoints
  Future<void> testProductEndpoints(String url) async {
    print("📦 Testing Product Endpoints:");
    
    await testEndpoint(
      name: "Fetch All Products",
      method: "GET",
      url: "$url/api/products/fetch-all-items",
    );
    
    await testEndpoint(
      name: "Search Products",
      method: "GET",
      url: "$url/api/products/search-products?query=test",
    );
    
    print("");
  }
  
  // Test Form endpoints
  Future<void> testFormEndpoints(String url) async {
    print("📄 Testing Form Endpoints:");
    
    await testEndpoint(
      name: "Get All Inspections",
      method: "GET",
      url: "$url/api/forms/get-all-inspections",
    );
    
    await testEndpoint(
      name: "Get Inspection by Task",
      method: "GET",
      url: "$url/api/forms/get-inspection-by-task",
    );
    
    print("");
  }
  
  // Test SSE endpoints
  Future<void> testSSEEndpoints(String url) async {
    print("📡 Testing SSE Endpoints:");
    
    await testEndpoint(
      name: "SSE Message Stream",
      method: "GET",
      url: "$url/api/sse/message",
    );
    
    print("");
  }
  
  // Generic endpoint test
  Future<void> testEndpoint({
    required String name,
    required String method,
    required String url,
    bool requiresAuth = false,
    Map<String, dynamic>? testData,
  }) async {
    try {
      http.Response response;
      Map<String, String> headers = {"Content-Type": "application/json"};
      
      // Add auth token if required
      if (requiresAuth) {
        final loginController = Get.find<LoginController>();
        String? token = await loginController.getToken();
        if (token != null) {
          headers["Authorization"] = "Bearer $token";
        }
      }
      
      // Make request based on method
      if (method == "GET") {
        response = await http.get(
          Uri.parse(url),
          headers: headers,
        ).timeout(const Duration(seconds: 5));
      } else if (method == "POST") {
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: testData != null ? jsonEncode(testData) : null,
        ).timeout(const Duration(seconds: 5));
      } else {
        throw Exception("Unsupported method: $method");
      }
      
      // Check response
      bool success = response.statusCode >= 200 && response.statusCode < 500;
      testResults["$method $name"] = success;
      
      if (success) {
        print("  ✅ $name - Status: ${response.statusCode}");
      } else {
        print("  ❌ $name - Status: ${response.statusCode}");
        errorMessages["$method $name"] = "Status: ${response.statusCode}";
      }
      
    } catch (e) {
      testResults["$method $name"] = false;
      errorMessages["$method $name"] = e.toString();
      print("  ❌ $name - Error: ${e.toString().split('\n')[0]}");
    }
  }
  
  // Show results in a dialog
  static Future<void> showTestResults(BuildContext context) async {
    final tester = ApiConnectionTest();
    
    // Show loading dialog
    Get.dialog(
      AlertDialog(
        title: Text("Testing API Connections"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Please wait..."),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    
    // Run tests
    final results = await tester.testAllEndpoints();
    
    // Close loading dialog
    Get.back();
    
    // Show results dialog
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              results['success'] ? Icons.check_circle : Icons.error,
              color: results['success'] ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8),
            Text("API Test Results"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Active Server:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(results['activeUrl'] ?? 'None'),
              SizedBox(height: 16),
              Text(
                "Summary:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(results['summary']),
              SizedBox(height: 16),
              Text(
                "Success Rate:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("${results['successRate'].toStringAsFixed(1)}%"),
              if (results['errors'].isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  "Failed Endpoints:",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                ...results['errors'].entries.map((e) => 
                  Padding(
                    padding: EdgeInsets.only(left: 8, top: 4),
                    child: Text(
                      "• ${e.key}",
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Close"),
          ),
          if (!results['success'])
            TextButton(
              onPressed: () async {
                Get.back();
                showTestResults(context);
              },
              child: Text("Retry"),
            ),
        ],
      ),
    );
  }
}
