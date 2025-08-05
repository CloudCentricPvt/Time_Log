import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

import '../../models/annual_leave_graph_res.dart';
import '../popups/k_material_dialog.dart';
import 'check_internet.dart';
import 'k_colors.dart';

class KAnnualLeaveGraph extends StatefulWidget {
  @override
  State<KAnnualLeaveGraph> createState() => _CustomMonthlyChartState();
}

class _CustomMonthlyChartState extends State<KAnnualLeaveGraph> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();
  List<AnnualLeaveData> monthlyLeave = [];
  List<AnnualLeaveData> annualLeave = [];
  List<AnnualLeaveData> compOffRequest = [];
  List<AnnualLeaveData> wfhRequest = [];

  /// --- define month for FLSpot.
  List<FlSpot> monthlyTakenLeave = [];
  List<FlSpot> annuallyTakenLeave = [];
  List<FlSpot> compOffTakenLeave = [];
  List<FlSpot> wfhTakenLeave = [];


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
    _fetchMonthlyLeaveDataForShowingGraph();
    _fetchAnnualLeaveDataForShowingGraph();
    _fetchCompOffLeaveForShowingGraph();
    _fetchWFHLeaveForShowingGraph();

  }
  /// --- this method used for fetch monthly leave from SF.
  Future<void> _fetchMonthlyLeaveDataForShowingGraph() async {
    final response = await getAnnualLeaveDetailsForGraph(context);

    if (response is AnnualLeaveGraphResponse) {
      // Create a list with 12 months initialized to 0.0
      List<double> monthHourMap = List.filled(12, 0.0);

      // Loop through each working hour detail from the API
      for (var detail in response.annualDataForGraph) {
        // Find the index of the month (e.g., January = 0)
        int index = fullMonthNames.indexOf(detail.strMonthName);

        // If the month name is valid
        if (index != -1) {
          // Get the hour count or use 0 if it's null
          double monthlyLeave = detail.intLeaveCount ?? 0;
          // Limit the hour count to a maximum of 250
          double cappedHours = monthlyLeave > 40 ? 40.0 : monthlyLeave.toDouble();

          // Store the value in the correct month index
          monthHourMap[index] = cappedHours;
        }
      }

      // Update the chart data with the new values
      setState(() {
        monthlyLeave = response.annualDataForGraph;
        monthlyTakenLeave = List.generate(12, (index) => FlSpot(index.toDouble(), monthHourMap[index]),
        );
      });
    }
  }

  /// --- this method used for fetch Annual leave from SF.
  Future<void> _fetchAnnualLeaveDataForShowingGraph() async {
    final response = await getAnnualLeaveDetailsForGraph(context);

    if (response is AnnualLeaveGraphResponse) {
      // Create a list with 12 months initialized to 0.0
      List<double> monthHourMap = List.filled(12, 0.0);

      // Loop through each working hour detail from the API
      for (var detail in response.annualDataForGraph) {
        // Find the index of the month (e.g., January = 0)
        int index = fullMonthNames.indexOf(detail.strMonthName);

        // If the month name is valid
        if (index != -1) {
          // Get the hour count or use 0 if it's null
          double annualLeave = detail.intCumulativeLeaveCount ?? 0;
          // Limit the hour count to a maximum of 250
          double cappedHours = annualLeave > 40 ? 40.0 : annualLeave.toDouble();

          // Store the value in the correct month index
          monthHourMap[index] = cappedHours;
        }
      }

      // Update the chart data with the new values
      setState(() {
        annualLeave = response.annualDataForGraph;
        annuallyTakenLeave = List.generate(12, (index) => FlSpot(index.toDouble(), monthHourMap[index]),
        );
      });
    }
  }

  /// --- this method used for fetch Comp Off leave from SF.
  Future<void> _fetchCompOffLeaveForShowingGraph() async {
    final response = await getAnnualLeaveDetailsForGraph(context);

    if (response is AnnualLeaveGraphResponse) {
      // Create a list with 12 months initialized to 0.0
      List<double> monthHourMap = List.filled(12, 0.0);

      // Loop through each working hour detail from the API
      for (var detail in response.annualDataForGraph) {
        // Find the index of the month (e.g., January = 0)
        int index = fullMonthNames.indexOf(detail.strMonthName);

        // If the month name is valid.
        if (index != -1) {
          // Get the hour count or use 0 if it's null
          double compOff = detail.intCompOffCount ?? 0;
          // Limit the hour count to a maximum of 250
          double cappedHours = compOff > 40 ? 40.0 : compOff.toDouble();

          // Store the value in the correct month index
          monthHourMap[index] = cappedHours;
        }
      }

      // Update the chart data with the new values
      setState(() {
        compOffRequest = response.annualDataForGraph;
        compOffTakenLeave= List.generate(12, (index) => FlSpot(index.toDouble(), monthHourMap[index]),
        );
      });
    }
  }

  /// --- this method used for fetch WFH leave from SF.
  Future<void> _fetchWFHLeaveForShowingGraph() async {
    final response = await getAnnualLeaveDetailsForGraph(context);

    if (response is AnnualLeaveGraphResponse) {
      // Create a list with 12 months initialized to 0.0
      List<double> monthHourMap = List.filled(12, 0.0);

      // Loop through each working hour detail from the API
      for (var detail in response.annualDataForGraph) {
        // Find the index of the month (e.g., January = 0)
        int index = fullMonthNames.indexOf(detail.strMonthName);

        // If the month name is valid
        if (index != -1) {
          // Get the hour count or use 0 if it's null
          double compOff = detail.intWfhCount ?? 0;
          // Limit the hour count to a maximum of 250
          double cappedHours = compOff > 40 ? 40.0 : compOff.toDouble();

          // Store the value in the correct month index
          monthHourMap[index] = cappedHours;
        }
      }

      // Update the chart data with the new values
      setState(() {
        wfhRequest = response.annualDataForGraph;
        wfhTakenLeave= List.generate(12, (index) => FlSpot(index.toDouble(), monthHourMap[index]),
        );
      });
    }
  }

  // Show labels only for selected months
  final Set<int> visibleMonthIndexes = {0, 2, 4, 6, 8, 10};

  @override
  Widget build(BuildContext context) {
    final chartHeight = MediaQuery.of(context).size.height * 0.25;

    return SizedBox(
      height: chartHeight,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: KColors.appColorWhite,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded( // this ensures the LineChart fills remaining height
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 11,
                  minY: 0,
                  maxY: 40,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyTakenLeave,
                      isCurved: false,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: annuallyTakenLeave,
                      isCurved: false,
                      color: Colors.yellow[800],
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: compOffTakenLeave,
                      isCurved: false,
                      color: Colors.red,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: wfhTakenLeave,
                      isCurved: false,
                      color: Colors.green,
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
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SideTitleWidget(
                            axisSide: AxisSide.bottom,
                            child: Text(""),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, _) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
