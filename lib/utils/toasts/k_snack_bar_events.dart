

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

import '../../views/authentication/login_screen.dart';
import '../constants/k_colors.dart';

class   KSnackBarEvents {
  static hideSnackBar() =>
      ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  static successSnackBar({required title, message = '', duration = 3}) {
    Get.snackbar(title, message,
        isDismissible: true,
        shouldIconPulse: true,
        colorText: Colors.white,
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: duration));
  }



  static warningSnackBar({required title, message = '', duration = 3}) {
    Get.snackbar(title, message,
        isDismissible: true,
        shouldIconPulse: true,
        colorText: Colors.white,
        backgroundColor: Colors.orange,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: duration));
  }

  static errorSnackBar({required title, message = '', duration = 3}) {
    Get.snackbar(title, message,
        isDismissible: true,
        shouldIconPulse: true,
        colorText: Colors.white,
        backgroundColor: KColors.appPrimary,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: duration));
  }

  static infoSnackBar({required title, message = '', duration = 3}) {
    Get.snackbar(title, message,
        isDismissible: true,
        shouldIconPulse: true,
        colorText: Colors.white,
        backgroundColor: KColors.appSecondaryGrey,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: duration));
  }

  static errorDialogSnackBarToLogOut({required title, message = '', duration = 3}) {
    Get.snackbar(title, message,
        isDismissible: false,
        shouldIconPulse: true,
        colorText: Colors.white,
        backgroundColor: KColors.appPrimary,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: duration),
        mainButton: TextButton(
            onPressed: () {
              final localStorage = GetStorage();
              localStorage.erase();
              Get.offAll(() => const LoginScreen());
            },
            child: Text("Ok")));
  }
}