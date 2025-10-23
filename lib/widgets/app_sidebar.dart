import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';

class AppSidebar extends StatefulWidget {
  final String userRole;
  final String? userName;
  
  const AppSidebar({
    Key? key,
    required this.userRole,
    this.userName,
  }) : super(key: key);

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  final LoginController loginController = Get.find<LoginController>();
  int selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
  }
  
  void _updateSelectedIndex() {
    final currentRoute = Get.currentRoute;
    final menuItems = _getMenuItems();
    for (int i = 0; i < menuItems.length; i++) {
      if (menuItems[i].route == currentRoute) {
        setState(() {
          selectedIndex = i;
        });
        break;
      }
    }
  }

  List<SidebarMenuItem> _getMenuItems() {
    switch (widget.userRole.toLowerCase()) {
      case 'superadmin':
        return [
          SidebarMenuItem(
            title: 'Dashboard',
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            route: '/superadmin-dashboard',
          ),
          SidebarMenuItem(
            title: 'User Management',
            icon: Icons.people_outline,
            selectedIcon: Icons.people,
            route: '/manage-users',
          ),
          SidebarMenuItem(
            title: 'Create User',
            icon: Icons.person_add_outlined,
            selectedIcon: Icons.person_add,
            route: '/create-user',
          ),
          SidebarMenuItem(
            title: 'All Tasks',
            icon: Icons.assignment_outlined,
            selectedIcon: Icons.assignment,
            route: '/all-tasks',
          ),
          SidebarMenuItem(
            title: 'Reports',
            icon: Icons.assessment_outlined,
            selectedIcon: Icons.assessment,
            route: '/reports',
          ),
          SidebarMenuItem(
            title: 'Sites',
            icon: Icons.location_city_outlined,
            selectedIcon: Icons.location_city,
            route: '/view-sites',
          ),
          SidebarMenuItem(
            title: 'System Settings',
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            route: '/system-settings',
          ),
          SidebarMenuItem(
            title: 'System Logs',
            icon: Icons.history_outlined,
            selectedIcon: Icons.history,
            route: '/system-logs',
          ),
        ];
      case 'supervisor':
        return [
          SidebarMenuItem(
            title: 'Dashboard',
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            route: '/supervisor-dashboard',
          ),
          SidebarMenuItem(
            title: 'My Tasks',
            icon: Icons.assignment_outlined,
            selectedIcon: Icons.assignment,
            route: '/supervisor-tasks',
          ),
          SidebarMenuItem(
            title: 'Team Management',
            icon: Icons.group_outlined,
            selectedIcon: Icons.group,
            route: '/team-management',
          ),
          SidebarMenuItem(
            title: 'Reports',
            icon: Icons.assessment_outlined,
            selectedIcon: Icons.assessment,
            route: '/supervisor-reports',
          ),
          SidebarMenuItem(
            title: 'Site Data',
            icon: Icons.location_on_outlined,
            selectedIcon: Icons.location_on,
            route: '/view-sites',
          ),
          SidebarMenuItem(
            title: 'New Listings',
            icon: Icons.add_business_outlined,
            selectedIcon: Icons.add_business,
            route: '/new-listing',
          ),
          SidebarMenuItem(
            title: 'Table Data',
            icon: Icons.table_chart_outlined,
            selectedIcon: Icons.table_chart,
            route: '/table-data',
          ),
        ];
      case 'inspector':
      default:
        return [
          SidebarMenuItem(
            title: 'Dashboard',
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            route: '/',
          ),
          SidebarMenuItem(
            title: 'My Tasks',
            icon: Icons.assignment_outlined,
            selectedIcon: Icons.assignment,
            route: '/all-tasks',
          ),
          SidebarMenuItem(
            title: 'Draft Reports',
            icon: Icons.drafts_outlined,
            selectedIcon: Icons.drafts,
            route: '/draft-reports',
          ),
          SidebarMenuItem(
            title: 'Site Inspection',
            icon: Icons.fact_check_outlined,
            selectedIcon: Icons.fact_check,
            route: '/site-inspection',
          ),
          SidebarMenuItem(
            title: 'View Sites',
            icon: Icons.location_on_outlined,
            selectedIcon: Icons.location_on,
            route: '/view-sites',
          ),
          SidebarMenuItem(
            title: 'History',
            icon: Icons.history_outlined,
            selectedIcon: Icons.history,
            route: '/inspection-history',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    
    return Drawer(
      width: isDesktop ? 280 : 260,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorPalette.primaryColor,
                    ColorPalette.primaryColor.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/hole_icon.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.business,
                              size: 40,
                              color: ColorPalette.primaryColor,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // App Name
                    const Text(
                      'HSE BUDDY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // User Info
                    if (widget.userName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getRoleIcon(widget.userRole),
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                widget.userName!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.userRole.toUpperCase(),
                        style: TextStyle(
                          color: ColorPalette.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Menu Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final isSelected = selectedIndex == index;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? ColorPalette.primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: ListTile(
                      leading: Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected
                            ? ColorPalette.primaryColor
                            : Colors.grey.shade600,
                        size: 24,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          color: isSelected
                              ? ColorPalette.primaryColor
                              : Colors.grey.shade800,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      trailing: isSelected
                          ? Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: ColorPalette.primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        // Close drawer on mobile
                        if (!isTablet) {
                          Navigator.pop(context);
                        }
                        Get.toNamed(item.route);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Divider
            Divider(
              color: Colors.grey.shade300,
              thickness: 1,
              height: 1,
            ),
            
            // Bottom Section
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Profile Button
                  ListTile(
                    leading: Icon(
                      Icons.person_outline,
                      color: Colors.grey.shade600,
                    ),
                    title: Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/profile');
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  
                  // Logout Button
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return Icons.admin_panel_settings;
      case 'supervisor':
        return Icons.supervisor_account;
      case 'inspector':
        return Icons.engineering;
      default:
        return Icons.person;
    }
  }
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: ColorPalette.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text('Confirm Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                loginController.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SidebarMenuItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  
  SidebarMenuItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}
