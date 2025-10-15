import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'package:hole_hse_inspection/controllers/searchInspector_controller.dart';
import 'package:hole_hse_inspection/controllers/search_controller.dart';
import 'package:hole_hse_inspection/widgets/search.dart';
import 'package:hole_hse_inspection/widgets/searchInspector.dart';
import 'package:http/http.dart' as http;

class CreateTask extends StatefulWidget {
  const CreateTask({super.key});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {

  final LoginController loginController = Get.find<LoginController>();

  final SearchWidgetController searchBarController =
      Get.put(SearchWidgetController());

  final UserSearchWidgetController userSearchBarController =
      Get.put(UserSearchWidgetController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _freqController = TextEditingController();


  final String baseUrl = Constants.baseUrl;
  bool isLoading = false;

  final List<bool> _isCriticalPart = <bool>[true, false];

  Future<void> showToken() async {
    String? token = await loginController.getToken();
    print(token);
  }

  Future<void> submitTask() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation for search fields
    if (userSearchBarController.selectedInspectorEmail.value.isEmpty) {
      Get.snackbar(
        "Validation Error", 
        "Please select an inspector from the search results",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (searchBarController.selectedPartNumber.value.isEmpty) {
      Get.snackbar(
        "Validation Error", 
        "Please select a product from the search results",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    setState(() {
      isLoading = true; 
    });

    final String apiUrl = "$baseUrl/api/tasks/create-task";

    final String inspectorName = userSearchBarController.searchController.text.trim();
    final String inspectorEmail = userSearchBarController.selectedInspectorEmail.value.trim(); 
    final String product = searchBarController.searchController.text.trim();
    final String date = _dateController.text.trim();
    final String note = _noteController.text.trim();

    final String selectedPartNumber = searchBarController.selectedPartNumber.value.trim();

    try {
      String? token = await loginController.getToken();
      
      if (token == null || token.isEmpty) {
        Get.snackbar(
          "Authentication Error", 
          "Please login again to continue",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }

      // Parse maintenance frequency safely
      int? maintenanceFreq;
      bool isRecurring = false;
      
      if (_freqController.text.isNotEmpty) {
        try {
          maintenanceFreq = int.parse(_freqController.text);
          if (maintenanceFreq > 0) {
            isRecurring = true;
          } else {
            maintenanceFreq = null;
          }
        } catch (e) {
          Get.snackbar(
            "Validation Error", 
            "Please enter a valid number for frequency",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
          return;
        }
      }

      final Map<String, dynamic> requestData = {
        'inspector_name': inspectorName,
        'email': inspectorEmail,
        'product': product,
        'part_number': selectedPartNumber,
        'due_date': date,
        'note': note,
        'critical': _isCriticalPart[1],
        'maintenance_freq': maintenanceFreq,
        'recurring': isRecurring,
      };

      print('Sending task data: $requestData');

      // print(apiUrl);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token here
        },
        body: jsonEncode(requestData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        Get.snackbar(
          "Success", 
          "Task created successfully! Task ID: ${responseData['taskId'] ?? 'N/A'}",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () {
              Get.back();
              // Navigate to tasks list or dashboard
            },
            child: Text(
              "View Tasks",
              style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
            ),
          ),
        );

        // Clear form after successful submission
        _clearForm();
      } else {
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage = errorData['message'] ?? 'Failed to create task';
          
          // Show detailed error information for debugging
          if (errorData['missingFields'] != null) {
            errorMessage += '\nMissing: ${errorData['missingFields'].join(', ')}';
          }
          
          if (errorData['availableUsers'] != null) {
            errorMessage += '\nAvailable users: ${errorData['availableUsers'].length}';
          }
          
          Get.snackbar(
            "Task Creation Failed", 
            errorMessage,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
            duration: const Duration(seconds: 6),
            mainButton: TextButton(
              onPressed: () {
                Get.back();
                _showDebugInfo(errorData);
              },
              child: Text(
                "Debug Info",
                style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold),
              ),
            ),
          );
        } catch (e) {
          Get.snackbar(
            "Error", 
            "Server error: ${response.statusCode}",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (error) {
      print('Submit task error: $error');
      Get.snackbar(
        "Network Error", 
        "Failed to connect to server. Please check your connection and try again.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 4),
      );
    } finally {
      setState(() {
        isLoading = false; 
      });
    }
  }

  void _clearForm() {
    _dateController.clear();
    _noteController.clear();
    _freqController.clear();
    userSearchBarController.searchController.clear();
    userSearchBarController.selectedInspectorEmail.value = '';
    searchBarController.searchController.clear();
    searchBarController.selectedPartNumber.value = '';
    searchBarController.selectedPartName.value = '';
    
    // Reset toggle buttons to default
    setState(() {
      _isCriticalPart[0] = true;
      _isCriticalPart[1] = false;
    });
  }

  void _showDebugInfo(Map<String, dynamic> errorData) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.orange),
            SizedBox(width: 8),
            Text('Debug Information'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Error Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorData.toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Current Form Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Inspector: ${userSearchBarController.searchController.text}'),
              Text('Email: ${userSearchBarController.selectedInspectorEmail.value}'),
              Text('Product: ${searchBarController.searchController.text}'),
              Text('Part Number: ${searchBarController.selectedPartNumber.value}'),
              Text('Date: ${_dateController.text}'),
              Text('Note: ${_noteController.text}'),
              Text('Critical: ${_isCriticalPart[1]}'),
              Text('Frequency: ${_freqController.text}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Copy debug info to clipboard or share
            },
            child: const Text('Copy Info'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    onTap: () {
                      userSearchBarController.isVisible.value = true;
                    },
                    controller: userSearchBarController.searchController,
                    decoration: InputDecoration(
                      labelText: 'Inspector Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    return Text(
                        "Inspector email: ${userSearchBarController.selectedInspectorEmail.value}");
                  }),
                  const SizedBox(height: 16),
                  TextFormField(
                    onTap: () async {
                      searchBarController.isVisible.value = true;
                      // Load products from database when field is tapped
                      await searchBarController.loadInitialProducts();
                    },
                    controller: searchBarController.searchController,
                    decoration: InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Tap to select a product',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    return Text(
                        "Part Number: ${searchBarController.selectedPartNumber.value}");
                  }),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          DateTime selectedDate =
                              DateTime.now(); // Default to current date
                          return SizedBox(
                            height: 250,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                Expanded(
                                  child: CupertinoDatePicker(
                                    initialDateTime: DateTime.now(),
                                    mode: CupertinoDatePickerMode.date,
                                    onDateTimeChanged: (DateTime date) {
                                      selectedDate = date;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _dateController.text =
                                              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Done'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date';
                      } else {
                        // Parse the selected date from the text field
                        DateTime selectedDate = DateTime.parse(value);
                        DateTime today = DateTime.now();
                        if (selectedDate.isBefore(
                            DateTime(today.year, today.month, today.day))) {
                          return 'Date cannot be before today';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Note',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ToggleButtons(
                    direction: Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        // The button that is tapped is set to true, and the others to false.
                        for (int i = 0; i < _isCriticalPart.length; i++) {
                          _isCriticalPart[i] = i == index;
                        }
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    selectedBorderColor: _isCriticalPart[0] == false
                        ? Colors.red[700]
                        : Colors.green[700],
                    selectedColor: Colors.white,
                    fillColor: _isCriticalPart[0] == false
                        ? Colors.red[200]
                        : Colors.green[200],
                    color: _isCriticalPart[0] == false
                        ? Colors.red[400]
                        : Colors.green[400],
                    constraints: const BoxConstraints(
                      minHeight: 40.0,
                      minWidth: 80.0,
                    ),
                    isSelected: _isCriticalPart,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Text("Normal Part"),
                            SizedBox(width: 8),
                            Icon(
                              size: 18,
                              Icons.settings,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Text("Critical Part"),
                            SizedBox(width: 8),
                            Icon(
                              size: 18,
                              Icons.warning_rounded,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        "Select\nFrequency",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(),
                          controller: _freqController,
                          decoration: InputDecoration(
                            labelText: 'Frequency in Days',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            suffixIcon: const Icon(Icons.data_exploration_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              submitTask();
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('Submit'),
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.8),
                ],
              ),
            ),
          ),
          Obx(() {
            if (searchBarController.isVisible.value == false) {
              return const SizedBox();
            } else {
              return Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SearchBox(),
                  ),
                ),
              );
            }
          }),
          Obx(() {
            if (userSearchBarController.isVisible.value == false) {
              return const SizedBox();
            } else {
              return Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: UserSearchBox(),
                  ),
                ),
              );
            }
          }),
        ]),
      ),
    );
  }
}
