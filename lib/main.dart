import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/config/sse_service.dart';
import 'package:hole_hse_inspection/views/camera_view.dart';
import 'package:hole_hse_inspection/views/home.dart';
import 'package:hole_hse_inspection/views/supervisor/supervisor_dashboard.dart';
import 'package:hole_hse_inspection/views/superadmin/superadmin_dashboard.dart';
import 'package:hole_hse_inspection/views/superadmin/create_user_page.dart';
import 'package:hole_hse_inspection/views/superadmin/manage_users_page.dart';
import 'package:hole_hse_inspection/views/superadmin/system_settings_page.dart';
import 'package:hole_hse_inspection/views/superadmin/reports_page.dart';
import 'package:hole_hse_inspection/views/superadmin/system_logs_page.dart';
import 'package:hole_hse_inspection/views/superadmin/profile_page.dart';
import 'package:hole_hse_inspection/views/login.dart';
import 'package:hole_hse_inspection/views/signup.dart';
import 'package:hole_hse_inspection/views/forgot_password.dart';
import 'package:hole_hse_inspection/views/api_test_page.dart';
import 'package:path_provider/path_provider.dart';
// Conditionally import web plugins
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_plugins.dart' if (dart.library.html) 'web_plugins_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize platform-specific plugins immediately for web
  if (kIsWeb) {
    initializeWebPlugins();
  }

  // Start app immediately with loading state, initialize heavy operations in background
  runApp(MyApp(initialRoute: '/loading'));
  
  // Initialize heavy operations in background
  _initializeAppAsync();
}

Future<void> _initializeAppAsync() async {
  try {
    // Initialize Hive for web and mobile platforms differently
    if (kIsWeb) {
      // For web, use default Hive initialization
      Hive.init('hse_buddy_web');
    } else {
      // For mobile platforms, use path provider
      var directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
    }

    // Initialize Hive boxes with error handling
    await Future.wait([
      Hive.openBox('draftBox').catchError((e) {
        print('Error opening draftBox: $e');
        return Hive.box('draftBox');
      }),
      Hive.openBox('userBox').catchError((e) {
        print('Error opening userBox: $e');
        return Hive.box('userBox');
      }),
    ]);

    // Check if user data exists in Hive
    String targetRoute = '/login'; // Default to login
    try {
      var userBox = Hive.box('userBox');
      var userData = userBox.get('userData');

      // Determine target route based on stored data
      if (userData != null && userData['user'] != null) {
        if (userData['user']['role'] == "superadmin") {
          targetRoute = '/superadmin-dashboard';
        } else if (userData['user']['role'] == "supervisor") {
          targetRoute = '/supervisor-dashboard';
        } else if (userData['user']['role'] == "inspector") {
          targetRoute = '/';
        }
      }
    } catch (e) {
      print('Error reading user data: $e');
      // Default to login page if there's an error
      targetRoute = '/login';
    }

    // Initialize platform-specific services for mobile only
    if (!kIsWeb) {
      _initializeMobileServices();
    }

    // Navigate to the determined route
    Get.offAllNamed(targetRoute);
  } catch (e) {
    print('Error during app initialization: $e');
    // Fallback to login if initialization fails
    Get.offAllNamed('/login');
  }
}

void _initializeMobileServices() {
  // Run mobile services initialization in background without blocking
  Future.microtask(() async {
    try {
      SseService sseService = SseService();

      if (Platform.isAndroid) {
        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();

        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          await androidImplementation.requestNotificationsPermission();
        }
      }
      sseService.listenToEvents(); // Start listening when app starts
    } catch (e) {
      print('Error initializing mobile services: $e');
    }
  });
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hole HSE Inspection',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      theme: buildTheme(),
      getPages: [
        GetPage(name: '/loading', page: () => const LoadingScreen()),
        GetPage(name: '/', page: () => const HomePage()),
        GetPage(
            name: '/supervisor-dashboard',
            page: () => const SupervisorDashboard()),
        GetPage(
            name: '/superadmin-dashboard',
            page: () => const SuperAdminDashboard()),
        GetPage(name: '/create-user', page: () => const CreateUserPage()),
        GetPage(name: '/manage-users', page: () => const ManageUsersPage()),
        GetPage(name: '/system-settings', page: () => const SystemSettingsPage()),
        GetPage(name: '/reports', page: () => const ReportsPage()),
        GetPage(name: '/system-logs', page: () => const SystemLogsPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/camera', page: () => CameraView()),
        GetPage(name: '/login', page: () => Login()),
        GetPage(name: '/signup', page: () => const SignupPage()),
        GetPage(name: '/forgot-password', page: () => const ForgotPasswordPage()),
        GetPage(name: '/api-test', page: () => const ApiTestPage()),
      ],
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.security,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            // Loading indicator
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            // Loading text
            Text(
              'Initializing HSE Inspection...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we set up your workspace',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
