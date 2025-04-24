import 'package:flutter/material.dart';

class ChangePasswordController{

  final TextEditingController currentPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();


  Future<void>changePassword(BuildContext context) async {

    if (currentPassController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter current password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (newPassController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please new password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (confirmPassController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter confirm password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password changed successfully"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);

  }

}