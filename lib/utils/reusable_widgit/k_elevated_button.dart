import 'package:flutter/material.dart';
import 'package:time_log/utils/constants/k_fonts.dart';
import '../constants/k_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final double? fontSize;
  final double? borderRadius;
  final double? height;
  final double? width;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.fontSize,
    this.borderRadius,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 210, // Default width: full available width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? KColors.appPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadius ?? 10.0),
            ),
          ),
          //padding: const EdgeInsets.symmetric(vertical: 14),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: KTextStyle.button,
        ),
      ),
    );
  }
}

class CustomElevatedButtonCheckInOut extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final double? fontSize;
  final double? borderRadius;
  final double? height;
  final double? width;

  const CustomElevatedButtonCheckInOut({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.fontSize,
    this.borderRadius,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: double.infinity, // Default width: full available width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? KColors.appPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadius ?? 10.0),
            ),
          ),
          //padding: const EdgeInsets.symmetric(vertical: 14),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: KTextStyle.button,
        ),
      ),
    );
  }
}
