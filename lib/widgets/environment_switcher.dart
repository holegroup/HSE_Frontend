import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/env.dart';

class EnvironmentSwitcher extends StatefulWidget {
  @override
  _EnvironmentSwitcherState createState() => _EnvironmentSwitcherState();
}

class _EnvironmentSwitcherState extends State<EnvironmentSwitcher> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Environment Configuration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Current Configuration
            _buildInfoRow('Current Environment:', AppConfig.environment.toString()),
            _buildInfoRow('Base URL:', AppConfig.baseUrl),
            _buildInfoRow('Timeout:', '${AppConfig.apiTimeout}ms'),
            
            SizedBox(height: 16),
            
            // Environment Switcher
            Text(
              'Switch Environment:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _switchEnvironment(Environment.development),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.isDevelopment ? Colors.green : Colors.grey,
                    ),
                    child: Text('Local'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _switchEnvironment(Environment.production),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.isProduction ? Colors.green : Colors.grey,
                    ),
                    child: Text('Live'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Test Connection Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testConnection,
                icon: Icon(Icons.network_check),
                label: Text('Test Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
            
            SizedBox(height: 8),
            
            // Quick URLs
            Text(
              'Quick Access:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SizedBox(height: 4),
            _buildUrlRow('Health Check:', '${AppConfig.baseUrl}/api/health'),
            _buildUrlRow('API Info:', '${AppConfig.baseUrl}/api'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUrlRow(String label, String url) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              url,
              style: TextStyle(fontSize: 10, color: Colors.blue),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  void _switchEnvironment(Environment env) {
    setState(() {
      AppConfig.setEnvironment(env);
    });
    
    Get.snackbar(
      'Environment Changed',
      'Switched to ${env.toString().split('.').last}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
  
  void _testConnection() async {
    Get.dialog(
      AlertDialog(
        title: Text('Testing Connection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing ${AppConfig.baseUrl}...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/health'),
      ).timeout(Duration(seconds: 5));
      
      Get.back(); // Close loading dialog
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Connection Success',
          'Server is reachable!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Connection Failed',
          'Server returned status: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Connection Error',
        'Failed to connect: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
