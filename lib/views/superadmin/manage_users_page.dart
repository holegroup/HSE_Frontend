import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/manage_users_controller.dart';

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ManageUsersController controller = Get.put(ManageUsersController());
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Manage Users',
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
            onPressed: () => controller.refreshUsers(),
          ),
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () => Get.toNamed('/create-user'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshUsers(),
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: controller.searchController,
                    onChanged: (value) => controller.filterUsers(),
                    decoration: InputDecoration(
                      hintText: 'Search users by name or email...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorPalette.primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Role Filter
                  Obx(() => Row(
                    children: [
                      const Text('Filter by role: '),
                      const SizedBox(width: 8),
                      _buildFilterChip('All', 'all', controller),
                      const SizedBox(width: 8),
                      _buildFilterChip('Super Admin', 'superadmin', controller),
                      const SizedBox(width: 8),
                      _buildFilterChip('Supervisor', 'supervisor', controller),
                      const SizedBox(width: 8),
                      _buildFilterChip('Inspector', 'inspector', controller),
                    ],
                  )),
                ],
              ),
            ),
            
            // Users List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (controller.filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchController.text.isEmpty
                              ? 'No users found'
                              : 'No users match your search',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.searchController.text.isEmpty
                              ? 'Create your first user to get started'
                              : 'Try adjusting your search criteria',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Get.toNamed('/create-user'),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Create User'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPalette.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.filteredUsers[index];
                    return _buildUserCard(user, controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, ManageUsersController controller) {
    final isSelected = controller.selectedRoleFilter.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        controller.selectedRoleFilter.value = value;
        controller.filterUsers();
      },
      selectedColor: ColorPalette.primaryColor.withOpacity(0.2),
      checkmarkColor: ColorPalette.primaryColor,
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, ManageUsersController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user['role']).withOpacity(0.1),
          child: Icon(
            _getRoleIcon(user['role']),
            color: _getRoleColor(user['role']),
          ),
        ),
        title: Text(
          user['name'] ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user['email'] ?? '',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user['role']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user['role']?.toString().toUpperCase() ?? 'UNKNOWN',
                    style: TextStyle(
                      color: _getRoleColor(user['role']),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Created: ${_formatDate(user['createdAt'])}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditUserDialog(user, controller);
                break;
              case 'delete':
                _showDeleteConfirmation(user, controller);
                break;
              case 'reset_password':
                _showResetPasswordDialog(user, controller);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, size: 20),
                title: Text('Edit User'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'reset_password',
              child: ListTile(
                leading: Icon(Icons.lock_reset, size: 20),
                title: Text('Reset Password'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (user['role'] != 'superadmin') // Don't allow deleting superadmins
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red, size: 20),
                  title: Text('Delete User', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'superadmin':
        return Colors.purple;
      case 'supervisor':
        return Colors.orange;
      case 'inspector':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String? role) {
    switch (role) {
      case 'superadmin':
        return Icons.admin_panel_settings;
      case 'supervisor':
        return Icons.supervisor_account;
      case 'inspector':
        return Icons.search;
      default:
        return Icons.person;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showEditUserDialog(Map<String, dynamic> user, ManageUsersController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Edit User'),
        content: const Text('User editing functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> user, ManageUsersController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteUser(user['_id']);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(Map<String, dynamic> user, ManageUsersController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Reset password for ${user['name']}? A new temporary password will be generated.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.resetUserPassword(user['_id']);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
