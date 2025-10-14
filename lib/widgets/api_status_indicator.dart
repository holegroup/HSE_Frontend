import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class ApiStatusIndicator extends StatefulWidget {
  final bool showDetails;
  final bool floatingStyle;
  
  const ApiStatusIndicator({
    Key? key, 
    this.showDetails = false,
    this.floatingStyle = false,
  }) : super(key: key);

  @override
  _ApiStatusIndicatorState createState() => _ApiStatusIndicatorState();
}

class _ApiStatusIndicatorState extends State<ApiStatusIndicator> {
  bool isConnected = false;
  bool isChecking = true;
  String activeUrl = '';
  String errorMessage = '';
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    checkConnection();
    // Check connection every 30 seconds
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      checkConnection();
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  Future<void> checkConnection() async {
    if (!mounted) return;
    
    setState(() {
      isChecking = true;
    });
    
    try {
      // Try primary URL
      final primaryUrl = Constants.baseUrl;
      final response = await http.get(
        Uri.parse("$primaryUrl/api/health"),
      ).timeout(Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        setState(() {
          isConnected = true;
          activeUrl = primaryUrl;
          errorMessage = '';
          isChecking = false;
        });
        return;
      }
    } catch (e) {
      // Try fallback URLs
      try {
        final fallbackUrl = Constants.fallbackUrl;
        final response = await http.get(
          Uri.parse("$fallbackUrl/api/health"),
        ).timeout(Duration(seconds: 3));
        
        if (response.statusCode == 200) {
          setState(() {
            isConnected = true;
            activeUrl = fallbackUrl;
            errorMessage = '';
            isChecking = false;
          });
          return;
        }
      } catch (e) {
        setState(() {
          isConnected = false;
          activeUrl = '';
          errorMessage = 'No server available';
          isChecking = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.floatingStyle) {
      return Positioned(
        top: 50,
        right: 16,
        child: _buildFloatingIndicator(),
      );
    }
    
    return _buildInlineIndicator();
  }
  
  Widget _buildFloatingIndicator() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _showConnectionDetails(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isChecking)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(
                  isConnected ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: Colors.white,
                ),
              SizedBox(width: 6),
              Text(
                isConnected ? 'API Connected' : 'API Offline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInlineIndicator() {
    return InkWell(
      onTap: widget.showDetails ? null : () => _showConnectionDetails(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isConnected 
            ? Colors.green.withOpacity(0.1) 
            : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isConnected ? Colors.green : Colors.red,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isChecking)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isConnected ? Colors.green : Colors.red,
                  ),
                ),
              )
            else
              Icon(
                isConnected ? Icons.check_circle : Icons.error,
                size: 18,
                color: isConnected ? Colors.green : Colors.red,
              ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isConnected ? 'API Connected' : 'API Disconnected',
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (widget.showDetails) ...[
                  SizedBox(height: 2),
                  Text(
                    isConnected 
                      ? activeUrl.replaceAll('http://', '').replaceAll('https://', '')
                      : errorMessage,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
            if (!widget.showDetails) ...[
              SizedBox(width: 8),
              Icon(
                Icons.info_outline,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _showConnectionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isConnected ? Icons.check_circle : Icons.error,
              color: isConnected ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8),
            Text('API Connection Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Status:', isConnected ? 'Connected' : 'Disconnected'),
            _buildDetailRow('Active URL:', isConnected ? activeUrl : 'None'),
            _buildDetailRow('Primary URL:', Constants.baseUrl),
            _buildDetailRow('Fallback URL:', Constants.fallbackUrl),
            if (!isConnected)
              _buildDetailRow('Error:', errorMessage),
            SizedBox(height: 16),
            Text(
              'Tips:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (!isConnected) ...[
              Text('• Ensure backend server is running', style: TextStyle(fontSize: 12)),
              Text('• Check network connection', style: TextStyle(fontSize: 12)),
              Text('• Verify firewall settings', style: TextStyle(fontSize: 12)),
            ] else ...[
              Text('• Connection is stable', style: TextStyle(fontSize: 12)),
              Text('• All API endpoints available', style: TextStyle(fontSize: 12)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              checkConnection();
            },
            child: Text('Refresh'),
          ),
          TextButton(
            onPressed: () => Get.toNamed('/api-test'),
            child: Text('Full Test'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: value.contains('Disconnected') || value.contains('None') 
                  ? Colors.red 
                  : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple connection check function for use anywhere
class ApiConnectionHelper {
  static Future<bool> isConnected() async {
    try {
      final response = await http.get(
        Uri.parse("${Constants.baseUrl}/api/health"),
      ).timeout(Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      // Try fallback
      try {
        final response = await http.get(
          Uri.parse("${Constants.fallbackUrl}/api/health"),
        ).timeout(Duration(seconds: 3));
        return response.statusCode == 200;
      } catch (e) {
        return false;
      }
    }
  }
  
  static Future<String?> getActiveUrl() async {
    try {
      final response = await http.get(
        Uri.parse("${Constants.baseUrl}/api/health"),
      ).timeout(Duration(seconds: 3));
      if (response.statusCode == 200) {
        return Constants.baseUrl;
      }
    } catch (e) {
      try {
        final response = await http.get(
          Uri.parse("${Constants.fallbackUrl}/api/health"),
        ).timeout(Duration(seconds: 3));
        if (response.statusCode == 200) {
          return Constants.fallbackUrl;
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  static void showConnectionError(BuildContext context) {
    Get.snackbar(
      'Connection Error',
      'Unable to connect to server. Please check your connection.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () => Get.toNamed('/api-test'),
        child: Text('Test', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
