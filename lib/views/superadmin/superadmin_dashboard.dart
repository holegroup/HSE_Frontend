import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/superadmin_controller.dart';
import 'package:hive/hive.dart';
import 'dashboard_search_delegate.dart';
import '../../widgets/unified_scaffold.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/action_card.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    return UnifiedScaffold(
      title: 'HSE Administration',
      actions: [
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
      body: _buildBody(),
    );
  }

  // AppBar and Drawer are provided by AdminScaffold now.

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
