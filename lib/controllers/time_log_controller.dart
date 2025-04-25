import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/utils/toasts/k_show_info.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

class TimeLogController {
  final KNetworkApiServices networkApiServices = KNetworkApiServices();
  final storage = GetStorage();
  String? selectedStartDate;
  String? selectedDate;
  String? selectedEndDate;
  String? selectedProject; // Store selected dropdown value
  String? selectedTask; // Store selected radio button value
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hrsController = TextEditingController();
  final TextEditingController minController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  Future<void> applyTimeLog(
      BuildContext context,
      String? projectName,
      String? taskName,
      String? date,
      String? hours,
      String? minutes,
      String? description) async {

    if (projectName == null || projectName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select Project"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (taskName == null || taskName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select Task"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (hrsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Hours."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (minController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter  Minutes."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (dateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select date."),
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

    /// --- call Create time log API
    var createTimeLog = {
      "employeeId": storage.read('EMP_ID'),
      "projectName": 'a0b7z00000664GnAAI',
      "taskName": 'Bug Fixing',
      "date": date,
      "hours": hours,
      "minutes": minutes,
      "description": description
    };
    print("#PAYLOAD: $createTimeLog");

    try {
      var response = await networkApiServices.postRequest(createTimeLog, KApiEndPoints.createTimeLog);
      print("#Time_RESPONSE: $response");

      if (response != null) {
        // Check for success
        if (response['code'] == 200) {
          Navigator.pop(context, true);
        } else {
          KShowInfo.showInfoMessage(context, response['message']);
        }
      } else {
        KShowInfo.showInfoMessage(context, response['message']);
      }
    } catch (e) {
      KShowInfo.showInfoMessage(context, "An error occurred: $e");
    }
  }
}
