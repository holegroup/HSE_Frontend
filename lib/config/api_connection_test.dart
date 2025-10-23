import 'package:http/http.dart' as http;
import 'dart:convert';
import 'env.dart';

class ApiConnectionTest {
  static Future<Map<String, dynamic>> checkConnection() async {
    try {
      // Test API health endpoint
      final response = await http
          .get(Uri.parse('${Constants.baseUrl}/api/health'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'connected': true,
          'status': data['status'],
          'message': data['message'],
          'databaseStatus': data['database']?['status'] ?? 'unknown',
          'environment': data['environment']
        };
      } else {
        return {
          'connected': false,
          'error': 'Server returned status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'connected': false, 'error': e.toString()};
    }
  }

  static Future<bool> testRegistrationEndpoint() async {
    try {
      // Test registration endpoint with invalid data to check if it's accessible
      final response = await http
          .post(
            Uri.parse('${Constants.baseUrl}/api/users/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'test': true}),
          )
          .timeout(const Duration(seconds: 10));

      // We expect a 400 status because we sent invalid data
      // This means the endpoint is accessible
      return response.statusCode == 400;
    } catch (e) {
      print('Registration endpoint test failed: $e');
      return false;
    }
  }
}
