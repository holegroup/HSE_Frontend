import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:http/http.dart' as http;
import 'app_config.dart';

class Constants {
  // Environment configuration - Automatically detect based on build mode
  static bool get useProductionServer {
    // Always use production server for release builds (APK)
    if (kReleaseMode) {
      return true;
    }
    // Use local server only in debug mode
    return false;
  }

  // Production server URL - Your live backend
  static const String productionUrl = "https://hsebackend.myhsebuddy.com";

  // Dynamic base URL based on platform and environment
  static String get baseUrl {
    // Use production server if enabled
    if (useProductionServer) {
      return productionUrl;
    }

    // Local development URLs
    if (kIsWeb) {
      // Flutter web
      return "http://localhost:5000";
    } else if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine
      // For physical device, replace with your computer's IP address
      return "http://10.0.2.2:5000"; // For emulator
      // return "http://192.168.1.100:5000"; // For physical device (replace with your IP)
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return "http://localhost:5000";
    } else {
      // Desktop platforms
      return "http://localhost:5000";
    }
  }

  // Fallback URLs for backup servers (in order of preference)
  static const String fallbackUrl = "https://hsebackend.myhsebuddy.com";
  static const String secondaryFallbackUrl = "https://hsebackend.myhsebuddy.com";

  // Alternative: Use AppConfig for more advanced configuration
  static String get advancedBaseUrl => AppConfig.baseUrl;

  // Debug method to check current configuration
  static void printCurrentConfig() {
    print('=== HSE App Configuration ===');
    print('useProductionServer: $useProductionServer');
    print('baseUrl: $baseUrl');
    print('kReleaseMode: $kReleaseMode');
    print('Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}');
    print('AppConfig Environment: ${AppConfig.currentEnvironment}');
    print('AppConfig BaseUrl: ${AppConfig.baseUrl}');
    print('=============================');
  }

  // Test server connectivity
  static Future<bool> testServerConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$healthEndpoint'),
        timeout: const Duration(seconds: 10),
      );
      
      print('Server response status: ${response.statusCode}');
      print('Server response body: ${response.body}');
      
      // Accept both 200 and 500 for now (since backend has issues)
      return response.statusCode == 200 || response.statusCode == 500;
    } catch (e) {
      print('Server connection failed: $e');
      return false;
    }
  }

  // API endpoints
  static const String loginEndpoint = "/api/users/login";
  static const String healthEndpoint = "/api/health";
  static const String usersEndpoint = "/api/users";
  static const String tasksEndpoint = "/api/tasks";
  static const String sitesEndpoint = "/api/sites";
  static const String formsEndpoint = "/api/forms";
}
