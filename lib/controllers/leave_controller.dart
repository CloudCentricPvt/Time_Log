import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/utils/constants/api_container.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/k_date_and_time.dart';
import '../utils/toasts/k_show_info.dart';

class ApplyLeaveController {
  String? selectedStartDate;
  String? selectedEndDate;
  String? selectedLeaveType; // Store selected dropdown value
  String? selectedLeaveOption; // Store selected radio button value
  final TextEditingController descriptionController = TextEditingController(); // Keep controller for text field
  final storage = GetStorage();
  final KNetworkApiServices networkApiServices = KNetworkApiServices();

  /// --- Apply for Request Leave
  Future<void> applyLeave(BuildContext context, String? startDate,String? endDate,String? countDay,String? leaveType,String? leaveDay,String? des) async {
    String fStartDate = KDateAndTime().convertToStandardDateFormatYYYY_MM_DD(startDate.toString());
    String fEndDate= KDateAndTime().convertToStandardDateFormatYYYY_MM_DD(endDate.toString());

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


    var applyLeavePayLoad = {
      "employeeId": storage.read('EMP_ID'),
      "annualLeaveId": storage.read('ANNUAL_LEAVE_ID'),
      "startDate": fStartDate,
      "endDate": fEndDate,
      "leaveType": leaveDay == "Full day" ? "Full" : "Half",
      "leaveCategory": leaveType,
      "description": des,
      "dayCount":countDay
    };

    print("#applyLeavePayLoad: $applyLeavePayLoad");

    /// --- Call apply leave API
    try{
      var response = await networkApiServices.postRequest(applyLeavePayLoad, KApiEndPoints.applyLeave,context);
      print("#APPLY_LEAVE_RESPONSE: $response");
      if(response!=null){
        if(response['code'] == 201 && response['status'] == true){

          Navigator.pop(context, true);
          //Navigator.pushReplacementNamed(context, '/leaves_screen');
          KShowInfo.showSuccessMessage(context, response['message']);
          print('Check_Res:"success"');
        }else{
          KShowInfo.showInfoMessage(context, response['message']);
          print('ELSE_part:"else_failed"');
        }
      }else{
        KShowInfo.showInfoMessage(context, response['message']);
        print('ELSE_part:"res_null"');
      }

    }catch(e){
      KShowInfo.showInfoMessage(context, "An error occurred: $e");
    }
  }

  /// --- Apply for Request Comp Off
  Future<void> applyCompOff(BuildContext context, String? startDate,String? endDate,String? countDay,String? des) async {
    String fStartDate = KDateAndTime().convertToStandardDateFormatYYYY_MM_DD(startDate.toString());
    String fEndDate= KDateAndTime().convertToStandardDateFormatYYYY_MM_DD(endDate.toString());

    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a description"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    var applyCompOffPayLoad = {
      "employeeId": storage.read('EMP_ID'),
      "annualLeaveId": storage.read('ANNUAL_LEAVE_ID'),
      "requestType":"Comp Off",
      "startDate": fStartDate,
      "endDate": fEndDate,
      "dayCount": countDay,
      "description": des
    };

    print("#applyCompOffPayLoad: $applyCompOffPayLoad");

    /// --- Call apply Comp Off API
    try{
      var response = await networkApiServices.postRequest(applyCompOffPayLoad, KApiEndPoints.applyCompOff,context);
      print("#APPLY_LEAVE_RESPONSE: $response");
      if(response!=null){
        if(response['code'] == 201 && response['status'] == true){

          Navigator.pop(context, true);
          KShowInfo.showSuccessMessage(context, response['message']);
          print('Check_Res:"success"');
        }else{
          KShowInfo.showInfoMessage(context, response['message']);
          print('ELSE_part:"else_failed"');
        }
      }else{
        KShowInfo.showInfoMessage(context, response['message']);
        print('ELSE_part:"res_null"');
      }

    }catch(e){
      KShowInfo.showInfoMessage(context, "An error occurred: $e");
    }
  }

  /// --- Apply for Request WFM
  Future<void> applyWFH(BuildContext context, String? startDate,String? endDate,String? countDay,String? des) async {
    String fStartDate = KDateAndTime().convertToStandardDateFormatYYYY_MM_DD(startDate.toString());
    String fEndDate= KDateAndTime().convertToStandardDateFormatYYYY_MM_DD(endDate.toString());

    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a description"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    var applyWFHPayLoad = {
      "employeeId": storage.read('EMP_ID'),
      "annualLeaveId": storage.read('ANNUAL_LEAVE_ID'),
      "requestType": "Work From Home",
      "startDate": fStartDate,
      "endDate": fEndDate,
      "dayCount": countDay,
      "description": des
    };

    print("#applyWFHPayLoad: $applyWFHPayLoad");

    /// --- Call apply WFH API
    try{
      var response = await networkApiServices.postRequest(applyWFHPayLoad, KApiEndPoints.applyWFH,context);
      print("#APPLY_LEAVE_RESPONSE: $response");
      if(response!=null){
        if(response['code'] == 201 && response['status'] == true){

          Navigator.pop(context, true);
          KShowInfo.showSuccessMessage(context, response['message']);
          print('Check_Res:"success"');
        }else{
          KShowInfo.showInfoMessage(context, response['message']);
          print('ELSE_part:"else_failed"');
        }
      }else{
        KShowInfo.showInfoMessage(context, response['message']);
        print('ELSE_part:"res_null"');
      }

    }catch(e){
      KShowInfo.showInfoMessage(context, "An error occurred: $e");
    }
  }

}
