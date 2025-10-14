import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/views/camera_view.dart';
import 'package:http/http.dart' as http;

class SearchWidgetController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final String baseUrl = Constants.baseUrl;
  var filteredSites = <Object>[].obs;

  int previousTextLength = 0;

  // Add variables to store the selected part details
  var selectedPartName = ''.obs;
  var selectedPartNumber = ''.obs;
  RxBool isVisible = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen to changes in the search text field
    searchController.addListener(() {
      search();
    });
  }

  // Load initial products when search widget becomes visible
  Future<void> loadInitialProducts() async {
    final String url = "${baseUrl}/api/products/fetch-all-products";
    
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data['data'] as List;
        
        // Extract all parts from all products
        List<Map<String, dynamic>> allParts = [];
        
        for (var product in products) {
          final equipName = product['equip_name'] ?? 'Unknown Equipment';
          final items = product['items'] as List? ?? [];
          
          for (var item in items) {
            final parts = item['parts'] as List? ?? [];
            
            for (var part in parts) {
              allParts.add({
                'part_name': part['part_name'] ?? 'Unknown Part',
                'part_number': part['part_number'] ?? 'Unknown Number',
                'equipment': equipName,
              });
            }
          }
        }
        
        // If no parts found, show products as selectable items
        if (allParts.isEmpty) {
          for (var product in products) {
            allParts.add({
              'part_name': product['equip_name'] ?? 'Unknown Equipment',
              'part_number': product['actual_equip_id'] ?? 'No ID',
              'equipment': 'Equipment',
            });
          }
        }
        
        // Update filteredSites with all available parts
        filteredSites.value = allParts;
      } else {
        // Don't show error as a product option - just keep list empty
        filteredSites.value = [];
      }
    } catch (e) {
      // Don't show any static data - only real database products
      filteredSites.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Force reload products (for debugging)
  Future<void> forceReloadProducts() async {
    filteredSites.clear();
    await loadInitialProducts();
  }

  Future<void> search() async {
    // If search text is empty, load initial products
    if (searchController.text.trim().isEmpty) {
      await loadInitialProducts();
      return;
    }

    final String url =
        "${baseUrl}/api/products/search-products?query=${searchController.text}";

    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract the list of parts from the data
        final parts = data['data'] as List;

        // Update filteredSites with part_name and part_number
        filteredSites.value = parts.map((part) {
          final partName = part['part_name'] ?? 'Unknown Name';
          final partNumber = part['part_number'] ?? 'Unknown Number';
          return {
            'part_name': partName,
            'part_number': partNumber
          };
        }).toList();
      } else {
        // No matches found - keep list empty
        clearSuggestions();
      }
    } catch (e) {
      // Silent error handling - don't show snackbar for network issues
      clearSuggestions();
    } finally {
      isLoading.value = false;
    }
  }

  selectSite(int index) {
    print(filteredSites[index]);
    // Get selected part details
    final selectedPart = filteredSites[index] as Map<String, dynamic>;
    selectedPartName.value = selectedPart['part_name'] ?? '';
    selectedPartNumber.value = selectedPart['part_number'] ?? '';

    // Update the text in the search controller
    searchController.text = selectedPartName.value;

    isVisible.value = false;

    // Clear suggestions
    clearSuggestions();
  }

  selectSiteAndOpenCamera(int index) {
    print(filteredSites[index]);
    final selectedPart = filteredSites[index] as Map<String, dynamic>;
    Get.to(() => CameraView(
          equipmentName: selectedPart['part_name'] ?? '',
          partNumber: selectedPart['part_number'] ?? '',
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
