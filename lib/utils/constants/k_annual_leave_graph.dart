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
      return;
    }
    _fetchAllLeaveGraphData();
  }

  Future<void> _fetchAllLeaveGraphData() async {
    final response = await getAnnualLeaveDetailsForGraph(context);

    if (response is! AnnualLeaveGraphResponse) return;

    List<double> monthly = List.filled(12, 0.0);
    List<double> annual = List.filled(12, 0.0);
    List<double> compOff = List.filled(12, 0.0);
    List<double> wfh = List.filled(12, 0.0);

    for (var detail in response.annualDataForGraph) {
      int index = fullMonthNames.indexOf(detail.strMonthName);
      if (index == -1) continue;

      monthly[index] = (detail.intLeaveCount ?? 0).clamp(0, 20).toDouble();
      annual[index] = (detail.intCumulativeLeaveCount ?? 0).clamp(0, 20).toDouble();
      compOff[index] = (detail.intCompOffCount ?? 0).clamp(0, 20).toDouble();
      wfh[index] = (detail.intWfhCount ?? 0).clamp(0, 20).toDouble();
    }

    setState(() {
      monthlyTakenLeave =
          List.generate(12, (i) => FlSpot(i.toDouble(), monthly[i]));
      annuallyTakenLeave =
          List.generate(12, (i) => FlSpot(i.toDouble(), annual[i]));
      compOffTakenLeave =
          List.generate(12, (i) => FlSpot(i.toDouble(), compOff[i]));
      wfhTakenLeave =
          List.generate(12, (i) => FlSpot(i.toDouble(), wfh[i]));
    });
  }

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
                  maxY: 20,
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
                      color: Colors.yellow,
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
