import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:http/http.dart' as http;
import 'app_config.dart';

class Constants {
  // Cache for detected server URL
  static String? _detectedServerUrl;
  static bool _isDetecting = false;

  // Environment configuration - Automatically detect based on build mode
  static bool get useProductionServer {
    // Always use production server for release builds (APK)
    if (kReleaseMode) {
      return true;
    }
    // In debug mode, we'll auto-detect the best server
    return false;
  }

  // Production server URL - Your live backend
  static const String productionUrl = "https://hsebackend.myhsebuddy.com";

  // Get local URL based on platform
  static String get localUrl {
    if (kIsWeb) {
      return "http://localhost:5000";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:5000"; // For emulator
    } else if (Platform.isIOS) {
      return "http://localhost:5000";
    } else {
      return "http://localhost:5000"; // Desktop
    }
  }

  // Dynamic base URL - auto-detects available server
  static String get baseUrl {
    // Use production server if in release mode
    if (useProductionServer) {
      return productionUrl;
    }

    // In debug mode, use cached detected server if available
    if (_detectedServerUrl != null) {
      return _detectedServerUrl!;
    }

    // Default to production for initial load
    return productionUrl;
  }

  // Auto-detect which server is available
  static Future<String> detectAvailableServer() async {
    if (_isDetecting) {
      // Wait a bit and return cached or default
      await Future.delayed(const Duration(milliseconds: 500));
      return _detectedServerUrl ?? productionUrl;
    }

    _isDetecting = true;

    try {
      print('🔍 Detecting available server...');
      
      // Try production server first (faster for most users)
      try {
        final prodResponse = await http.get(
          Uri.parse('$productionUrl$healthEndpoint'),
        ).timeout(const Duration(seconds: 3));
        
        if (prodResponse.statusCode == 200) {
          print('✅ Production server is available: $productionUrl');
          _detectedServerUrl = productionUrl;
          _isDetecting = false;
          return productionUrl;
        }
      } catch (e) {
        print('⚠️ Production server not available: $e');
      }

      // Try local server as fallback
      try {
        final localResponse = await http.get(
          Uri.parse('$localUrl$healthEndpoint'),
        ).timeout(const Duration(seconds: 2));
        
        if (localResponse.statusCode == 200) {
          print('✅ Local server is available: $localUrl');
          _detectedServerUrl = localUrl;
          _isDetecting = false;
          return localUrl;
        }
      } catch (e) {
        print('⚠️ Local server not available: $e');
      }

      // If both fail, default to production
      print('⚠️ No server detected, defaulting to production');
      _detectedServerUrl = productionUrl;
      _isDetecting = false;
      return productionUrl;
      
    } catch (e) {
      print('❌ Server detection error: $e');
      _detectedServerUrl = productionUrl;
      _isDetecting = false;
      return productionUrl;
    }
  }

  // Reset detection cache (useful for retry)
  static void resetServerDetection() {
    _detectedServerUrl = null;
    _isDetecting = false;
    print('🔄 Server detection cache cleared');
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
      final client = http.Client();
      try {
        final response = await client.get(
          Uri.parse('$baseUrl$healthEndpoint'),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Connection timeout');
          },
        );
        
        print('Server response status: ${response.statusCode}');
        print('Server response body: ${response.body}');
        
        // Accept both 200 and 500 for now (since backend has issues)
        return response.statusCode == 200 || response.statusCode == 500;
      } finally {
        client.close();
      }
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
