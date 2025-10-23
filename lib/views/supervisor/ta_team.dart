import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';

class TaTeam extends StatefulWidget {
  const TaTeam({super.key});

  @override
  State<TaTeam> createState() => _TaTeamState();
}

class _TaTeamState extends State<TaTeam> {
  bool isLoading = false;
  List<Map<String, dynamic>> teamMembers = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Simulate loading team members
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for team members
      teamMembers = [
        {
          'id': '1',
          'name': 'John Smith',
          'role': 'Inspector',
          'email': 'john.smith@company.com',
          'phone': '+1 234 567 8901',
          'status': 'Active',
          'joinDate': DateTime(2023, 1, 15),
          'tasksCompleted': 45,
          'avatar': null,
        },
        {
          'id': '2',
          'name': 'Sarah Johnson',
          'role': 'Safety Officer',
          'email': 'sarah.johnson@company.com',
          'phone': '+1 234 567 8902',
          'status': 'Active',
          'joinDate': DateTime(2023, 3, 20),
          'tasksCompleted': 32,
          'avatar': null,
        },
        {
          'id': '3',
          'name': 'Mike Wilson',
          'role': 'Inspector',
          'email': 'mike.wilson@company.com',
          'phone': '+1 234 567 8903',
          'status': 'On Leave',
          'joinDate': DateTime(2022, 11, 10),
          'tasksCompleted': 67,
          'avatar': null,
        },
        {
          'id': '4',
          'name': 'Emily Davis',
          'role': 'Quality Controller',
          'email': 'emily.davis@company.com',
          'phone': '+1 234 567 8904',
          'status': 'Active',
          'joinDate': DateTime(2023, 5, 8),
          'tasksCompleted': 28,
          'avatar': null,
        },
        {
          'id': '5',
          'name': 'Robert Brown',
          'role': 'Inspector',
          'email': 'robert.brown@company.com',
          'phone': '+1 234 567 8905',
          'status': 'Inactive',
          'joinDate': DateTime(2022, 8, 3),
          'tasksCompleted': 89,
          'avatar': null,
        },
      ];
    } catch (e) {
      print('Error loading team members: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredTeamMembers {
    if (searchQuery.isEmpty) {
      return teamMembers;
    }
    return teamMembers.where((member) {
      return member['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
             member['role'].toLowerCase().contains(searchQuery.toLowerCase()) ||
             member['email'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Team Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorPalette.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadTeamMembers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Team',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTeamMembers,
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search team members...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            // Team Stats
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Members',
                      teamMembers.length.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Active',
                      teamMembers.where((m) => m['status'] == 'Active').length.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'On Leave',
                      teamMembers.where((m) => m['status'] == 'On Leave').length.toString(),
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            // Team Members List
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: ColorPalette.primaryColor,
                      ),
                    )
                  : filteredTeamMembers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isNotEmpty 
                                    ? "No team members found"
                                    : "No Team Members",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                searchQuery.isNotEmpty
                                    ? "Try adjusting your search terms"
                                    : "Add team members to get started",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: searchQuery.isNotEmpty 
                                    ? () {
                                        setState(() {
                                          searchQuery = '';
                                        });
                                      }
                                    : _loadTeamMembers,
                                icon: Icon(searchQuery.isNotEmpty ? Icons.clear : Icons.refresh),
                                label: Text(searchQuery.isNotEmpty ? "Clear Search" : "Refresh"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorPalette.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTeamMembers.length,
                          itemBuilder: (context, index) {
                            final member = filteredTeamMembers[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(member['status']),
                                  child: Text(
                                    member['name'].split(' ').map((n) => n[0]).take(2).join(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  member['name'],
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
                                      member['role'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      member['email'],
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(member['status']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(member['status']),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    member['status'],
                                    style: TextStyle(
                                      color: _getStatusColor(member['status']),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildDetailRow('Phone', member['phone']),
                                        _buildDetailRow('Join Date', _formatDate(member['joinDate'])),
                                        _buildDetailRow('Tasks Completed', member['tasksCompleted'].toString()),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () => _contactMember(member),
                                              icon: const Icon(Icons.phone, size: 16),
                                              label: const Text('Contact'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                            ElevatedButton.icon(
                                              onPressed: () => _viewMemberProfile(member),
                                              icon: const Icon(Icons.person, size: 16),
                                              label: const Text('Profile'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: ColorPalette.primaryColor,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                            ElevatedButton.icon(
                                              onPressed: () => _assignTask(member),
                                              icon: const Icon(Icons.assignment, size: 16),
                                              label: const Text('Assign'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTeamMember,
        backgroundColor: ColorPalette.primaryColor,
        child: const Icon(Icons.person_add, color: Colors.white),
        tooltip: 'Add Team Member',
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'on leave':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _contactMember(Map<String, dynamic> member) {
    Get.snackbar(
      "Contact Member",
      "Calling ${member['name']} at ${member['phone']}",
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
      duration: const Duration(seconds: 2),
    );
  }

  void _viewMemberProfile(Map<String, dynamic> member) {
    Get.snackbar(
      "Member Profile",
      "Viewing profile for ${member['name']}",
      backgroundColor: ColorPalette.primaryColor.withOpacity(0.1),
      colorText: ColorPalette.primaryColor,
      duration: const Duration(seconds: 2),
    );
  }

  void _assignTask(Map<String, dynamic> member) {
    Get.snackbar(
      "Assign Task",
      "Assigning task to ${member['name']}",
      backgroundColor: Colors.blue.withOpacity(0.1),
      colorText: Colors.blue,
      duration: const Duration(seconds: 2),
    );
  }

  void _addTeamMember() {
    Get.snackbar(
      "Add Team Member",
      "Team member addition feature coming soon",
      backgroundColor: Colors.blue.withOpacity(0.1),
      colorText: Colors.blue,
      duration: const Duration(seconds: 2),
    );
  }
}
