import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';

class FooterMenu extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const FooterMenu({Key? key, this.selectedIndex = 0, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Show a horizontal footer for desktop/tablet, bottom navigation for mobile
    if (width >= 900) {
      // Desktop
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildItem(Icons.dashboard, 'Dashboard', 0),
                const SizedBox(width: 12),
                _buildItem(Icons.people, 'Users', 1),
                const SizedBox(width: 12),
                _buildItem(Icons.assignment, 'Tasks', 2),
                const SizedBox(width: 12),
                _buildItem(Icons.assessment, 'Reports', 3),
              ],
            ),
            Text('© ${DateTime.now().year} Hole HSE',
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    } else if (width >= 600) {
      // Tablet
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildItem(Icons.dashboard, 'Dashboard', 0),
            _buildItem(Icons.people, 'Users', 1),
            _buildItem(Icons.assignment, 'Tasks', 2),
            _buildItem(Icons.assessment, 'Reports', 3),
          ],
        ),
      );
    }

    // Mobile: use BottomNavigationBar
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (i) {
        if (onTap != null) onTap!(i);
        switch (i) {
          case 0:
            Get.offAllNamed('/home');
            break;
          case 1:
            Get.toNamed('/manage-users');
            break;
          case 2:
            Get.toNamed('/all-tasks');
            break;
          case 3:
            Get.toNamed('/reports');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Reports'),
      ],
    );
  }

  Widget _buildItem(IconData icon, String label, int idx) {
    return InkWell(
      onTap: () {
        if (onTap != null) onTap!(idx);
        switch (idx) {
          case 0:
            Get.offAllNamed('/home');
            break;
          case 1:
            Get.toNamed('/manage-users');
            break;
          case 2:
            Get.toNamed('/all-tasks');
            break;
          case 3:
            Get.toNamed('/reports');
            break;
        }
      },
      child: Row(
        children: [
          Icon(icon, color: ColorPalette.primaryColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.grey.shade800)),
        ],
      ),
    );
  }
}
