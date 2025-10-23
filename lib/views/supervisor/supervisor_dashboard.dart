import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'package:hole_hse_inspection/views/supervisor/ta_home.dart';
import 'package:hole_hse_inspection/views/supervisor/ta_reports.dart';
import 'package:hole_hse_inspection/views/supervisor/ta_tasks.dart';
import 'package:hole_hse_inspection/views/supervisor/ta_team.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/views/supervisor/create_task.dart';
import 'package:hole_hse_inspection/views/supervisor/recurringTasks.dart';
import 'package:hole_hse_inspection/widgets/drawer_button.dart';
import 'package:hole_hse_inspection/views/profile.dart';
import 'package:hole_hse_inspection/views/view_sites.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hole_hse_inspection/controllers/recurring_task_controller.dart';
import 'package:hole_hse_inspection/controllers/task_controller.dart';
import 'package:hive/hive.dart';

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

  String? userRole;
  String? userName;
  bool isLoading = true;

  int _selectedPage = 0;
  int _currentNavIndex = 0;

  final List<Widget> _pages = [
    const TaHome(),
    const RecurringTasks(),
    const CreateTask(),
    const TaReports(),
    const TaTasks(),
    const TaTeam(),
  ];

  final List<String> _pageNames = [
    'Dashboard',
    'Recurring Tasks',
    'Create Task',
    'Reports',
    'Task Management',
    'Team Management',
  ];

  // Bottom navigation pages
  final List<Widget> _navPages = [
    const TaHome(),
    const RecurringTasks(),
    const CreateTask(),
  ];

  final List<String> _navTitles = [
    'Home',
    'See Tasks',
    'Create Task',
  ];

  final List<IconData> _navIcons = [
    Icons.home,
    Icons.task_alt,
    Icons.add_task,
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
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
    );
    
    // Redirect based on actual role
    Future.delayed(const Duration(seconds: 2), () {
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
      duration: const Duration(seconds: 3),
    );
    
    Future.delayed(const Duration(seconds: 1), () {
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
        duration: const Duration(seconds: 2),
      );
      
      final response = await http.get(Uri.parse(url));
      
      Get.snackbar(
        "API Test Result",
        "Status: ${response.statusCode}\nBody: ${response.body}",
        backgroundColor: response.statusCode == 200 
            ? Colors.green.shade100 
            : Colors.red.shade100,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        "API Test Error",
        "Error: $e",
        backgroundColor: Colors.red.shade100,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: ColorPalette.primaryColor),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
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
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
              ),
              const SizedBox(height: 16),
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
        title: Text(
          _navTitles[_currentNavIndex],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: ColorPalette.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ColorPalette.primaryColor,
                  width: 1,
                ),
              ),
              child: const Row(
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
          ),
          IconButton(
            onPressed: _testApiConnection,
            icon: const Icon(
              Icons.wifi_tethering,
              color: ColorPalette.primaryColor,
            ),
            tooltip: 'Test API Connection',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // HSE BUDDY Logo
                  Image.asset(
                    'assets/images/icon.png',
                    filterQuality: FilterQuality.low,
                    width: constraints.maxWidth * 0.4,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: constraints.maxWidth * 0.4,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business,
                              size: 40,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'HSE BUDDY',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                  // Menu Items
                  CustomDrawerButton(
                    icon: Icons.dashboard_rounded,
                    label: "Dashboard",
                    onPressed: () {
                      setState(() {
                        _selectedPage = 0;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.repeat,
                    label: "Recurring Tasks",
                    onPressed: () {
                      setState(() {
                        _selectedPage = 1;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.create_new_folder_rounded,
                    label: "Create Task",
                    onPressed: () {
                      setState(() {
                        _selectedPage = 2;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.description,
                    label: "Reports",
                    onPressed: () {
                      setState(() {
                        _selectedPage = 3;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.task_alt,
                    label: "Task Management",
                    onPressed: () {
                      setState(() {
                        _selectedPage = 4;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.people,
                    label: "Team Management",
                    onPressed: () {
                      setState(() {
                        _selectedPage = 5;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  // Divider
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),
                  // Additional Options
                  CustomDrawerButton(
                    icon: Icons.settings,
                    label: "Profile Settings",
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(() => const Profile());
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.data_usage,
                    label: "View Site Data",
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(() => const ViewSites());
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.logout,
                    label: "Logout",
                    backgroundColor: Colors.red.shade600,
                    onPressed: () {
                      Navigator.pop(context);
                      _logout();
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      body: _navPages[_currentNavIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          selectedItemColor: ColorPalette.primaryColor,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentNavIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),
          onTap: (index) {
            setState(() {
              _currentNavIndex = index;
            });
          },
          items: List.generate(_navPages.length, (index) {
            return BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentNavIndex == index
                      ? ColorPalette.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _navIcons[index],
                  size: _currentNavIndex == index ? 26 : 24,
                ),
              ),
              label: _navTitles[index],
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
