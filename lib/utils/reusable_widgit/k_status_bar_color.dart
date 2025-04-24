import 'package:flutter/services.dart';
import 'package:time_log/utils/constants/k_colors.dart';

// Define a constant for the status bar style
class KStatusBar {
  static const SystemUiOverlayStyle customStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: KColors.appStatusBarColor, // Set the color of the status bar
    statusBarIconBrightness: Brightness.light, // Set icon color (light or dark)
  );
}
