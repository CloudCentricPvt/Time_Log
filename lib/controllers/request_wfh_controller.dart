import 'package:flutter/material.dart';

class RequestWFHController {
  final TextEditingController descriptionController = TextEditingController();

  Future<void> checkDescription(BuildContext context) async {
    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Description"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Comp Off Request applied successfully"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }
}
