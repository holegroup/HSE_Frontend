import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/controllers/new_listing_controller.dart';

class NewListing extends StatefulWidget {
  const NewListing({super.key});

  @override
  State<NewListing> createState() => _NewListingState();
}

class _NewListingState extends State<NewListing> {
  final NewListingController newListingController =
      Get.put(NewListingController());
  List<dynamic> items = []; // To store API data for items
  List<dynamic> parts = []; // To store API data for parts
  bool isLoading = true; // Track loading state
  bool hasError = false; // Track error state

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    
    try {
      final fetchedItems = await newListingController.getItems(); // Fetch items
      final fetchedParts = await newListingController.getParts(); // Fetch parts
      setState(() {
        items = fetchedItems ?? []; // Update the items list
        parts = fetchedParts ?? []; // Update the parts list
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Listings"),
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading new listings..."),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "Failed to load listings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Please check your connection and try again"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchData,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty && parts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "No New Listings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "There are no pending items or parts to review",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Display items
            if (items.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
                child: Text(
                  "Pending Items (${items.length})",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              ...items.map((item) => buildItemCard(item)),
            ],
            // Display parts
            if (parts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8, top: 16),
                child: Text(
                  "Pending Parts (${parts.length})",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
              ...parts.map((part) => buildPartCard(part)),
            ],
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
        Obx(() {
          if (newListingController.isLoadingGlobal.value) {
            return Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.3,
                  height: MediaQuery.sizeOf(context).width * 0.3,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircularProgressIndicator(),
                        Text("Processing..."),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        }),
      ],
    );
  }

  // Widget to display each item
  Widget buildItemCard(dynamic item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Site Name: ${item['siteId']['site_name']}",
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Equipment Name: ${item['productId']['equip_name']}",
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Serial Number: ${item['serial_number']}",
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Added By: ${item['added_by']['name']}",
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Status: ${item['status']}",
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await newListingController.itemStatus(
                          itemId: item['_id'], status: 'Rejected');
                      fetchData(); // Refresh data after action
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text("Reject"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await newListingController.itemStatus(
                          itemId: item['_id'], status: 'Approved');
                      fetchData(); // Refresh data after action
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Accept"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display each part
  Widget buildPartCard(dynamic part) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Equipment Name: ${part['productId']['equip_name']}",
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Item Name: ${part['itemId']['item_name']}",
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Part Name: ${part['part_name']}",
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Part Number: ${part['part_number']}",
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Added By: ${part['added_by']['name']}",
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Status: ${part['status']}",
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      print("Rejected: ${part['_id']}");
                      await newListingController.partStatus(
                          partId: part['_id'], status: 'Rejected');
                      fetchData(); // Refresh data after action
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text("Reject"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      print("Accepted: ${part['_id']}");
                      await newListingController.partStatus(
                          partId: part['_id'], status: 'Approved');
                      fetchData(); // Refresh data after action
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Accept"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
