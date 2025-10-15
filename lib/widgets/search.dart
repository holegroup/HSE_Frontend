import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hole_hse_inspection/config/color.palate.dart';
import 'package:hole_hse_inspection/controllers/search_controller.dart';

class SearchBox extends StatelessWidget {
  final bool isGoToReport;
  const SearchBox({super.key, this.isGoToReport = false});

  @override
  Widget build(BuildContext context) {
    // Initialize the GetX controller
    // final SearchController searchController = Get.put(SearchController());
    final SearchWidgetController searchBarController =
        Get.put(SearchWidgetController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search box with dropdown and clear option
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: -3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: searchBarController.searchController,
            decoration: InputDecoration(
              prefixIcon: IconButton(
                  onPressed: () {
                    searchBarController.isVisible.value = false;
                  },
                  icon: const Icon(Icons.close)),
              suffixIcon: Obx(() {
                if (searchBarController.isLoading.value == false) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          searchBarController.loadInitialProducts();
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: ColorPalette.primaryColor,
                        ),
                        tooltip: 'Load Products',
                      ),
                      IconButton(
                        onPressed: () {
                          searchBarController.search();
                        },
                        icon: Icon(
                          Icons.search,
                          color: ColorPalette.primaryColor,
                          shadows: [
                            Shadow(
                              color: Colors.blue.shade900.withOpacity(0.9),
                              offset: const Offset(0, 0),
                              blurRadius: 30,
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
              }),
              hintText: "Search...",
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),

        // Loading indicator
        Obx(() {
          if (searchBarController.isLoading.value) {
            return Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: -3,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text("Loading products..."),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // Empty state message
        Obx(() {
          if (!searchBarController.isLoading.value && searchBarController.filteredSites.isEmpty) {
            return Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: -3,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 32, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      "No products found in database",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Please add products first",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    TextButton(
                      onPressed: () {
                        searchBarController.loadInitialProducts();
                      },
                      child: const Text("Refresh"),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // Suggestions list
        Obx(() {
          if (!searchBarController.isLoading.value && searchBarController.filteredSites.isNotEmpty) {
            return Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: searchBarController.filteredSites.length < 4
                      ? searchBarController.filteredSites.length * 75
                      : 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: -3,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: searchBarController.filteredSites.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (isGoToReport) {
                            searchBarController.selectSiteAndOpenCamera(index);
                          } else {
                            searchBarController.selectSite(index);
                          }
                        },
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.all(8),
                          margin: EdgeInsets.only(
                              bottom: index + 1 ==
                                      searchBarController.filteredSites.length
                                  ? 0
                                  : 8),
                          decoration: const BoxDecoration(
                              // color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(5))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      () {
                                        final item = searchBarController.filteredSites[index] as Map<String, dynamic>;
                                        return item['part_name'] ?? '';
                                      }(),
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    () {
                                      final item = searchBarController.filteredSites[index] as Map<String, dynamic>;
                                      return item['part_number'] ?? '';
                                    }(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              if (searchBarController.filteredSites[index] is Map<String, dynamic> && 
                                  (searchBarController.filteredSites[index] as Map<String, dynamic>)['equipment'] != null)
                                Text(
                                  "Equipment: ${(searchBarController.filteredSites[index] as Map<String, dynamic>)['equipment']}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    searchBarController.clearSuggestions();
                    searchBarController.isVisible.value = false;
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 30),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.7),
                          offset: const Offset(0, 6),
                          blurRadius: 14,
                          spreadRadius: -5,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        }),
      ],
    );
  }
}
