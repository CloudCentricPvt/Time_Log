import 'package:flutter/material.dart';
import 'dart:async';

import 'package:get_storage/get_storage.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage =  GetStorage();


  @override
  void initState() {
    super.initState();
    //bool isActive = storage.read('Is_Active');
    bool isActive = (storage.read('Is_Active') as bool?) ?? false;

    Timer(const Duration(seconds: 3), () {
        // Debug log
        if (isActive == true) {
          Navigator.pushReplacementNamed(context, '/home_screen');
        } else {
          Navigator.pushReplacementNamed(context, '/login_screen');
        }
      });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.appColorWhite,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Image.asset(KAssets.appLogo,height: 320, width: 260,),
              ),
            ),
          ),
          //     const Spacer(),
          const Text(
            'A CloudCentric Product',
            style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight:FontWeight.w500
            ),
          ),
          const SizedBox(height: 18,)
        ],
      ),
    );
  }
}