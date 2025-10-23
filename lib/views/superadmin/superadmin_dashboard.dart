import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/superadmin_controller.dart';
import 'package:hive/hive.dart';
import 'dashboard_search_delegate.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/action_card.dart';
import '../../widgets/drawer_button.dart';
import '../../controllers/login_controller.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final Function() onTap;

  DrawerMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final SuperAdminController controller = Get.put(SuperAdminController());
  final LoginController loginController = Get.put(LoginController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentNavIndex = 0;

  // Bottom navigation pages
  final List<String> _navTitles = [
    'HSE Administration',
    'See Tasks',
    'Create Task',
  ];

  final List<IconData> _navIcons = [
    Icons.home,
    Icons.task_alt,
    Icons.add_task,
  ];

  List<DrawerMenuItem> get menuItems => [
        DrawerMenuItem(
          title: 'Dashboard',
          icon: Icons.dashboard,
          onTap: () => Get.offAllNamed('/superadmin-dashboard'),
        ),
        DrawerMenuItem(
          title: 'User Management',
          icon: Icons.people,
          onTap: () => Get.toNamed('/manage-users'),
        ),
        DrawerMenuItem(
          title: 'Create User',
          icon: Icons.person_add,
          onTap: () => Get.toNamed('/create-user'),
        ),
        DrawerMenuItem(
          title: 'Tasks',
          icon: Icons.assignment,
          onTap: () => Get.toNamed('/all-tasks'),
        ),
        DrawerMenuItem(
          title: 'Reports',
          icon: Icons.assessment,
          onTap: () => Get.toNamed('/reports'),
        ),
        DrawerMenuItem(
          title: 'System Settings',
          icon: Icons.settings,
          onTap: () => Get.toNamed('/system-settings'),
        ),
        DrawerMenuItem(
          title: 'System Logs',
          icon: Icons.history,
          onTap: () => Get.toNamed('/system-logs'),
        ),
      ];

  @override
  void initState() {
    super.initState();
    controller.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red,
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 16,
                  color: Colors.red,
                ),
                SizedBox(width: 4),
                Text(
                  'Super Admin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () => _showSearch(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () => controller.refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () => Get.snackbar('Notifications', 'No new notifications'),
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
                    icon: Icons.dashboard,
                    label: "Dashboard",
                    onPressed: () {
                      Navigator.pop(context);
                      Get.offAllNamed('/superadmin-dashboard');
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.people,
                    label: "User Management",
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed('/manage-users');
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.person_add,
                    label: "Create User",
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed('/create-user');
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.assignment,
                    label: "Tasks",
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed('/all-tasks');
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.assessment,
                    label: "Reports",
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed('/reports');
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.settings,
                    label: "System Settings",
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed('/system-settings');
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.history,
                    label: "System Logs",
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed('/system-logs');
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
                    icon: Icons.account_circle,
                    label: "Profile",
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed('/profile');
                    },
                  ),
                  CustomDrawerButton(
                    icon: Icons.logout,
                    label: "Logout",
                    backgroundColor: Colors.red.shade600,
                    onPressed: () {
                      Navigator.pop(context);
                      loginController.logout();
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      body: _buildCurrentPage(),
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
          selectedItemColor: Colors.red,
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
          items: List.generate(_navTitles.length, (index) {
            return BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentNavIndex == index
                      ? Colors.red.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _navIcons[index],
                  size: _currentNavIndex == index ? 26 : 24,
                ),
              ),
              label: _navTitles[index] == 'HSE Administration' ? 'Home' : _navTitles[index],
            );
          }),
        ),
      ),
    );
  }

  // Custom hamburger menu drawer and bottom navigation implemented above

  Widget _buildCurrentPage() {
    switch (_currentNavIndex) {
      case 0:
        return _buildBody(); // Home - Main dashboard
      case 1:
        return _buildTasksPage(); // See Tasks
      case 2:
        return _buildCreateTaskPage(); // Create Task
      default:
        return _buildBody();
    }
  }

  Widget _buildTasksPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Tasks Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'View and manage all system tasks',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTaskPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_task,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Create New Task',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create and assign new tasks to users',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildStatisticsCardsResponsive(width),
            const SizedBox(height: 20),
            _buildQuickActionsResponsive(width),
            if (width >= 600) const SizedBox(height: 24),
            if (width >= 600) _buildDesktopActionStrip(),
          ],
        ),
      );
    });
  }

  Widget _buildWelcomeCard() {
    var userBox = Hive.box('userBox');
    var userData = userBox.get('userData');
    String userName = userData?['user']?['name'] ?? 'Super Admin';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorPalette.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You have full administrative access',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCardsResponsive(double width) {
    int columns = 1;
    if (width >= 1200) {
      columns = 4;
    } else if (width >= 800) {
      columns = 2;
    } else {
      columns = 1;
    }

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        StatCard(
            title: 'Total Users',
            value: controller.totalUsers.value.toString(),
            icon: Icons.people,
            color: Colors.blue),
        StatCard(
            title: 'Tasks',
            value: '15',
            icon: Icons.assignment,
            color: Colors.orange),
        StatCard(
            title: 'Reports',
            value: '8',
            icon: Icons.assessment,
            color: Colors.green),
        StatCard(
            title: 'Alerts',
            value: '3',
            icon: Icons.notifications,
            color: Colors.red),
      ],
    );
  }

  // Quick actions are provided by _buildQuickActionsResponsive

  Widget _buildQuickActionsResponsive(double width) {
    int columns = width >= 1200 ? 4 : (width >= 800 ? 2 : 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2,
          children: [
            ActionCard(
                title: 'Create User',
                icon: Icons.person_add,
                onTap: () => Get.toNamed('/create-user')),
            ActionCard(
                title: 'View Reports',
                icon: Icons.assessment,
                onTap: () => Get.toNamed('/reports')),
            ActionCard(
                title: 'System Settings',
                icon: Icons.settings,
                onTap: () => Get.toNamed('/system-settings')),
            ActionCard(
                title: 'View Logs',
                icon: Icons.history,
                onTap: () => Get.toNamed('/system-logs')),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopActionStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/create-user'),
            icon: const Icon(Icons.person_add),
            label: const Text('Create User'),
            style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => Get.toNamed('/reports'),
            icon: const Icon(Icons.assessment),
            label: const Text('View Reports'),
          ),
          const Spacer(),
          Text(
              'Last updated: ${DateTime.now().toLocal().toString().split('.').first}',
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: DashboardSearchDelegate(),
    );
  }

  // Logout is handled by AdminScaffold drawer
}
