import 'package:flutter/material.dart';
import 'package:hole_hse_inspection/config/api_test.dart';
import 'package:hole_hse_inspection/config/env.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  _ApiTestPageState createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final ApiConnectionTest tester = ApiConnectionTest();
  Map<String, dynamic> testResults = {};
  bool isLoading = false;
  String activeUrl = '';
  
  @override
  void initState() {
    super.initState();
    checkConnection();
  }
  
  Future<void> checkConnection() async {
    setState(() {
      isLoading = true;
    });
    
    // Check which URL is active
    String? url = await tester.getActiveUrl();
    
    setState(() {
      activeUrl = url ?? 'No server reachable';
      isLoading = false;
    });
  }
  
  Future<void> runFullTest() async {
    setState(() {
      isLoading = true;
      testResults = {};
    });
    
    final results = await tester.testAllEndpoints();
    
    setState(() {
      testResults = results;
      isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Server Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.dns, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Server Configuration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Primary URL:', Constants.baseUrl),
                    _buildInfoRow('Fallback URL:', Constants.fallbackUrl),
                    _buildInfoRow('Secondary:', Constants.secondaryFallbackUrl),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Text(
                          'Active Server: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            activeUrl,
                            style: TextStyle(
                              color: activeUrl.contains('No server') 
                                ? Colors.red 
                                : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!activeUrl.contains('No server'))
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Controls
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : checkConnection,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : runFullTest,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run Full Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick Test Button
            ElevatedButton.icon(
              onPressed: isLoading ? null : () => ApiConnectionTest.showTestResults(context),
              icon: const Icon(Icons.bug_report),
              label: const Text('Quick Test (Dialog)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
            
            // Loading Indicator
            if (isLoading)
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Testing endpoints...'),
                    ],
                  ),
                ),
              ),
            
            // Test Results
            if (testResults.isNotEmpty && !isLoading) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            testResults['success'] == true 
                              ? Icons.check_circle 
                              : Icons.error,
                            color: testResults['success'] == true 
                              ? Colors.green 
                              : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Test Results',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Summary
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (testResults['successRate'] ?? 0) > 80 
                            ? Colors.green.shade50 
                            : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Summary: ${testResults['summary'] ?? 'N/A'}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (testResults['successRate'] ?? 0) / 100,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                (testResults['successRate'] ?? 0) > 80 
                                  ? Colors.green 
                                  : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Success Rate: ${testResults['successRate']?.toStringAsFixed(1) ?? '0'}%',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      
                      // Endpoint Results
                      if (testResults['results'] != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Endpoint Details:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: testResults['results'].length,
                            itemBuilder: (context, index) {
                              String key = testResults['results'].keys.elementAt(index);
                              bool success = testResults['results'][key];
                              return ListTile(
                                leading: Icon(
                                  success ? Icons.check : Icons.close,
                                  color: success ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                                title: Text(
                                  key,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                dense: true,
                              );
                            },
                          ),
                        ),
                      ],
                      
                      // Errors
                      if (testResults['errors'] != null && 
                          testResults['errors'].isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Failed Endpoints:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...testResults['errors'].entries.map((e) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: Colors.red)),
                                Expanded(
                                  child: Text(
                                    '${e.key}: ${e.value}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            
            // Instructions Card
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstruction('1. Ensure backend server is running'),
                    _buildInstruction('2. Check if using correct URL for your platform'),
                    _buildInstruction('3. For Android emulator: use 10.0.2.2 instead of localhost'),
                    _buildInstruction('4. For physical device: use your PC\'s IP address'),
                    _buildInstruction('5. Ensure firewall allows port 5000'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
