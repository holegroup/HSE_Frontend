import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SiteController extends GetxController {
  final String baseUrl = Constants.baseUrl;

  var sites = [].obs;
  final RxBool isloadingSite = false.obs;

  var selectedSiteData = {}.obs;
  final RxBool isLoadingSiteDetail = false.obs;
  final RxBool isLoadingGlobal = false.obs;
  final RxMap<String, bool> loadingStates = <String, bool>{}.obs;

  final LoginController loginController = Get.put(LoginController());
  var token;

  @override
  void onInit() {
    super.onInit();
    fetchToken();
  }

  void fetchToken() async {
    token = await loginController.getToken();
    print('User token: $token');
  }

  Future<void> fetchAllSites() async {
    isloadingSite.value = true;
    final String url = "$baseUrl/api/sites/fetch-all-sites";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
        if (responseData['data'] != null) {
          sites.value = responseData['data'];
        } else {
          print("No data field in the response.");
        }
      } else {
        print("Failed to fetch sites. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred while fetching sites: $e");
    } finally {
      isloadingSite.value = false;
    }
  }

  Future<void> fetchSiteById(String siteId) async {
    loadingStates[siteId] = true;
    final String url = "$baseUrl/api/sites/fetch-products/$siteId";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          selectedSiteData.value = responseData;
          // print(responseData);
        } else {
          print("No data field in the response for site ID: $siteId");
        }
      } else {
        print("Failed to fetch site data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred while fetching site data: $e");
    } finally {
      loadingStates[siteId] = false;
    }
  }

  Future<void> addNewSite() async {
    // Create controllers for form fields
    TextEditingController siteNameController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController cityController = TextEditingController();
    TextEditingController stateController = TextEditingController();
    TextEditingController countryController = TextEditingController();
    TextEditingController zipCodeController = TextEditingController();
    
    // Observable for loading state
    RxBool isLoading = false.obs;
    RxString message = "".obs;

    Get.bottomSheet(
        enableDrag: true,
        BottomSheet(
          onClosing: () {},
          builder: (BuildContext context) {
            return Obx(() => SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text("Add a New Site", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    TextField(
                      controller: siteNameController,
                      decoration: InputDecoration(
                        labelText: 'Site Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: stateController,
                      decoration: InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: countryController,
                      decoration: InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: zipCodeController,
                      decoration: InputDecoration(
                        labelText: 'Zip-code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (message.value.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: message.value.contains('Success') ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message.value,
                          style: TextStyle(
                            color: message.value.contains('Success') ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading.value ? null : () {
                              Get.back();
                            },
                            child: Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading.value ? null : () async {
                              // Validate inputs
                              String siteName = siteNameController.text.trim();
                              String address = addressController.text.trim();
                              String city = cityController.text.trim();
                              String state = stateController.text.trim();
                              String country = countryController.text.trim();
                              String zipCode = zipCodeController.text.trim();

                              if (siteName.isEmpty || address.isEmpty || city.isEmpty || 
                                  state.isEmpty || country.isEmpty || zipCode.isEmpty) {
                                message.value = 'All fields are required';
                                return;
                              }

                              try {
                                isLoading.value = true;
                                message.value = '';
                                
                                // Prepare request body
                                Map<String, dynamic> requestBody = {
                                  'site_name': siteName,
                                  'location': {
                                    'address': address,
                                    'city': city,
                                    'state': state,
                                    'country': country,
                                    'zip_code': zipCode,
                                  },
                                  'products_stored': [],
                                };

                                // Make HTTP POST request
                                final response = await http.post(
                                  Uri.parse('${baseUrl}/api/sites/create-site'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode(requestBody),
                                );

                                final responseData = jsonDecode(response.body);

                                if (response.statusCode == 200) {
                                  message.value = 'Success: Site created successfully!';
                                  // Clear form fields
                                  siteNameController.clear();
                                  addressController.clear();
                                  cityController.clear();
                                  stateController.clear();
                                  countryController.clear();
                                  zipCodeController.clear();
                                  
                                  // Refresh sites list
                                  await fetchAllSites();
                                  
                                  // Close bottom sheet after a delay
                                  Future.delayed(Duration(seconds: 2), () {
                                    Get.back();
                                  });
                                } else {
                                  message.value = 'Error: ${responseData['message'] ?? 'Failed to create site'}';
                                }
                              } catch (e) {
                                message.value = 'Error: ${e.toString()}';
                              } finally {
                                isLoading.value = false;
                              }
                            },
                            child: isLoading.value
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Create Site'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ));
          },
        ));
  }

  Future<void> addNewProduct() async {
    // Create controllers for form fields
    TextEditingController equipNameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController actualEquipIdController = TextEditingController();
    
    // Observable for loading state
    RxBool isLoading = false.obs;
    RxString message = "".obs;

    Get.bottomSheet(
        enableDrag: true,
        BottomSheet(
          onClosing: () {},
          builder: (BuildContext context) {
            return Obx(() => SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text("Add a New Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    TextField(
                      controller: equipNameController,
                      decoration: InputDecoration(
                        labelText: 'Equipment Name',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Excavator, Crane, etc.',
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Brief description of the equipment',
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: actualEquipIdController,
                      decoration: InputDecoration(
                        labelText: 'Equipment ID',
                        border: OutlineInputBorder(),
                        hintText: 'Unique equipment identifier',
                      ),
                    ),
                    SizedBox(height: 16),
                    if (message.value.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: message.value.contains('Success') ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message.value,
                          style: TextStyle(
                            color: message.value.contains('Success') ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading.value ? null : () {
                              Get.back();
                            },
                            child: Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading.value ? null : () async {
                              // Validate inputs
                              String equipName = equipNameController.text.trim();
                              String description = descriptionController.text.trim();
                              String actualEquipId = actualEquipIdController.text.trim();

                              if (equipName.isEmpty || actualEquipId.isEmpty) {
                                message.value = 'Equipment Name and Equipment ID are required';
                                return;
                              }

                              try {
                                isLoading.value = true;
                                message.value = '';
                                
                                // Prepare request body
                                Map<String, dynamic> requestBody = {
                                  'equip_name': equipName,
                                  'description': description,
                                  'actual_equip_id': actualEquipId,
                                };

                                // Make HTTP POST request
                                final response = await http.post(
                                  Uri.parse('${baseUrl}/api/products/create-product'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode(requestBody),
                                );

                                final responseData = jsonDecode(response.body);

                                if (response.statusCode == 201) {
                                  message.value = 'Success: Product created successfully!';
                                  // Clear form fields
                                  equipNameController.clear();
                                  descriptionController.clear();
                                  actualEquipIdController.clear();
                                  
                                  // Close bottom sheet after a delay
                                  Future.delayed(Duration(seconds: 2), () {
                                    Get.back();
                                  });
                                } else {
                                  message.value = 'Error: ${responseData['message'] ?? 'Failed to create product'}';
                                }
                              } catch (e) {
                                message.value = 'Error: ${e.toString()}';
                              } finally {
                                isLoading.value = false;
                              }
                            },
                            child: isLoading.value
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Create Product'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ));
          },
        ));
  }

  Future<void> addNewPart({
    required String productId,
    required String itemId,
  }) async {
    TextEditingController partNameController = TextEditingController();
    TextEditingController partNumberController = TextEditingController();
    Get.bottomSheet(
        enableDrag: true,
        BottomSheet(
          onClosing: () {},
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text("Send Request to add Part"),
                  SizedBox(height: 16),
                  TextField(
                    controller: partNameController,
                    decoration: InputDecoration(labelText: 'Part Name'),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  TextField(
                    controller: partNumberController,
                    decoration: InputDecoration(labelText: 'Part Number'),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle button 1 press
                            Get.back();
                          },
                          child: Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate inputs
                            String partName = partNameController.text.trim();
                            String partNumber =
                                partNumberController.text.trim();

                            if (partName.isEmpty || partNumber.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Part Name and Part Number cannot be empty',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            try {
                              isLoadingGlobal.value = true;
                              print(isLoadingGlobal.value);
                              // HTTP PUT request
                              final response = await http.post(
                                Uri.parse(
                                    '${baseUrl}/api/sites/add-parts-items'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer ${token}',
                                },
                                body: jsonEncode({
                                  'productId': productId,
                                  'itemId': itemId,
                                  'part_name': partName,
                                  'part_number': partNumber,
                                }),
                              );

                              if (response.statusCode == 200) {
                                // Success
                                Get.snackbar(
                                  'Success',
                                  'Part added successfully',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } else {
                                // Handle error
                                Get.snackbar(
                                  'Error',
                                  'Failed to add part. Status code: ${response.statusCode}',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            } catch (e) {
                              // Handle exception
                              Get.snackbar(
                                'Error',
                                'An error occurred: $e',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } finally {
                              // Close the bottom sheet
                              Get.back();
                              print("API task ended");
                              isLoadingGlobal.value = false;
                              print(isLoadingGlobal.value);
                            }
                          },
                          child: Text('Done'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        ));
  }

  Future<void> addNewItem({
    required String SiteId,
    required String productId,
  }) async {
    TextEditingController itemNameController = TextEditingController();
    TextEditingController serialNumberController = TextEditingController();

    // Add observable for loading state
    RxBool isLoading = false.obs;
    RxString message = "".obs;

    Get.bottomSheet(
      enableDrag: true,
      BottomSheet(
        onClosing: () {},
        builder: (BuildContext context) {
          return Obx(() => Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text("Send Request to add Item"),
                    SizedBox(height: 16),
                    TextField(
                      controller: itemNameController,
                      decoration: InputDecoration(labelText: 'Item Name'),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: serialNumberController,
                      decoration: InputDecoration(labelText: 'Serial Number'),
                    ),
                    SizedBox(height: 16),
                    Text(message.value),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading.value
                                ? null
                                : () async {
                                    String itemName =
                                        itemNameController.text.trim();
                                    String serialNumber =
                                        serialNumberController.text.trim();

                                    if (itemName.isEmpty ||
                                        serialNumber.isEmpty) {
                                      Get.snackbar(
                                        'Error',
                                        'Part Name and Part Number cannot be empty',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                      return;
                                    }

                                    isLoading.value = true;

                                    try {
                                      print("API started");
                                      final response = await http.post(
                                        Uri.parse(
                                            '${baseUrl}/api/sites/add-items-site'),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Authorization': 'Bearer ${token}',
                                        },
                                        body: jsonEncode({
                                          'siteId': SiteId,
                                          'serial_number': serialNumber,
                                          'name': itemName,
                                          'productId': productId,
                                        }),
                                      );
                                      final data = jsonDecode(response.body);

                                      message.value = data['message'];
                                    } catch (e) {
                                      message.value = e.toString();
                                    } finally {
                                      isLoading.value = false;
                                      print("API task ended");
                                      itemNameController.clear();
                                      serialNumberController.clear();
                                    }
                                  },
                            child: isLoading.value
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Done'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ));
        },
      ),
    );
  }
}
