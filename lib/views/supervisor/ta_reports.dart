import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';

class TaReports extends StatefulWidget {
  const TaReports({super.key});

  @override
  State<TaReports> createState() => _TaReportsState();
}

class _TaReportsState extends State<TaReports> {
  bool isLoading = false;
  List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Simulate loading reports
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for reports
      reports = [
        {
          'id': '1',
          'title': 'Weekly Safety Report',
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'status': 'Completed',
          'type': 'Safety',
        },
        {
          'id': '2',
          'title': 'Monthly Inspection Report',
          'date': DateTime.now().subtract(const Duration(days: 7)),
          'status': 'Pending',
          'type': 'Inspection',
        },
        {
          'id': '3',
          'title': 'Equipment Maintenance Report',
          'date': DateTime.now().subtract(const Duration(days: 14)),
          'status': 'Completed',
          'type': 'Maintenance',
        },
      ];
    } catch (e) {
      print('Error loading reports: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reports",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorPalette.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Reports',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReports,
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: ColorPalette.primaryColor,
                  ),
                )
              : reports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Reports Found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Reports will appear here when available",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadReports,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Refresh"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(report['status']),
                              child: Icon(
                                _getReportIcon(report['type']),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              report['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Type: ${report['type']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Date: ${_formatDate(report['date'])}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(report['status']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(report['status']),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                report['status'],
                                style: TextStyle(
                                  color: _getStatusColor(report['status']),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            onTap: () {
                              _viewReport(report);
                            },
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewReport,
        backgroundColor: ColorPalette.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Create New Report',
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getReportIcon(String type) {
    switch (type.toLowerCase()) {
      case 'safety':
        return Icons.security;
      case 'inspection':
        return Icons.search;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.description;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _viewReport(Map<String, dynamic> report) {
    Get.snackbar(
      "Report Details",
      "Viewing ${report['title']}",
      backgroundColor: ColorPalette.primaryColor.withOpacity(0.1),
      colorText: ColorPalette.primaryColor,
      duration: const Duration(seconds: 2),
    );
  }

  void _createNewReport() {
    Get.snackbar(
      "Create Report",
      "Report creation feature coming soon",
      backgroundColor: Colors.blue.withOpacity(0.1),
      colorText: Colors.blue,
      duration: const Duration(seconds: 2),
    );
  }
}
