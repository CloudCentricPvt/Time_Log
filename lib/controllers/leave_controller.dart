import 'package:flutter/material.dart';

class ApplyLeaveController {
  String? selectedStartDate;
  String? selectedEndDate;
  String? selectedLeaveType; // Store selected dropdown value
  String? selectedLeaveOption; // Store selected radio button value
  final TextEditingController descriptionController = TextEditingController(); // Keep controller for text field

  Future<void> applyLeave(BuildContext context) async {

    if (selectedLeaveType == null || selectedLeaveType!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a Leave type"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedLeaveOption == null || selectedLeaveOption!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select Leave type (Full day or Half day,etc.)"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a description"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Leave Applied successfully"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }
}
