import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/utils/constants/k_date_and_time.dart';
import 'package:time_log/utils/toasts/k_show_info.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

class TimeLogController {
  final KNetworkApiServices networkApiServices = KNetworkApiServices();
  final storage = GetStorage();
  String? selectedProject; // Store selected dropdown value
  String? selectedTask; // Store selected radio button value
  final TextEditingController projectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hrsController = TextEditingController();
  final TextEditingController minController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  ///--- Create Time log
  Future<void> applyTimeLog(BuildContext context, String? projectName, String? taskName, String? date, String? hours, String? minutes, String? description) async {


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

    if (hrsController.text.trim().isEmpty && minController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter either Hours or Minutes."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    /*if (hrsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Hours."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }*/

    int? value = int.tryParse(hrsController.text.trim());
   /* if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid number."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }*/

   /* if (value! < 0 || value > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hours must be between 0 and 8."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
*/
    /*if (minController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Minutes."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }*/

    if (hrsController.text.isNotEmpty) {
      int? minValue = int.tryParse(hrsController.text);

      if (minValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enter a valid number for Hrs."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (minValue < 1 || minValue > 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hours must be between 1 and 8."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }


    if (minController.text.isNotEmpty) {
      int? minValue = int.tryParse(minController.text);

      if (minValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enter a valid number for Minutes."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (minValue < 0 || minValue > 59) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Minutes must be between 0 and 59."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
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

    String formattedDate = KDateAndTime().convertToStandardDateFormatYYYY_MM_DD(date.toString());
    print("#formattedDate: $formattedDate");


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
      "projectName": projectName,
      "taskName": taskName,
      "date": (formattedDate == null || formattedDate.isEmpty)? DateTime.now().toString().split(' ')[0] : formattedDate,
      "hours": (hours == null || hours.isEmpty) ? '0' : hours,
      "minutes": (minutes == null || minutes.isEmpty) ? '0' : minutes,
      "description": description
    };
    print("#Create_Time_Log_PAYLOAD: $createTimeLog");

    try {
      var response = await networkApiServices.postRequest(createTimeLog, KApiEndPoints.createTimeLog,context);
      print("#Time_RESPONSE: $response");

      if (response != null) {
        // Check for success
        if (response['code'] == 200) {
          Navigator.pop(context, true);
          KShowInfo.showSuccessMessage(context,  response['message']);
        } else {
          KShowInfo.showErrorMessage(context, response['message']);
          print('Else1');
        }
      } else {
        KShowInfo.showErrorMessage(context, response['message']);
        print('Else2');
      }
    } catch (e) {
      KShowInfo.showInfoMessage(context, "An error occurred: $e");
    }
  }

  ///--- Update time log
  Future<void> updateTimeLog(BuildContext context,String? id,String? projectId, String? taskName, String? date, String? hours, String? minutes, String? description) async {

    /*if (projectName == null || projectName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select Project"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }*/

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
    int? value = int.tryParse(hrsController.text.trim());
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid number."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (value < 1 || value > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hours must be between 1 and 8."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    /*if (minController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Minutes."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }*/


    if (minController.text.isNotEmpty) {
      int? minValue = int.tryParse(minController.text);

      if (minValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enter a valid number for Minutes."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (minValue < 0 || minValue > 59) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Minutes must be between 0 and 59."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
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
    String formattedDate = KDateAndTime().convertToStandardDateFormatYYYY_MM_DD(date.toString());
    print("#formattedDate: $formattedDate");

    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a description"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    /// --- call Update time log API
    var updateTimeLog = {
      "timeLogId": id,
      "projectName": projectId,
      "taskName": taskName,
      "date": formattedDate,
      "hours": hours,
      "minutes": minutes,
      "description": description
    };

    print('Payload_Update_Time:$updateTimeLog');

    try {
      var response = await networkApiServices.putRequest(updateTimeLog, KApiEndPoints.updateTimeLog,context);
      print("#Time_RESPONSE: $response");

      if (response != null) {
        // Check for success
        if (response['code'] == 200) {
          Navigator.pop(context, true);
          KShowInfo.showSuccessMessage(context,  response['message']);

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
