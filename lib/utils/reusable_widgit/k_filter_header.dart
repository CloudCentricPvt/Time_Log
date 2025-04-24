import 'package:flutter/material.dart';
import '../constants/k_colors.dart';

class KFilterHeader extends StatelessWidget {
  final String textTitle;
  final Color? strokeColor;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback? onHistoryTap;
  final double? height;
  final double? width;

  const KFilterHeader({
    super.key,
    required this.textTitle,
    this.strokeColor = KColors.appColorWhite, // Default stroke color
    this.textColor = KColors.orangeColor, // Default text color
    this.backgroundColor = KColors.appColorWhite, // Default background
    this.onHistoryTap,
    this.height, // Optional height
    this.width,  // Optional width
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, // Set height if provided
      width: width,   // Set width if provided
      child: Card(
        color: backgroundColor,
        shadowColor: KColors.cardShadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), // Rounded corners
          side: BorderSide(color: strokeColor!, width: 1), // Stroke border
        ),
        child: InkWell(
          onTap: onHistoryTap, // Make card clickable if needed
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Center(
              child: Text(
                textTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
