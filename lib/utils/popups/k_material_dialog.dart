
import 'package:flutter/material.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class KMaterialDialogs {
  KMaterialDialogs._();

  static void confirmationDialog(
      BuildContext context,
      Widget iconsButtonConfirm,
      Widget iconsOutlineButtonCancel,
      String title,
      String message) {
    Dialogs.materialDialog(
        barrierDismissible: false,
        msg: message,
        title: title,
        color: Colors.white,
        context: context,
        actions: [iconsOutlineButtonCancel, iconsButtonConfirm]);
  }

  static void sessionTimeOut(BuildContext context, Widget iconsButtonConfirm,
      String title, String message) {
    Dialogs.materialDialog(
        msg: message,
        title: title,
        color: Colors.white,
        context: context,
        actions: [iconsButtonConfirm]);
  }

  static void noInternetFound(BuildContext context, Widget iconsButtonConfirm,
      String title, String message) {
    Dialogs.materialDialog(
        msg: message,
        title: title,
        color: Colors.white,
        context: context,
        actions: [iconsButtonConfirm]);
  }

  static void infoMaterialDialog(BuildContext context,
      Widget iconsButtonConfirm, String title, String message) {
    Dialogs.materialDialog(
        msg: message,
        title: title,
        color: Colors.white,
        context: context,
        actions: [iconsButtonConfirm]);
  }

  static void validationCheck(BuildContext context,
      String title, String message) {
    Dialogs.materialDialog(
        msg: message,
        title: title,
        color: Colors.white,
        context: context,
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'Okay',
            color: Colors.red,
            textStyle: const TextStyle(color: Colors.white,fontSize: 16),
            iconColor: Colors.white,
          )
        ]);
  }
}