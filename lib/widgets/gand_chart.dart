import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hole_hse_inspection/config/env.dart';
import 'package:hole_hse_inspection/controllers/login_controller.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

class TaskPieChart extends StatefulWidget {
  const TaskPieChart({super.key});

  @override
  _TaskPieChartState createState() => _TaskPieChartState();
}

class _TaskPieChartState extends State<TaskPieChart> {
  Map<String, double> dataMap = {};
  bool isLoading = false;
  final List<Color> colorList = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
  ];

  DateTime? startDate;
  DateTime? endDate;

  bool isVisible = false;

  Future<void> fetchChartData({String? startDate, String? endDate}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final LoginController loginController = Get.put(LoginController());
      String? token = await loginController.getToken();

      var userData = await loginController.getUserData();
      
      // Better null checking
      if (userData == null || userData['id'] == null) {
        print("User data is null or missing ID, setting default data");
        setState(() {
          dataMap = {
            "Pending": 0.0,
            "Due Soon": 0.0,
            "Overdue": 0.0,
            "Completed": 0.0
          };
          isLoading = false;
        });
        return;
      }

      String baseUrl = Constants.baseUrl;

      // Build URL with proper query parameters
      String url = '$baseUrl/api/tasks/get-task-status-supervisor?supervisorId=${userData['id']}';
      
      if (startDate != null) {
        url += '&startDate=$startDate';
      }
      if (endDate != null) {
        url += '&endDate=$endDate';
      }

      print('Fetching chart data from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final Map<String, dynamic>? data = responseData['data'];

        if (data == null || data.isEmpty) {
          // Handle null or empty data - show default empty state
          setState(() {
            dataMap = {
              "Pending": 0.0,
              "Due Soon": 0.0,
              "Overdue": 0.0,
              "Completed": 0.0
            };
            isLoading = false;
          });
        } else {
          // Convert the API data to a format suitable for the pie chart
          Map<String, double> chartData = {};
          
          // Ensure all expected status types are present
          chartData["Pending"] = (data["Pending"] ?? 0).toDouble();
          chartData["Due Soon"] = (data["Due Soon"] ?? 0).toDouble();
          chartData["Overdue"] = (data["Overdue"] ?? 0).toDouble();
          chartData["Completed"] = (data["Completed"] ?? 0).toDouble();
          
          // If all values are 0, show a "No Tasks" message
          bool hasData = chartData.values.any((value) => value > 0);
          
          setState(() {
            if (hasData) {
              dataMap = chartData;
            } else {
              dataMap = {"No Tasks": 1.0}; // Show something in the chart
            }
            isLoading = false;
          });
        }
      } else if (response.statusCode == 404) {
        // Handle 404 specifically - likely no tasks found
        print("No tasks found (404), showing empty state");
        setState(() {
          dataMap = {
            "Pending": 0.0,
            "Due Soon": 0.0,
            "Overdue": 0.0,
            "Completed": 0.0
          };
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching chart data: $error");
      // Show user-friendly error state
      setState(() {
        dataMap = {"Error Loading Data": 1.0};
        isLoading = false;
      });
      
      // Show snackbar for user feedback
      Get.snackbar(
        "Data Loading Error",
        "Unable to load task statistics. Please check your connection and try again.",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _selectDate(BuildContext context, bool isStartDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            backgroundColor: Colors.white70,
            content: SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.95,
              height: 150,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (DateTime value) {
                  setState(() {
                    if (isStartDate) {
                      startDate = value;
                    } else {
                      endDate = value;
                    }
                  });
                },
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  fetchChartData(
                    startDate: startDate != null
                        ? "${startDate!.toLocal()}".split(' ')[0]
                        : null,
                    endDate: endDate != null
                        ? "${endDate!.toLocal()}".split(' ')[0]
                        : null,
                  );
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            SizedBox(width: 10),
            Text(
              "At a glance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => _selectDate(context, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(1),
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                  child: Text(
                    startDate == null
                        ? "Select Start Date"
                        : "${startDate!.toLocal()}".split(' ')[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _selectDate(context, false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(1),
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                  child: Text(
                    endDate == null
                        ? "Select End Date"
                        : "${endDate!.toLocal()}".split(' ')[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    startDate = null;
                    endDate = null;
                    fetchChartData();
                  });
                },
                icon: const Icon(Icons.repeat),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Loading task statistics...'),
                    ],
                  ),
                )
              : dataMap.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No task data available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : PieChart(
                      dataMap: dataMap,
                      animationDuration: const Duration(milliseconds: 800),
                      chartType: ChartType.ring,
                      chartRadius: MediaQuery.of(context).size.width / 2.5,
                      colorList: colorList,
                      legendOptions: const LegendOptions(
                        showLegends: true,
                        legendPosition: LegendPosition.right,
                        legendTextStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: false,
                        showChartValues: true,
                        showChartValuesOutside: false,
                        decimalPlaces: 0,
                        chartValueStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
