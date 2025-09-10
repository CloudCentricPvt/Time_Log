import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../constants/k_colors.dart';

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
            center: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // 🟢 Prevent extra vertical space
                crossAxisAlignment: CrossAxisAlignment.center, // 🟢 Center horizontally
                children: [
                  Text(
                    value,
                    style: valueStyle ??
                        TextStyle(
                          fontSize: valueTextSize ?? 22,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (label != null)
                    Text(
                      label,
                      style: labelStyle ??
                          TextStyle(
                            fontSize: labelTextSize ?? 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: KColors.appBlackColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),

            progressColor: progressColor ?? KColors.appPrimary,
            backgroundColor: backgroundColor ?? Colors.grey[300]!,
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ),
        if (bottomLabel != null) ...[
          Text(
            bottomLabel,
            textAlign: TextAlign.center,
            style: bottomLabelStyle ??
                TextStyle(
                  fontSize: bottomLabelTextSize ?? 12,
                  color: bottomLabelColor ?? KColors.appBlackColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600
                ),
          ),
        ],
      ],
    );
  }
}

