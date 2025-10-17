import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/profile_controller.dart';
import 'package:hive/hive.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Profile Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: ColorPalette.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(controller),
            const SizedBox(height: 24),
            
            // Personal Information
            _buildPersonalInfoSection(controller),
            const SizedBox(height: 20),
            
            // Security Settings
            _buildSecuritySection(controller),
            const SizedBox(height: 20),
            
            // Preferences
            _buildPreferencesSection(controller),
            const SizedBox(height: 20),
            
            // Account Actions
            _buildAccountActionsSection(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileController controller) {
    var userBox = Hive.box('userBox');
    var userData = userBox.get('userData');
    String userName = userData?['user']?['name'] ?? 'Super Admin';
    String userEmail = userData?['user']?['email'] ?? 'admin@hse.com';
    String userRole = userData?['user']?['role'] ?? 'superadmin';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorPalette.primaryColor, ColorPalette.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.primaryColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => controller.changeProfilePicture(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: ColorPalette.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              userRole.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(ProfileController controller) {
    return _buildSection(
      'Personal Information',
      Icons.person,
      [
        _buildEditableTile(
          'Full Name',
          controller.name.value,
          Icons.person_outline,
          () => _showEditDialog('Full Name', controller.name.value, (value) {
            controller.name.value = value;
            controller.updateProfile();
          }),
        ),
        _buildEditableTile(
          'Email Address',
          controller.email.value,
          Icons.email_outlined,
          () => _showEditDialog('Email Address', controller.email.value, (value) {
            controller.email.value = value;
            controller.updateProfile();
          }),
        ),
        _buildEditableTile(
          'Phone Number',
          controller.phone.value.isEmpty ? 'Not set' : controller.phone.value,
          Icons.phone_outlined,
          () => _showEditDialog('Phone Number', controller.phone.value, (value) {
            controller.phone.value = value;
            controller.updateProfile();
          }),
        ),
      ],
    );
  }

  Widget _buildSecuritySection(ProfileController controller) {
    return _buildSection(
      'Security Settings',
      Icons.security,
      [
        _buildActionTile(
          'Change Password',
          'Update your account password',
          Icons.lock_outline,
          () => _showChangePasswordDialog(controller),
        ),
        _buildSwitchTile(
          'Two-Factor Authentication',
          'Add an extra layer of security',
          Icons.verified_user,
          controller.twoFactorEnabled,
          (value) => controller.toggleTwoFactor(value),
        ),
        _buildActionTile(
          'Login Sessions',
          'Manage active login sessions',
          Icons.devices,
          () => _showLoginSessionsDialog(),
        ),
        _buildActionTile(
          'Security Log',
          'View recent security activities',
          Icons.history,
          () => _showSecurityLogDialog(),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(ProfileController controller) {
    return _buildSection(
      'Preferences',
      Icons.settings,
      [
        _buildSwitchTile(
          'Email Notifications',
          'Receive email notifications',
          Icons.notifications_outlined,
          controller.emailNotifications,
          (value) => controller.toggleEmailNotifications(value),
        ),
        _buildSwitchTile(
          'Push Notifications',
          'Receive push notifications',
          Icons.push_pin_outlined,
          controller.pushNotifications,
          (value) => controller.togglePushNotifications(value),
        ),
        _buildActionTile(
          'Language',
          'English (US)',
          Icons.language,
          () => _showLanguageDialog(),
        ),
        _buildActionTile(
          'Time Zone',
          'UTC+05:30 (India Standard Time)',
          Icons.access_time,
          () => _showTimeZoneDialog(),
        ),
      ],
    );
  }

  Widget _buildAccountActionsSection(ProfileController controller) {
    return _buildSection(
      'Account Actions',
      Icons.admin_panel_settings,
      [
        _buildActionTile(
          'Export Data',
          'Download your account data',
          Icons.download,
          () => controller.exportAccountData(),
        ),
        _buildActionTile(
          'Activity Log',
          'View your account activity',
          Icons.timeline,
          () => _showActivityLogDialog(),
        ),
        _buildActionTile(
          'Privacy Settings',
          'Manage your privacy preferences',
          Icons.privacy_tip,
          () => _showPrivacySettingsDialog(),
        ),
        _buildDangerTile(
          'Delete Account',
          'Permanently delete your account',
          Icons.delete_forever,
          () => _showDeleteAccountDialog(),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorPalette.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: ColorPalette.primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEditableTile(String title, String value, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.edit, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, RxBool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
      trailing: Obx(() => Switch(
        value: value.value,
        onChanged: onChanged,
        activeColor: ColorPalette.primaryColor,
      )),
    );
  }

  Widget _buildDangerTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.red.shade600),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.red.shade600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.red.shade400,
          fontSize: 14,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.red.shade600),
      onTap: onTap,
    );
  }

  void _showEditDialog(String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    Get.dialog(
      AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(ProfileController controller) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.changePassword(
                currentPasswordController.text,
                newPasswordController.text,
                confirmPasswordController.text,
              );
              Get.back();
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from your account?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              var userBox = Hive.box('userBox');
              userBox.clear();
              Get.offAllNamed('/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showLoginSessionsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Active Sessions'),
        content: const Text('Login sessions management will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSecurityLogDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Security Log'),
        content: const Text('Security activity log will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Language'),
        content: const Text('Language selection will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTimeZoneDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Time Zone'),
        content: const Text('Time zone selection will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showActivityLogDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Activity Log'),
        content: const Text('Account activity log will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text('Privacy settings will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to permanently delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Account Deletion',
                'Account deletion request has been submitted',
                backgroundColor: Colors.orange.shade100,
                colorText: Colors.orange.shade900,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
