import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'app_sidebar.dart';

class UnifiedScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final bool showDrawer;
  final bool automaticallyImplyLeading;
  
  const UnifiedScaffold({
    Key? key,
    required this.body,
    required this.title,
    this.actions,
    this.bottom,
    this.floatingActionButton,
    this.showDrawer = true,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);

  @override
  State<UnifiedScaffold> createState() => _UnifiedScaffoldState();
}

class _UnifiedScaffoldState extends State<UnifiedScaffold> {
  final LoginController loginController = Get.put(LoginController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  String? userRole;
  String? userName;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      final userData = await loginController.getUserData();
      if (userData != null) {
        setState(() {
          userRole = userData['role'];
          userName = userData['name'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isMobile = screenWidth < 600;
    
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: ColorPalette.primaryColor,
          ),
        ),
      );
    }
    
    // Desktop Layout with permanent sidebar
    if (isDesktop && widget.showDrawer) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey.shade50,
        body: Row(
          children: [
            // Fixed Sidebar for Desktop
            SizedBox(
              width: 280,
              child: AppSidebar(
                userRole: userRole ?? 'inspector',
                userName: userName,
              ),
            ),
            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Custom AppBar
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 24),
                        // Title
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.primaryColor,
                            ),
                          ),
                        ),
                        // Actions
                        if (widget.actions != null) ...widget.actions!,
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  // Body
                  Expanded(
                    child: widget.body,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: widget.floatingActionButton,
      );
    }
    
    // Tablet and Mobile Layout with drawer
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: ColorPalette.primaryColor,
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(
          color: ColorPalette.primaryColor,
        ),
        leading: widget.showDrawer
            ? IconButton(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.menu,
                    color: ColorPalette.primaryColor,
                    size: 28,
                  ),
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                tooltip: 'Menu',
              )
            : widget.automaticallyImplyLeading
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: ColorPalette.primaryColor,
                    ),
                    onPressed: () => Get.back(),
                  )
                : null,
        actions: [
          if (widget.actions != null) ...widget.actions!,
          // Add notification icon for mobile
          if (isMobile)
            IconButton(
              icon: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: ColorPalette.primaryColor,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                // Handle notifications
                Get.snackbar(
                  'Notifications',
                  'No new notifications',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          const SizedBox(width: 8),
        ],
        bottom: widget.bottom,
      ),
      drawer: widget.showDrawer && userRole != null
          ? AppSidebar(
              userRole: userRole!,
              userName: userName,
            )
          : null,
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

// Helper widget for responsive layout
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 1200 && desktop != null) {
      return desktop!;
    } else if (screenWidth >= 600 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}
