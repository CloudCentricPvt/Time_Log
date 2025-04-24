import 'package:flutter/material.dart';
import 'package:time_log/utils/reusable_widgit/k_custom_app_bar.dart';
import 'package:time_log/utils/reusable_widgit/k_size_box.dart';

import '../../utils/constants/k_colors.dart';
class LeavesPolicyScreen extends StatefulWidget {
  const LeavesPolicyScreen({super.key});

  @override
  State<LeavesPolicyScreen> createState() => _LeavesPolicyScreenState();
}

class _LeavesPolicyScreenState extends State<LeavesPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: const KCustomAppBar(screenTitle: 'Leave Policy'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KSizedBox.w30,
            Text('Company Leave Policy',style: TextStyle(fontFamily: 'Poppins',fontWeight:FontWeight.w700,color: KColors.textHeadingColor),),
            Text('This leave policy ensures that employees are aware of their entitlements regarding various types of leave, maintaining a balance between work responsibilities and personal needs.',style: TextStyle(fontFamily: 'Poppins',fontWeight:FontWeight.w400,color: KColors.textHeadingColor),),
          ],
        ),
      ),
    );
  }
}
