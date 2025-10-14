import 'dart:convert';
// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/models/table_data_model.dart';
import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class TableDataController extends GetxController {
  String baseUrl = Constants.baseUrl;
  final RxBool isloadingDetails = false.obs;
  final RxList<Task> tasks = <Task>[].obs;

  Future<void> getData({String? startDate, String? endDate}) async {
    isloadingDetails.value = true;

    String url = '$baseUrl/api/tasks/get-all-tasks';
    if (startDate != null && endDate != null) {
      url += '?startDate=$startDate&endDate=$endDate';
    } else if (startDate != null) {
      url += '?startDate=$startDate';
    } else if (endDate != null) {
      url += '?endDate=$endDate';
    }

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] as List;
        tasks.value = data.map((task) => Task.fromJson(task)).toList();
        
        // Show success message with count
        String dateRange = '';
        if (startDate != null && endDate != null) {
          dateRange = ' for $startDate to $endDate';
        } else if (startDate != null) {
          dateRange = ' from $startDate';
        } else if (endDate != null) {
          dateRange = ' until $endDate';
        }
        
        if (tasks.isNotEmpty) {
          Get.snackbar(
            "Data Loaded", 
            "Found ${tasks.length} tasks$dateRange",
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: Duration(seconds: 2),
          );
        }
      } else if (response.statusCode == 404) {
        tasks.value = [];
        Get.snackbar(
          "No Data", 
          "No tasks found for the selected criteria",
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.blue.shade800,
        );
      } else {
        tasks.value = [];
        Get.snackbar(
          "Error", 
          "Failed to fetch data (${response.statusCode})",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    } catch (e) {
      tasks.value = [];
      Get.snackbar(
        "Network Error", 
        "Could not connect to server. Please check your connection.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isloadingDetails.value = false;
    }
  }

  // Future<bool> _requestPermision(Permission permission) async {
  //   AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
  //   if (build.version.sdkInt >= 30) {
  //     var re = await Permission.manageExternalStorage.request();
  //     if (re.isGranted) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } else {
  //     if (await permission.isGranted) {
  //       return true;
  //     } else {
  //       var result = await permission.request();
  //       if (result.isGranted) {
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     }
  //   }
  // }

  // Future<void> downloadCsv({String? startDate, String? endDate}) async {
  //   // isloadingDetails.value = true;
  //   print('Downloading CSV...');

  //   String url = '$baseUrl/api/tasks/download-csv';
  //   if (startDate != null && endDate != null) {
  //     url += '?startDate=$startDate&endDate=$endDate';
  //   }

  //   try {
  //     // Check if storage permission is granted, and if not, request it
  //     _requestPermision(Permission.storage);
  //     var status = await Permission.storage.request();
  //     if (status.isGranted) {
  //       final response = await http.get(Uri.parse(url));
  //       print(response.statusCode);

  //       if (response.statusCode == 200) {
  //         final bytes = response.bodyBytes;

  //         // Prompt user to select a directory using the file picker
  //         String? directoryPath = await FilePicker.platform.getDirectoryPath();

  //         // If no directory is selected, exit early
  //         if (directoryPath == null) {
  //           Get.snackbar("Error", "No directory selected");
  //           return;
  //         }

  //         final filePath = '$directoryPath/tasks.csv';
  //         final file = File(filePath);

  //         // Write the bytes to the selected directory
  //         await file.writeAsBytes(bytes);

  //         print('File saved to: $filePath');
  //         Get.snackbar("Success", "CSV downloaded successfully!");
  //       } else {
  //         Get.snackbar("Error", "Failed to download CSV");
  //       }
  //     } else {
  //       // If permission is denied, request it and check again
  //       // Get.snackbar(
  //       //     "Permission Denied", "Please allow storage access permission");
  //       print(status);
  //       Permission.storage.request();
  //       // Optionally, show a dialog or message to explain why you need the permission
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     Get.snackbar("Error", "Something went wrong while downloading the CSV");
  //   } finally {
  //     // isloadingDetails.value = false;
  //   }
  // }

  Future<void> downloadCsv({String? startDate, String? endDate}) async {
    try {
      String url = '$baseUrl/api/tasks/download-csv';
      if (startDate != null && endDate != null) {
        url += '?startDate=$startDate&endDate=$endDate';
      } else if (startDate != null) {
        url += '?startDate=$startDate';
      } else if (endDate != null) {
        url += '?endDate=$endDate';
      }
      
      Get.snackbar(
        "Downloading CSV", 
        "Preparing your CSV file...",
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        duration: Duration(seconds: 2),
      );
      
      Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        Get.snackbar(
          "CSV Download", 
          "CSV file download started. Check your downloads folder.",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          duration: Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Download Failed', 
          'Unable to open download link. Please try again.',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Download Error', 
        'Failed to download CSV: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
}
