import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class KCircularProgressBar {
  static Widget circularIndicator({
    double radius = 65.0,
    double lineWidth = 2.0,
    required double percent,
    required String value,
    String? label, // Optional label inside circle
    String? bottomLabel, // Optional label outside circle
    Color? progressColor,
    Color? backgroundColor,
    Color? bottomLabelColor, // Optional bottom text color
    TextStyle? valueStyle,
    TextStyle? labelStyle,
    TextStyle? bottomLabelStyle,
    double? valueTextSize,
    double? labelTextSize,
    double? bottomLabelTextSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularPercentIndicator(
            radius: radius,
            lineWidth: lineWidth,
            percent: percent,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value, // Dynamic Value
                  style: valueStyle ??
                      TextStyle(
                        fontSize: valueTextSize ?? 22,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (label != null) // Show label inside the circle if provided
                  Text(
                    label,
                    style: labelStyle ??
                        TextStyle(
                          fontSize: labelTextSize ?? 16,
                          color: Colors.black54,
                        ),
                  ),
              ],
            ),
            progressColor: progressColor ?? Colors.blue,
            backgroundColor: backgroundColor ?? Colors.grey[300]!,
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ),
        if (bottomLabel != null) // Show label outside the circle if provided
          Text(
            bottomLabel,
            style: bottomLabelStyle ??
                TextStyle(
                  fontSize: bottomLabelTextSize ?? 14,
                  color: bottomLabelColor ?? Colors.black, // Default black
                  fontWeight: FontWeight.bold,
                ),
          ),
      ],
    );
  }
}
