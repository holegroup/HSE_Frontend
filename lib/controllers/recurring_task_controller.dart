import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/models/recurring_task_model.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class RecurringTaskController extends GetxController {
  final String baseUrl = Constants.baseUrl;
  final RxBool isloadingDetails = false.obs;

  final RxList<RecurringTask> recurringTasks = <RecurringTask>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Auto-load tasks when controller is initialized
    getRecurringTask();
  }

  Future<void> getRecurringTask() async {
    isloadingDetails.value = true;
    final String url = "$baseUrl/api/tasks/get-all-recurring-task";
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] as List;
        
        recurringTasks.value =
            data.map((task) => RecurringTask.fromJson(task)).toList();
            
        // Show success message only if tasks were found
        if (recurringTasks.isNotEmpty) {
          Get.snackbar(
            "Success", 
            "Loaded ${recurringTasks.length} recurring tasks",
            backgroundColor: Colors.green.shade100,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        Get.snackbar(
          "Error", 
          "Failed to fetch recurring tasks (${response.statusCode})",
          backgroundColor: Colors.red.shade100,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Network Error", 
        "Could not connect to server. Please check your connection.",
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isloadingDetails.value = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    final String url =
        "$baseUrl/api/tasks/change-recurring-status?taskId=$taskId&status=false";

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        recurringTasks.removeWhere((task) => task.id == taskId);
        Get.snackbar("Success", "Task deleted successfully");
      } else {
        Get.snackbar("Error", "Failed to delete task");
      }

      print(response.statusCode);
      print(response.body);
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "Something went wrong");
    }
  }
}
