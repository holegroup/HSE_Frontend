import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'footer_menu.dart';

class AdminScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final String title;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? leading;

  const AdminScaffold({
    Key? key,
    required this.body,
    this.actions,
    this.bottom,
    this.title = 'HSE Admin',
    this.scaffoldKey,
    this.leading,
  }) : super(key: key);

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: ColorPalette.primaryColor),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // For mobile widths show FooterMenu as bottomNavigationBar; for larger screens show as footer row
    Widget mainContent = SafeArea(child: body);
    Widget? bottomNav;
    if (width < 600) {
      bottomNav = const FooterMenu();
    } else {
      mainContent = Column(
        children: [
          Expanded(child: SafeArea(child: body)),
          const FooterMenu(),
        ],
      );
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title, style: TextStyle(color: ColorPalette.primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: actions,
        bottom: bottom,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Permanent side navigation for desktop/tablet
          if (width >= 600)
            Container(
              width: 280,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // HSE BUDDY Logo Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/icon.png',
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.business,
                                size: 40,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'HSE BUDDY',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        _buildDrawerItem(
                          icon: Icons.dashboard,
                          title: 'Dashboard',
                          onTap: () => Get.toNamed('/superadmin-dashboard'),
                        ),
                        _buildDrawerItem(
                          icon: Icons.people,
                          title: 'Manage Users',
                          onTap: () => Get.toNamed('/manage-users'),
                        ),
                        _buildDrawerItem(
                          icon: Icons.assignment,
                          title: 'Tasks',
                          onTap: () => Get.toNamed('/all-tasks'),
                        ),
                        _buildDrawerItem(
                          icon: Icons.assessment,
                          title: 'Reports',
                          onTap: () => Get.toNamed('/reports'),
                        ),
                        _buildDrawerItem(
                          icon: Icons.settings,
                          title: 'Profile Settings',
                          onTap: () => Get.toNamed('/profile'),
                        ),
                        _buildDrawerItem(
                          icon: Icons.data_usage,
                          title: 'View Sites',
                          onTap: () => Get.toNamed('/view-sites'),
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Divider(),
                        ),
                      ],
                    ),
                  ),
                  // Logout Button at Bottom
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        var box = Hive.box('userBox');
                        box.clear();
                        Get.offAllNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Log-out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Main content area
          Expanded(
            child: mainContent,
          ),
        ],
      ),
      bottomNavigationBar: bottomNav,
    );
  }
}
