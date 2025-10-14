import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/controllers/recurring_task_controller.dart';
import 'package:hole_hse_inspection/views/supervisor/create_task.dart';
import 'package:hole_hse_inspection/views/supervisor/recurringTasks.dart';
import '../../controllers/login_controller.dart';
import 'ta_home.dart';
import 'package:hole_hse_inspection/controllers/task_controller.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  _SupervisorDashboardState createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  final LoginController controller = Get.put(LoginController());
  final TaskController taskController = Get.put(TaskController());
  RecurringTaskController recurringTaskController =
      Get.put(RecurringTaskController());

  int _currentIndex = 0;
  String? userRole;
  String? userName;
  bool isLoading = true;

  final List<Widget> _tabs = [
    TaHome(),
    RecurringTasks(),
    CreateTask(),
  ];

  final List<IconData> _tabIcons = [
    Icons.dashboard_rounded,
    Icons.insert_chart,
    Icons.create_new_folder_rounded,
  ];

  final List<String> _tabLabels = [
    'Home',
    'See Tasks',
    'Create Task',
  ];

  @override
  void initState() {
    super.initState();
    _validateSupervisorAccess();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    try {
      // Initialize controllers with error handling
      await Future.wait([
        taskController.getTask().catchError((error) {
          print('Error loading tasks: $error');
          return null;
        }),
        recurringTaskController.getRecurringTask().catchError((error) {
          print('Error loading recurring tasks: $error');
          return null;
        }),
      ]);
    } catch (e) {
      print('Error initializing controllers: $e');
      // Don't block the UI if controller initialization fails
    }
  }

  Future<void> _validateSupervisorAccess() async {
    try {
      var userBox = await Hive.openBox('userBox');
      var userData = userBox.get('userData');
      
      if (userData == null) {
        _redirectToLogin('Session expired. Please login again.');
        return;
      }
      
      userRole = userData['user']['role'];
      userName = userData['user']['name'];
      
      // Validate supervisor role
      if (userRole != 'supervisor') {
        _showRoleError();
        return;
      }
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error validating supervisor access: $e');
      _redirectToLogin('Authentication error. Please login again.');
    }
  }

  void _showRoleError() {
    Get.snackbar(
      "Access Denied",
      "This dashboard is only accessible to supervisors. Your role: ${userRole ?? 'Unknown'}",
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
    );
    
    // Redirect based on actual role
    Future.delayed(Duration(seconds: 2), () {
      if (userRole == 'inspector') {
        Get.offAllNamed('/');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }

  void _redirectToLogin(String message) {
    Get.snackbar(
      "Authentication Required",
      message,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade900,
      duration: Duration(seconds: 3),
    );
    
    Future.delayed(Duration(seconds: 1), () {
      Get.offAllNamed('/login');
    });
  }

  Future<void> _testApiConnection() async {
    try {
      var userBox = await Hive.openBox('userBox');
      var userData = userBox.get('userData');
      
      if (userData == null) {
        Get.snackbar("Error", "No user data found");
        return;
      }
      
      String supervisorId = userData['user']['_id'];
      String url = '${Constants.baseUrl}/api/tasks/get-task-status-supervisor?supervisorId=$supervisorId';
      
      Get.snackbar(
        "Testing API",
        "Calling: $url",
        backgroundColor: Colors.blue.shade100,
        duration: Duration(seconds: 2),
      );
      
      final response = await http.get(Uri.parse(url));
      
      Get.snackbar(
        "API Test Result",
        "Status: ${response.statusCode}\nBody: ${response.body}",
        backgroundColor: response.statusCode == 200 
            ? Colors.green.shade100 
            : Colors.red.shade100,
        duration: Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        "API Test Error",
        "Error: $e",
        backgroundColor: Colors.red.shade100,
        duration: Duration(seconds: 3),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: ColorPalette.primaryColor),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
              ),
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
              ),
              SizedBox(height: 16),
              Text(
                'Validating supervisor access...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.supervisor_account,
              color: ColorPalette.primaryColor,
              size: 28,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Supervisor Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (userName != null)
                  Text(
                    'Welcome, $userName',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ColorPalette.primaryColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user,
                  size: 16,
                  color: ColorPalette.primaryColor,
                ),
                SizedBox(width: 4),
                Text(
                  'Supervisor',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _testApiConnection,
            icon: Icon(
              Icons.wifi_tethering,
              color: ColorPalette.primaryColor,
            ),
            tooltip: 'Test API Connection',
          ),
          IconButton(
            onPressed: _logout,
            icon: Icon(
              Icons.logout,
              color: ColorPalette.primaryColor,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          selectedItemColor: ColorPalette.primaryColor,
          unselectedItemColor: ColorPalette.light2,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 11,
          ),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: List.generate(_tabs.length, (index) {
            return BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? ColorPalette.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _tabIcons[index],
                  size: _currentIndex == index ? 26 : 24,
                ),
              ),
              label: _tabLabels[index],
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
