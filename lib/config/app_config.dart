import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

enum Environment { development, staging, production }

class AppConfig {
  static Environment _environment = Environment.production; // Change this to switch environments
  
  // Get current environment
  static Environment get environment => _environment;
  
  // Set environment (useful for testing)
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  // Environment-specific configurations
  static Map<Environment, Map<String, dynamic>> _configs = {
    Environment.development: {
      'baseUrl': _getLocalUrl(),
      'apiTimeout': 10000,
      'enableLogging': true,
      'enableDebugMode': true,
    },
    Environment.staging: {
      'baseUrl': 'https://hse-api.onrender.com',
      'apiTimeout': 15000,
      'enableLogging': true,
      'enableDebugMode': false,
    },
    Environment.production: {
      'baseUrl': 'https://hsebackend.myhsebuddy.com',
      'apiTimeout': 20000,
      'enableLogging': false,
      'enableDebugMode': false,
    },
  };
  
  // Get local URL based on platform
  static String _getLocalUrl() {
    if (kIsWeb) {
      return "http://localhost:5000";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:5000"; // For Android emulator
      // return "http://192.168.1.100:5000"; // For physical device
    } else if (Platform.isIOS) {
      return "http://localhost:5000";
    } else {
      return "http://localhost:5000"; // Desktop
    }
  }
  
  // Get configuration value
  static T getValue<T>(String key) {
    return _configs[_environment]![key] as T;
  }
  
  // Getters for common configurations
  static String get baseUrl => getValue<String>('baseUrl');
  static int get apiTimeout => getValue<int>('apiTimeout');
  static bool get enableLogging => getValue<bool>('enableLogging');
  static bool get enableDebugMode => getValue<bool>('enableDebugMode');
  
  // Fallback URLs (in order of preference)
  static List<String> get fallbackUrls => [
    'https://hsebackend.myhsebuddy.com',
    'https://inspection-app-backend.onrender.com',
    'https://hse-api.onrender.com',
  ];
  
  // API endpoints
  static const String loginEndpoint = "/api/users/login";
  static const String healthEndpoint = "/api/health";
  static const String usersEndpoint = "/api/users";
  static const String tasksEndpoint = "/api/tasks";
  static const String sitesEndpoint = "/api/sites";
  static const String formsEndpoint = "/api/forms";
  static const String productsEndpoint = "/api/products";
  static const String sseEndpoint = "/api/sse";
  
  // Helper methods
  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  
  // Get full endpoint URL
  static String getEndpointUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  // Debug info
  static Map<String, dynamic> get debugInfo => {
    'environment': _environment.toString(),
    'baseUrl': baseUrl,
    'platform': kIsWeb ? 'Web' : Platform.operatingSystem,
    'isDebugMode': kDebugMode,
    'config': _configs[_environment],
  };
}
