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
import 'package:hole_hse_inspection/views/login.dart';
import 'package:hole_hse_inspection/views/signup.dart';
import 'package:hole_hse_inspection/views/forgot_password.dart';
import 'package:hole_hse_inspection/views/api_test_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure URL strategy for web to remove hash from URLs
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }
  
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
  try {
    await Hive.openBox('draftBox');
    await Hive.openBox('userBox');
  } catch (e) {
    print('Error initializing Hive: $e');
  }

  // Check if user data exists in Hive
  String initialRoute = '/login'; // Default to login
  try {
    var userBox = Hive.box('userBox');
    var userData = userBox.get('userData');
    
    // Determine initial route based on stored data
    if (userData != null && userData['user'] != null) {
      if (userData['user']['role'] == "supervisor") {
        initialRoute = '/supervisor-dashboard';
      } else if (userData['user']['role'] == "inspector") {
        initialRoute = '/';
      }
    }
  } catch (e) {
    print('Error reading user data: $e');
    // Default to login page if there's an error
    initialRoute = '/login';
  }

  // Initialize platform-specific services
  if (!kIsWeb) {
    try {
      SseService sseService = SseService();
      
      if (Platform.isAndroid) {
        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          await androidImplementation.requestNotificationsPermission();
        }
      }
      sseService.listenToEvents(); // Start listening when app starts
    } catch (e) {
      print('Error initializing platform services: $e');
    }
  }
  
  runApp(MyApp(initialRoute: initialRoute));
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
        GetPage(name: '/', page: () => HomePage()),
        GetPage(name: '/supervisor-dashboard', page: () => SupervisorDashboard()),
        GetPage(name: '/camera', page: () => CameraView()),
        GetPage(name: '/login', page: () => Login()),
        GetPage(name: '/signup', page: () => SignupPage()),
        GetPage(name: '/forgot-password', page: () => ForgotPasswordPage()),
        GetPage(name: '/api-test', page: () => ApiTestPage()),
      ],
    );
  }
}
