import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_config.dart';

class DevToolsButton extends StatelessWidget {
  const DevToolsButton({Key? key}) : super(key: key);

  void _showEnvironmentPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Environment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEnvironmentTile(
                context,
                Environment.development,
                'Development (Local)',
                'Uses local development server',
              ),
              const Divider(),
              _buildEnvironmentTile(
                context,
                Environment.production,
                'Production (Live)',
                'Uses live production server',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnvironmentTile(
    BuildContext context,
    Environment env,
    String title,
    String subtitle,
  ) {
    final isSelected = AppConfig.environment == env;

    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Text(
              'URL: ${AppConfig.baseUrl}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ],
        ],
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      selected: isSelected,
      onTap: () {
        AppConfig.setEnvironment(env);
        Navigator.pop(context);

        // Show confirmation snackbar
        Get.snackbar(
          'Environment Changed',
          'Switched to ${title.split(' ')[0]} environment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!AppConfig.enableDebugMode) return const SizedBox.shrink();

    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.settings),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppConfig.isProduction ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                AppConfig.isProduction ? 'P' : 'D',
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      onPressed: () => _showEnvironmentPicker(context),
      tooltip: 'Switch Environment',
    );
  }
}
