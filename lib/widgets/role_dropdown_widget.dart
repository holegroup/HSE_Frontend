import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';

class RoleDropdownWidget extends StatelessWidget {
  final RxString selectedRole;
  final bool showLabel;
  final Function(String)? onRoleChanged;

  const RoleDropdownWidget({
    super.key,
    required this.selectedRole,
    this.showLabel = true,
    this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final roles = [
      {
        'value': 'inspector',
        'label': 'Inspector',
        'icon': Icons.search,
        'description': 'Conduct inspections and submit reports'
      },
      {
        'value': 'supervisor',
        'label': 'Supervisor',
        'icon': Icons.supervisor_account,
        'description': 'Manage tasks and oversee operations'
      },
      {
        'value': 'superadmin',
        'label': 'Super Admin',
        'icon': Icons.admin_panel_settings,
        'description': 'Full system access and user management'
      },
    ];

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
        Obx(() => Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value:
                      selectedRole.value.isNotEmpty ? selectedRole.value : null,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Select role'),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role['value'] as String,
                      child: Row(
                        children: [
                          Icon(
                            role['icon'] as IconData,
                            size: 20,
                            color: ColorPalette.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                role['label'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                role['description'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      selectedRole.value = value;
                      if (onRoleChanged != null) {
                        onRoleChanged!(value);
                      }
                    }
                  },
                ),
              ),
            )),
      ],
    );
  }
}
