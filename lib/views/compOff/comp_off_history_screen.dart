import 'package:flutter/material.dart';

import '../../utils/constants/k_colors.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';

class CompOffHistoryScreen extends StatefulWidget {
  const CompOffHistoryScreen({super.key});

  @override
  State<CompOffHistoryScreen> createState() => _CompOffHistoryScreenState();
}

class _CompOffHistoryScreenState extends State<CompOffHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: KCustomAppBar(screenTitle: 'Comp Off History',historyTitle:'Request New',showHistory: true,onHistoryTap: (){},),
      ),
    );
  }
}
