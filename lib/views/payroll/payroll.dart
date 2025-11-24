import 'package:flutter/material.dart';

import '../../utils/constants/k_colors.dart';
import 'package:flutter/services.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';

class Payroll extends StatefulWidget {
  const Payroll({super.key});

  @override
  State<Payroll> createState() => _PayrollState();
}

class _PayrollState extends State<Payroll> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: const KCustomAppBar(screenTitle: 'Payroll'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF84DBFF), // Same as app bar
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Center(
        child: Text(
          "Right Now it is Pending",
          style: TextStyle(
            fontFamily: "Poppins",
          ),
        ),
      ),
    );
  }
}
