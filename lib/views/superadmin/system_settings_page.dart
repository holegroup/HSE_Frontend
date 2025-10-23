import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/config/app_config.dart';
import 'package:hole_hse_inspection/controllers/system_settings_controller.dart';

class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SystemSettingsController controller =
        Get.put(SystemSettingsController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'System Settings',
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
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () => controller.saveSettings(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Configuration
            _buildSectionCard(
              'System Configuration',
              Icons.settings,
              [
                _buildSettingTile(
                  'Application Name',
                  'HSE Inspection System',
                  Icons.app_registration,
                  onTap: () => _showEditDialog(
                      'Application Name', 'HSE Inspection System'),
                ),
                _buildSettingTile(
                  'System Version',
                  'v1.0.0',
                  Icons.info,
                  onTap: () => _showEditDialog('System Version', 'v1.0.0'),
                ),
                _buildSettingTile(
                  'Maintenance Mode',
                  'Disabled',
                  Icons.build,
                  trailing: Obx(() => Switch(
                        value: controller.maintenanceMode.value,
                        onChanged: (value) =>
                            controller.toggleMaintenanceMode(value),
                        activeColor: ColorPalette.primaryColor,
                      )),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // User Management Settings
            _buildSectionCard(
              'User Management',
              Icons.people,
              [
                _buildSettingTile(
                  'Default User Role',
                  'Inspector',
                  Icons.person,
                  onTap: () => _showRoleSelectionDialog(controller),
                ),
                _buildSettingTile(
                  'Password Policy',
                  'Minimum 6 characters',
                  Icons.lock,
                  onTap: () => _showPasswordPolicyDialog(controller),
                ),
                _buildSettingTile(
                  'Auto-approve Users',
                  'Enabled',
                  Icons.approval,
                  trailing: Obx(() => Switch(
                        value: controller.autoApproveUsers.value,
                        onChanged: (value) =>
                            controller.toggleAutoApproveUsers(value),
                        activeColor: ColorPalette.primaryColor,
                      )),
                ),
                _buildSettingTile(
                  'Session Timeout',
                  '24 hours',
                  Icons.timer,
                  onTap: () => _showSessionTimeoutDialog(controller),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Security Settings
            _buildSectionCard(
              'Security',
              Icons.security,
              [
                _buildSettingTile(
                  'Two-Factor Authentication',
                  'Optional',
                  Icons.verified_user,
                  trailing: Obx(() => Switch(
                        value: controller.twoFactorAuth.value,
                        onChanged: (value) =>
                            controller.toggleTwoFactorAuth(value),
                        activeColor: ColorPalette.primaryColor,
                      )),
                ),
                _buildSettingTile(
                  'Login Attempts Limit',
                  '5 attempts',
                  Icons.block,
                  onTap: () => _showLoginAttemptsDialog(controller),
                ),
                _buildSettingTile(
                  'API Rate Limiting',
                  'Enabled',
                  Icons.speed,
                  trailing: Obx(() => Switch(
                        value: controller.apiRateLimit.value,
                        onChanged: (value) =>
                            controller.toggleApiRateLimit(value),
                        activeColor: ColorPalette.primaryColor,
                      )),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notification Settings
            _buildSectionCard(
              'Notifications',
              Icons.notifications,
              [
                _buildSettingTile(
                  'Email Notifications',
                  'Enabled',
                  Icons.email,
                  trailing: Obx(() => Switch(
                        value: controller.emailNotifications.value,
                        onChanged: (value) =>
                            controller.toggleEmailNotifications(value),
                        activeColor: ColorPalette.primaryColor,
                      )),
                ),
                _buildSettingTile(
                  'Push Notifications',
                  'Enabled',
                  Icons.push_pin,
                  trailing: Obx(() => Switch(
                        value: controller.pushNotifications.value,
                        onChanged: (value) =>
                            controller.togglePushNotifications(value),
                        activeColor: ColorPalette.primaryColor,
                      )),
                ),
                _buildSettingTile(
                  'SMS Notifications',
                  'Disabled',
                  Icons.sms,
                  trailing: Obx(() => Switch(
                        value: controller.smsNotifications.value,
                        onChanged: (value) =>
                            controller.toggleSmsNotifications(value),
                        activeColor: ColorPalette.primaryColor,
                      )),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Database Settings
            _buildSectionCard(
              'Database',
              Icons.storage,
              [
                _buildSettingTile(
                  'Database Status',
                  'Connected',
                  Icons.check_circle,
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ONLINE',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _buildSettingTile(
                  'Backup Schedule',
                  'Daily at 2:00 AM',
                  Icons.backup,
                  onTap: () => _showBackupScheduleDialog(controller),
                ),
                _buildSettingTile(
                  'Data Retention',
                  '1 year',
                  Icons.delete_sweep,
                  onTap: () => _showDataRetentionDialog(controller),
                ),
                _buildSettingTile(
                  'Manual Backup',
                  'Create backup now',
                  Icons.save_alt,
                  onTap: () => controller.createManualBackup(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // System Actions
            _buildSectionCard(
              'System Actions',
              Icons.admin_panel_settings,
              [
                _buildSettingTile(
                  'Clear Cache',
                  'Clear system cache',
                  Icons.clear_all,
                  onTap: () => controller.clearSystemCache(),
                ),
                _buildSettingTile(
                  'Reset Statistics',
                  'Reset all statistics',
                  Icons.refresh,
                  onTap: () => _showResetConfirmation('statistics', controller),
                ),
                _buildSettingTile(
                  'Export Data',
                  'Export system data',
                  Icons.download,
                  onTap: () => controller.exportSystemData(),
                ),
                _buildSettingTile(
                  'System Logs',
                  'View system logs',
                  Icons.list_alt,
                  onTap: () => Get.toNamed('/system-logs'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Environment Settings
            _buildSectionCard(
              'Environment Settings',
              Icons.cloud,
              [
                _buildSettingTile(
                  'Current Environment',
                  'Currently using: ${AppConfig.environment.toString().split('.').last.toUpperCase()}',
                  Icons.public,
                  onTap: () => _showEnvironmentDialog(),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (AppConfig.environment == Environment.production
                              ? Colors.green
                              : Colors.orange)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppConfig.environment == Environment.production
                          ? 'LIVE'
                          : 'LOCAL',
                      style: TextStyle(
                        color: AppConfig.environment == Environment.production
                            ? Colors.green
                            : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _buildSettingTile(
                  'Base URL',
                  AppConfig.baseUrl,
                  Icons.link,
                ),
                _buildSettingTile(
                  'Debug Mode',
                  AppConfig.enableDebugMode ? 'Enabled' : 'Disabled',
                  Icons.bug_report,
                  trailing: Switch(
                    value: AppConfig.enableDebugMode,
                    onChanged: (value) => Get.snackbar(
                      'Debug Mode',
                      'Change debug mode in config/app_config.dart',
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    ),
                    activeColor: ColorPalette.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.saveSettings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save All Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
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

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
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
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  void _showEditDialog(String title, String currentValue) {
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
              // Save logic here
              Get.back();
              Get.snackbar('Updated', '$title has been updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRoleSelectionDialog(SystemSettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Default User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Inspector'),
              value: 'inspector',
              groupValue: controller.defaultUserRole.value,
              onChanged: (value) => controller.defaultUserRole.value = value!,
            ),
            RadioListTile<String>(
              title: const Text('Supervisor'),
              value: 'supervisor',
              groupValue: controller.defaultUserRole.value,
              onChanged: (value) => controller.defaultUserRole.value = value!,
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
              Get.back();
              Get.snackbar('Updated', 'Default user role has been updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPasswordPolicyDialog(SystemSettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Password Policy'),
        content: const Text(
            'Password policy configuration will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSessionTimeoutDialog(SystemSettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Session Timeout'),
        content: const Text(
            'Session timeout configuration will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLoginAttemptsDialog(SystemSettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Login Attempts Limit'),
        content: const Text(
            'Login attempts limit configuration will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBackupScheduleDialog(SystemSettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Backup Schedule'),
        content: const Text(
            'Backup schedule configuration will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataRetentionDialog(SystemSettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Data Retention'),
        content: const Text(
            'Data retention configuration will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(
      String type, SystemSettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('Reset ${type.capitalize}'),
        content: Text(
            'Are you sure you want to reset all $type? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.resetStatistics();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showEnvironmentDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Environment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEnvironmentOption(
              Environment.development,
              'Local Development',
              'Uses local development server',
              'http://localhost:5000 or http://10.0.2.2:5000',
            ),
            const Divider(),
            _buildEnvironmentOption(
              Environment.staging,
              'Staging',
              'Uses staging server',
              'Not configured',
              enabled: false,
            ),
            const Divider(),
            _buildEnvironmentOption(
              Environment.production,
              'Production',
              'Uses live production server',
              'https://hsebackend.myhsebuddy.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentOption(
    Environment env,
    String title,
    String subtitle,
    String url, {
    bool enabled = true,
  }) {
    final bool isSelected = AppConfig.environment == env;

    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 4),
          Text(
            url,
            style: TextStyle(
              fontSize: 12,
              color: enabled ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      selected: isSelected,
      enabled: enabled,
      onTap: enabled
          ? () {
              AppConfig.setEnvironment(env);
              Get.back();

              Get.snackbar(
                'Environment Changed',
                'Switched to ${title.split(' ')[0]} environment',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
            }
          : null,
    );
  }
}
