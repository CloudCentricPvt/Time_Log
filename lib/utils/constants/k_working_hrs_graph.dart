import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

import '../../models/dashboard_res.dart';
import '../popups/k_material_dialog.dart';
import 'check_internet.dart';
import 'k_colors.dart';

class KWorkingHrsGraph extends StatefulWidget {
  @override
  State<KWorkingHrsGraph> createState() => _CustomMonthlyChartState();
}

class _CustomMonthlyChartState extends State<KWorkingHrsGraph> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();
  List<WorkingHourDetail> workingHrsDetails = [];
  List<FlSpot> workingHours = [];


  final List<String> allMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  final List<String> fullMonthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];


  @override
  void initState() {
    _checkInternetConnection();
    super.initState();
  }
  void _checkInternetConnection() async {
    bool connected = await _checkInternet.isConnected();
    if (!connected) {
      // Show no internet dialog or handle no connectivity case
      KMaterialDialogs.noInternetFound(
        context,
        IconsButton(
          onPressed: () {
            Navigator.pop(context);
            // Maybe retry or do something else
          },
          text: 'Okay',
          color: Colors.red,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        "No Internet Connection",
        "Please check your internet connection and try again.",
      );
      return; // Stop further API calls
    }
    _fetchDashboardDetails();

  }
  Future<void> _fetchDashboardDetails() async {
    final response = await getDashboard(context);

    if (response is DashboardResponse) {
      // Create a list with 12 months initialized to 0.0
      List<double> monthHourMap = List.filled(12, 0.0);

      // Loop through each working hour detail from the API
      for (var detail in response.data.workingHourDetails) {
        // Find the index of the month (e.g., January = 0)
        int index = fullMonthNames.indexOf(detail.strMonthName);

        // If the month name is valid
        if (index != -1) {
          // Get the hour count or use 0 if it's null
          int hours = detail.intHourCount ?? 0;

          // Limit the hour count to a maximum of 250
          double cappedHours = hours > 300 ? 300.0 : hours.toDouble();

          // Store the value in the correct month index
          monthHourMap[index] = cappedHours;
        }
      }

      // Update the chart data with the new values
      setState(() {
        workingHrsDetails = response.data.workingHourDetails;
        workingHours = List.generate(12, (index) => FlSpot(index.toDouble(), monthHourMap[index]),
        );
      });
    }
  }



  // Show labels only for these months (odd indexes)
  final Set<int> visibleMonthIndexes = {0, 2, 4, 6, 8, 10};




  final List<FlSpot> selfStudyHours = [
    FlSpot(0, 0),
    FlSpot(1, 0),
    FlSpot(2, 50),
    FlSpot(3, 0),
    FlSpot(4, 120),
    FlSpot(5, 0),
    FlSpot(6, 0),
    FlSpot(7, 0),
    FlSpot(8, 0),
    FlSpot(9, 0),
    FlSpot(10, 0),
    FlSpot(11, 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: KColors.appColorWhite,
          borderRadius: BorderRadius.circular(4),
        ),

        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 2.9,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 11,
                    minY: 0,
                    maxY: 300,
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: workingHours,
                        isCurved: false,
                        color: Colors.blue,
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                      LineChartBarData(
                        spots: selfStudyHours,
                        isCurved: false,
                        color: Colors.orange,
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, _) {
                            int index = value.toInt();
                            if (index >= 0 &&
                                index < allMonths.length &&
                                visibleMonthIndexes.contains(index)) {
                              return SideTitleWidget(
                                axisSide: AxisSide.bottom,
                                child: Text(
                                  allMonths[index],
                                  style: TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return SideTitleWidget(
                              axisSide: AxisSide.bottom,
                              child: Text(""),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles( // Show Y-axis on left
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 50,
                          getTitlesWidget: (value, _) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 10),
                            );
                          },
                          reservedSize: 30, // space to fit text
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),

                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
