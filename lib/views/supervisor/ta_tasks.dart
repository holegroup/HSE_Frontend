import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/task_controller.dart';

class TaTasks extends StatefulWidget {
  const TaTasks({super.key});

  @override
  State<TaTasks> createState() => _TaTasksState();
}

class _TaTasksState extends State<TaTasks> with TickerProviderStateMixin {
  final TaskController taskController = Get.put(TaskController());
  late TabController _tabController;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    taskController.getTask();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<dynamic> get filteredTasks {
    if (selectedFilter == 'All') {
      return taskController.tasks;
    }
    return taskController.tasks
        .where((task) => task['status'].toString().toLowerCase() == selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tasks Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorPalette.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Tasks')),
              const PopupMenuItem(value: 'Pending', child: Text('Pending')),
              const PopupMenuItem(value: 'In Progress', child: Text('In Progress')),
              const PopupMenuItem(value: 'Completed', child: Text('Completed')),
            ],
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Tasks',
          ),
          IconButton(
            onPressed: () => taskController.getTask(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Tasks',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Pending', icon: Icon(Icons.pending)),
            Tab(text: 'Active', icon: Icon(Icons.play_arrow)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await taskController.getTask();
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTaskList('All'),
            _buildTaskList('Pending'),
            _buildTaskList('In Progress'),
            _buildTaskList('Completed'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTask,
        backgroundColor: ColorPalette.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Create New Task',
      ),
    );
  }

  Widget _buildTaskList(String status) {
    return Obx(() {
      if (taskController.getTaskIsLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: ColorPalette.primaryColor,
          ),
        );
      }

      List<dynamic> tasks;
      if (status == 'All') {
        tasks = taskController.tasks;
      } else {
        tasks = taskController.tasks
            .where((task) => task['status'].toString().toLowerCase() == status.toLowerCase())
            .toList();
      }

      if (tasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getStatusIcon(status),
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                "No ${status == 'All' ? '' : status} Tasks Found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                status == 'All'
                    ? "Create tasks to get started"
                    : "No tasks with ${status.toLowerCase()} status",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => taskController.getTask(),
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
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
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: _getTaskStatusColor(task['status']),
                child: Icon(
                  _getTaskStatusIcon(task['status']),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                task['product'] ?? 'Unknown Product',
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
                    'Status: ${task['status']}',
                    style: TextStyle(
                      color: _getTaskStatusColor(task['status']),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (task['due_date'] != null)
                    Text(
                      'Due: ${_formatDate(DateTime.parse(task['due_date']))}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTaskStatusColor(task['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getTaskStatusColor(task['status']),
                    width: 1,
                  ),
                ),
                child: Text(
                  task['status'],
                  style: TextStyle(
                    color: _getTaskStatusColor(task['status']),
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
                      if (task['note'] != null && task['note'].isNotEmpty)
                        _buildDetailRow('Note', task['note']),
                      if (task['part_number'] != null)
                        _buildDetailRow('Part Number', task['part_number']),
                      if (task['inspector_name'] != null)
                        _buildDetailRow('Inspector', task['inspector_name']),
                      if (task['site_name'] != null)
                        _buildDetailRow('Site', task['site_name']),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _editTask(task),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _viewTaskDetails(task),
                            icon: const Icon(Icons.visibility, size: 16),
                            label: const Text('View'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _deleteTask(task),
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
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
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'all':
        return Icons.list;
      case 'pending':
        return Icons.pending;
      case 'in progress':
        return Icons.play_arrow;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.task;
    }
  }

  Color _getTaskStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTaskStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'in progress':
        return Icons.play_arrow;
      default:
        return Icons.task;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _createNewTask() {
    Get.snackbar(
      "Create Task",
      "Task creation feature coming soon",
      backgroundColor: Colors.blue.withOpacity(0.1),
      colorText: Colors.blue,
      duration: const Duration(seconds: 2),
    );
  }

  void _editTask(Map<String, dynamic> task) {
    Get.snackbar(
      "Edit Task",
      "Editing ${task['product']}",
      backgroundColor: Colors.blue.withOpacity(0.1),
      colorText: Colors.blue,
      duration: const Duration(seconds: 2),
    );
  }

  void _viewTaskDetails(Map<String, dynamic> task) {
    Get.snackbar(
      "Task Details",
      "Viewing details for ${task['product']}",
      backgroundColor: ColorPalette.primaryColor.withOpacity(0.1),
      colorText: ColorPalette.primaryColor,
      duration: const Duration(seconds: 2),
    );
  }

  void _deleteTask(Map<String, dynamic> task) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task['product']}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                "Task Deleted",
                "${task['product']} has been deleted",
                backgroundColor: Colors.red.withOpacity(0.1),
                colorText: Colors.red,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
