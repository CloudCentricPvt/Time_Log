import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'k_colors.dart';

class KAnnualLeaveGraph extends StatefulWidget {
  @override
  State<KAnnualLeaveGraph> createState() => _CustomMonthlyChartState();
}

class _CustomMonthlyChartState extends State<KAnnualLeaveGraph> {
  final List<String> allMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  // Show labels only for selected months
  final Set<int> visibleMonthIndexes = {0, 2, 4, 6, 8, 10};

  // Sample data
  final List<FlSpot> monthlyLeave = [
    FlSpot(0, 11),
    FlSpot(1, 03),
    FlSpot(2, 08),
    FlSpot(3, 0),
    FlSpot(4, 0),
    FlSpot(5, 0),
    FlSpot(6, 0),
    FlSpot(7, 0),
    FlSpot(8, 0),
    FlSpot(9, 0),
    FlSpot(10, 0),
    FlSpot(11, 0),
  ];

  final List<FlSpot> annualLeave = [
    FlSpot(0, 0),
    FlSpot(1, 0),
    FlSpot(2, 21),
    FlSpot(3, 0),
    FlSpot(4, 0),
    FlSpot(5, 0),
    FlSpot(6, 0),
    FlSpot(7, 0),
    FlSpot(8, 0),
    FlSpot(9, 0),
    FlSpot(10, 0),
    FlSpot(11, 0),
  ];

  final List<FlSpot> compOff = [
    FlSpot(0, 20),
    FlSpot(1, 30),
    FlSpot(2, 10),
    FlSpot(3, 0),
    FlSpot(4, 0),
    FlSpot(5, 0),
    FlSpot(6, 0),
    FlSpot(7, 9),
    FlSpot(8, 4),
    FlSpot(9, 5),
    FlSpot(10, 0),
    FlSpot(11, 0),
  ];

  final List<FlSpot> wfhRequest = [
    FlSpot(0, 10),
    FlSpot(1, 15),
    FlSpot(2, 25),
    FlSpot(3, 0),
    FlSpot(4, 0),
    FlSpot(5, 0),
    FlSpot(6, 0),
    FlSpot(7, 20),
    FlSpot(8, 12),
    FlSpot(9, 0),
    FlSpot(10, 0),
    FlSpot(11, 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: KColors.appColorWhite,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2.9,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 11,
                    minY: 0,
                    maxY: 30,
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: monthlyLeave,
                        isCurved: false,
                        color: Colors.blue,
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                      LineChartBarData(
                        spots: annualLeave,
                        isCurved: false,
                        color: Colors.yellow[800],
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                      LineChartBarData(
                        spots: compOff,
                        isCurved: false,
                        color: Colors.red,
                        barWidth: 2,
                        dotData: FlDotData(show: true),
                      ),
                      LineChartBarData(
                        spots: wfhRequest,
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
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
                          getTitlesWidget: (value, _) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 10),
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
