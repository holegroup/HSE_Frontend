import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/views/camera_view.dart';
import 'package:http/http.dart' as http;

class UserSearchWidgetController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final String baseUrl = Constants.baseUrl;

  RxBool isVisible = false.obs;
  var filteredSites = <Object>[].obs;

  int previousTextLength = 0;
  final RxString selectedInspectorEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      search();
    });
  }

  Future<void> search() async {
    final String url =
        "$baseUrl/api/users/search-users?query=${searchController.text}";

    print(
        "search api called----------------------------------------------------------------");

    try {
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract the list of parts from the data
        final users = data['data'] as List;

        // Update filteredSites with user name and email
        filteredSites.value = users.map((user) {
          final name = user['name'] ?? 'Unknown Name';
          final email = user['email'] ?? 'Unknown email';
          return {
            'name': name,
            'email': email
          };
        }).toList();
      } else {
        clearSuggestions();
        filteredSites.add({
          'name': 'No Match',
          'email': ''
        });
      }
    } catch (e) {
      Get.snackbar("An error occurred", "$e");
    } finally {
      isLoading.value = false;
      print(filteredSites);
    }
  }

  selectSite(int index) {
    print(filteredSites[index]);
    // Update the text in the search controller
    final selectedUser = filteredSites[index] as Map<String, dynamic>;
    searchController.text = selectedUser['name'] ?? '';

    selectedInspectorEmail.value = selectedUser['email'] ?? '';
    // Clear suggestions
    clearSuggestions();

    isVisible.value = false;
  }

  selectSiteAndOpenCamera(int index) {
    print(filteredSites[index]);
    final selectedUser = filteredSites[index] as Map<String, dynamic>;
    Get.to(() => CameraView(
          equipmentName: selectedUser['name'] ?? '',
          partNumber: selectedUser['email'] ?? '',
        ));
  }

  clearSuggestions() {
    filteredSites.value = [];
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
