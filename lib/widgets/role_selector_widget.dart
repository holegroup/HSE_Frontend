import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';

class RoleSelectorWidget extends StatelessWidget {
  final RxString selectedRole;
  final bool showLabel;
  final Function(String)? onRoleChanged;

  const RoleSelectorWidget({
    super.key,
    required this.selectedRole,
    this.showLabel = true,
    this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            'Select Your Role',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Obx(() => Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildRoleCard(
                    'inspector',
                    'Inspector',
                    Icons.search,
                    'Conduct inspections and submit reports',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRoleCard(
                    'supervisor',
                    'Supervisor',
                    Icons.supervisor_account,
                    'Manage tasks and oversee operations',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRoleCard(
              'superadmin',
              'Super Admin',
              Icons.admin_panel_settings,
              'Full system access and user management',
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildRoleCard(String value, String label, IconData icon, String description) {
    final isSelected = selectedRole.value == value;
    
    return GestureDetector(
      onTap: () {
        selectedRole.value = value;
        if (onRoleChanged != null) {
          onRoleChanged!(value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
            ? ColorPalette.primaryColor.withOpacity(0.1)
            : Colors.white,
          border: Border.all(
            color: isSelected 
              ? ColorPalette.primaryColor 
              : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: ColorPalette.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected 
                ? ColorPalette.primaryColor 
                : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected 
                  ? ColorPalette.primaryColor 
                  : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ColorPalette.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Selected',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Alternative compact role selector for forms
class CompactRoleSelector extends StatelessWidget {
  final RxString selectedRole;
  final Function(String)? onRoleChanged;

  const CompactRoleSelector({
    super.key,
    required this.selectedRole,
    this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildOption('inspector', 'Inspector', Icons.search),
              ),
              Expanded(
                child: _buildOption('supervisor', 'Supervisor', Icons.supervisor_account),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildOption('superadmin', 'Super Admin', Icons.admin_panel_settings),
        ],
      ),
    ));
  }

  Widget _buildOption(String value, String label, IconData icon) {
    final isSelected = selectedRole.value == value;
    
    return GestureDetector(
      onTap: () {
        selectedRole.value = value;
        if (onRoleChanged != null) {
          onRoleChanged!(value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected 
                ? ColorPalette.primaryColor 
                : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                  ? ColorPalette.primaryColor 
                  : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
