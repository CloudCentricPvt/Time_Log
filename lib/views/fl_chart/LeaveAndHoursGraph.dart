import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LeaveAndHoursGraph extends StatefulWidget {
  @override
  _LeaveAndHoursGraphState createState() => _LeaveAndHoursGraphState();
}

class _LeaveAndHoursGraphState extends State<LeaveAndHoursGraph> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Annual Leave Details
            buildSectionTitle("Annual Leave Details"),
            buildLegend([
              {"color": Colors.blue, "text": "Monthly Leave"},
              {"color": Colors.yellow, "text": "Annual Leave"},
              {"color": Colors.red, "text": "Comp Off Request"},
              {"color": Colors.green, "text": "WFH Request"},
            ]),
            SizedBox(height: 10),
            Container(
              height: 200,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: LineChart(annualLeaveData()),
            ),

            SizedBox(height: 20),

            // Working Hours Details
            buildSectionTitle("Working Hours Details"),
            buildLegend([
              {"color": Colors.blue, "text": "Working Hours"},
              {"color": Colors.orange, "text": "Self Study Hours"},
            ]),
            SizedBox(height: 10),
            Container(
              height: 200,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: LineChart(workingHoursData()),
            ),
          ],
        ),
      ),
    );
  }

  // Section Title
  Widget buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Legend Widget
  Widget buildLegend(List<Map<String, dynamic>> items) {
    return Row(
      children: items
          .map((item) => Padding(
        padding: EdgeInsets.only(right: 12),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item["color"],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: 5),
            Text(item["text"], style: TextStyle(fontSize: 12)),
          ],
        ),
      ))
          .toList(),
    );
  }

  // Annual Leave Line Chart Data
  LineChartData annualLeaveData() {
    return LineChartData(
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 1:
                  return Text("January");
                case 3:
                  return Text("March");
                case 5:
                  return Text("May");
                case 7:
                  return Text("July");
                case 9:
                  return Text("September");
                case 11:
                  return Text("December");
              }
              return Text("");
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      gridData: FlGridData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: [FlSpot(1, 1), FlSpot(3, 0.5), FlSpot(5, 0.2)],
          isCurved: true,
          color: Colors.blue,
          dotData: FlDotData(show: true),
        ),
        LineChartBarData(
          spots: [FlSpot(1, 0.8), FlSpot(3, 0.4), FlSpot(5, 0.2)],
          isCurved: true,
          color: Colors.green,
          dotData: FlDotData(show: true),
        ),
      ],
    );
  }

  // Working Hours Line Chart Data
  LineChartData workingHoursData() {
    return LineChartData(
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 1:
                  return Text("January");
                case 3:
                  return Text("March");
                case 5:
                  return Text("May");
                case 7:
                  return Text("July");
                case 9:
                  return Text("September");
                case 11:
                  return Text("December");
              }
              return Text("");
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      gridData: FlGridData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: [FlSpot(1, 200), FlSpot(3, 50), FlSpot(5, 0)],
          isCurved: true,
          color: Colors.blue,
          dotData: FlDotData(show: true),
        ),
        LineChartBarData(
          spots: [FlSpot(1, 100), FlSpot(3, 30), FlSpot(5, 0)],
          isCurved: true,
          color: Colors.orange,
          dotData: FlDotData(show: true),
        ),
      ],
    );
  }
}
