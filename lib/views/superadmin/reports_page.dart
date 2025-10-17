import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/reports_controller.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportsController controller = Get.put(ReportsController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'System Reports',
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.refreshReports(),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => controller.exportAllReports(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshReports(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Selector
              _buildDateRangeSelector(controller),
              const SizedBox(height: 20),
              
              // Quick Stats Cards
              _buildQuickStatsSection(controller),
              const SizedBox(height: 20),
              
              // User Analytics
              _buildUserAnalyticsSection(controller),
              const SizedBox(height: 20),
              
              // Inspection Reports
              _buildInspectionReportsSection(controller),
              const SizedBox(height: 20),
              
              // System Activity
              _buildSystemActivitySection(controller),
              const SizedBox(height: 20),
              
              // Performance Metrics
              _buildPerformanceMetricsSection(controller),
              const SizedBox(height: 20),
              
              // Export Options
              _buildExportOptionsSection(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(ReportsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  'From: ${controller.fromDate.value}',
                  Icons.calendar_today,
                  () => controller.selectFromDate(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  'To: ${controller.toDate.value}',
                  Icons.calendar_today,
                  () => controller.selectToDate(),
                ),
              ),
            ],
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQuickDateButton('Today', () => controller.setToday()),
              const SizedBox(width: 8),
              _buildQuickDateButton('This Week', () => controller.setThisWeek()),
              const SizedBox(width: 8),
              _buildQuickDateButton('This Month', () => controller.setThisMonth()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ColorPalette.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: ColorPalette.primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection(ReportsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Inspections',
              controller.totalInspections.value.toString(),
              Icons.assignment,
              Colors.blue,
              '+12% from last period',
            ),
            _buildStatCard(
              'Active Users',
              controller.activeUsers.value.toString(),
              Icons.people,
              Colors.green,
              '+5% from last period',
            ),
            _buildStatCard(
              'Completed Tasks',
              controller.completedTasks.value.toString(),
              Icons.task_alt,
              Colors.orange,
              '+8% from last period',
            ),
            _buildStatCard(
              'System Uptime',
              '${controller.systemUptime.value}%',
              Icons.trending_up,
              Colors.purple,
              'Excellent performance',
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAnalyticsSection(ReportsController controller) {
    return _buildReportSection(
      'User Analytics',
      Icons.analytics,
      [
        _buildReportTile(
          'New User Registrations',
          '24 this month',
          Icons.person_add,
          () => controller.viewUserRegistrations(),
        ),
        _buildReportTile(
          'User Activity Report',
          'Login patterns & usage',
          Icons.timeline,
          () => controller.viewUserActivity(),
        ),
        _buildReportTile(
          'Role Distribution',
          'Users by role breakdown',
          Icons.pie_chart,
          () => controller.viewRoleDistribution(),
        ),
      ],
    );
  }

  Widget _buildInspectionReportsSection(ReportsController controller) {
    return _buildReportSection(
      'Inspection Reports',
      Icons.assignment,
      [
        _buildReportTile(
          'Inspection Summary',
          'Overview of all inspections',
          Icons.summarize,
          () => controller.viewInspectionSummary(),
        ),
        _buildReportTile(
          'Compliance Report',
          'Safety compliance metrics',
          Icons.verified,
          () => controller.viewComplianceReport(),
        ),
        _buildReportTile(
          'Issue Tracking',
          'Open & resolved issues',
          Icons.bug_report,
          () => controller.viewIssueTracking(),
        ),
      ],
    );
  }

  Widget _buildSystemActivitySection(ReportsController controller) {
    return _buildReportSection(
      'System Activity',
      Icons.computer,
      [
        _buildReportTile(
          'API Usage Statistics',
          'Endpoint usage & performance',
          Icons.api,
          () => controller.viewApiUsage(),
        ),
        _buildReportTile(
          'Error Logs',
          'System errors & warnings',
          Icons.error,
          () => controller.viewErrorLogs(),
        ),
        _buildReportTile(
          'Database Performance',
          'Query performance metrics',
          Icons.storage,
          () => controller.viewDatabasePerformance(),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetricsSection(ReportsController controller) {
    return _buildReportSection(
      'Performance Metrics',
      Icons.speed,
      [
        _buildReportTile(
          'Response Times',
          'Average API response times',
          Icons.timer,
          () => controller.viewResponseTimes(),
        ),
        _buildReportTile(
          'Resource Usage',
          'CPU, Memory, Storage usage',
          Icons.memory,
          () => controller.viewResourceUsage(),
        ),
        _buildReportTile(
          'Load Balancing',
          'Server load distribution',
          Icons.balance,
          () => controller.viewLoadBalancing(),
        ),
      ],
    );
  }

  Widget _buildReportSection(String title, IconData icon, List<Widget> children) {
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

  Widget _buildReportTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
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

  Widget _buildExportOptionsSection(ReportsController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorPalette.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.download, color: ColorPalette.primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Export Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  'Export PDF',
                  Icons.picture_as_pdf,
                  Colors.red,
                  () => controller.exportToPDF(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildExportButton(
                  'Export Excel',
                  Icons.table_chart,
                  Colors.green,
                  () => controller.exportToExcel(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  'Export CSV',
                  Icons.text_snippet,
                  Colors.blue,
                  () => controller.exportToCSV(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildExportButton(
                  'Email Report',
                  Icons.email,
                  Colors.orange,
                  () => controller.emailReport(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
