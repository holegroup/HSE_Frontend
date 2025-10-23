import 'package:flutter/material.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';

class DashboardSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchContent();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchContent();
  }

  Widget _buildSearchContent() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Start typing to search'),
      );
    }

    // Mock search results - replace with actual search logic
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSearchCategory('Users', [
          {'title': 'John Doe', 'subtitle': 'Inspector', 'icon': Icons.person},
          {
            'title': 'Jane Smith',
            'subtitle': 'Supervisor',
            'icon': Icons.supervisor_account
          },
        ]),
        const Divider(),
        _buildSearchCategory('Tasks', [
          {
            'title': 'Monthly Inspection',
            'subtitle': 'Due in 2 days',
            'icon': Icons.assignment
          },
          {
            'title': 'Safety Audit',
            'subtitle': 'Completed',
            'icon': Icons.task_alt
          },
        ]),
        const Divider(),
        _buildSearchCategory('Reports', [
          {
            'title': 'Q3 Safety Report',
            'subtitle': 'Generated on Oct 15',
            'icon': Icons.description
          },
          {
            'title': 'Equipment Audit',
            'subtitle': 'Last week',
            'icon': Icons.build
          },
        ]),
      ],
    );
  }

  Widget _buildSearchCategory(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: ColorPalette.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...items.map((item) => ListTile(
              leading: Icon(item['icon'] as IconData,
                  color: ColorPalette.primaryColor),
              title: Text(item['title'] as String),
              subtitle: Text(item['subtitle'] as String),
              onTap: () {
                // Handle item tap
              },
            )),
      ],
    );
  }
}
