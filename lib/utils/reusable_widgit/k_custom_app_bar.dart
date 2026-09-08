import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_log/utils/constants/k_colors.dart';

import '../constants/k_fonts.dart';

class KCustomAppBar extends StatelessWidget {
  final String screenTitle;
  final bool showHistory;
  final String historyTitle;
  final VoidCallback? onHistoryTap;

  const KCustomAppBar({
    super.key,
    required this.screenTitle,
    this.showHistory = false,
    this.historyTitle = "History",
    this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16.0, right: 0.0),
      dense: true,
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: const Icon(
            size: 24, Icons.arrow_back_ios, color: KColors.appColorWhite),
      ),
      title: Text(screenTitle,
          style: KTextStyle.titleLarge
              .copyWith(color: Colors.white, letterSpacing: 0.7, fontSize: 17)),
      trailing: showHistory
          ? GestureDetector(
              onTap: onHistoryTap, // Make it clickable
              child: Card(
                shadowColor: KColors.cardShadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 6, right: 6, top: 1, bottom: 1),
                  child: Text(
                    historyTitle, // Use custom title
                    style: const TextStyle(
                      color: KColors.appPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            )
          : null, // Show only when showHistory is true
    );
  }
}
