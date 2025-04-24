
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';
import '../utils/constants/k_date_and_time.dart';
import '../utils/toasts/k_show_info.dart';

class CheckInCheckOutController{
  final TextEditingController descriptionController = TextEditingController();
  final KNetworkApiServices networkApiServices = KNetworkApiServices();
  final storage = GetStorage();
  
  /// --- check in
  Future<dynamic> checkIn(BuildContext context, String des,String lat,String long) async {
    if (descriptionController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter check-In description"),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    /// --- call Check In API
    var checkInPayLoad = {
      "empId": storage.read("EMP_ID"),
      "latitude": lat,
      "longitude": long,
      "description": des,
      "checkInDateTime": KDateAndTime().getCurrentDateAndTime(),
      "checkInCheckOutTrue": true
    };
    print("PAYLOAD: $checkInPayLoad");
    /// ---  Call API
    try{
      var response = await networkApiServices.postRequest(checkInPayLoad, KApiEndPoints.checkIn);
      print("RESPONSE: $response");
      if(response!=null){
        if(response['code']==200 && response['status']==true){

          KShowInfo.showSuccessMessage(context, response['message']?.toString() ?? 'No message');
        }else{
          KShowInfo.showInfoMessage(context, response['message']?.toString() ?? 'No message');
          
        }
      }
    }catch(e){
      KShowInfo.showErrorMessage(context, e.toString() ?? 'No message');
      print("#RESPONSE3: $e".toString());
    }

  }

  /// --- Check Out
  Future<dynamic> checkOut(BuildContext context, String des,String lat,String long) async {
    if (descriptionController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter check-Out description"),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    /// --- call Check Out API
    var checkOutPayLoad = {
      "empId": storage.read("EMP_ID"),
      "latitude": "28.619248",
      "longitude": "77.366885",
      "description": des,
      "checkOutDateTime": KDateAndTime().getCurrentDateAndTime(),
      "checkInCheckOutTrue": false
    };
    print("PAYLOAD: $checkOutPayLoad");
    /// ---  Call API
    try{
      var response = await networkApiServices.postRequest(checkOutPayLoad, KApiEndPoints.checkOut);
      print("RESPONSE: $response");
      if(response!=null){
        if(response['code']==200 && response['status']==true){

          KShowInfo.showSuccessMessage(context, response['message']?.toString() ?? 'No message');
        }else{
          KShowInfo.showInfoMessage(context, response['message']?.toString() ?? 'No message');

        }
      }
    }catch(e){
      KShowInfo.showErrorMessage(context, e.toString() ?? 'No message');
      print("#RESPONSE3: $e".toString());
    }

  }

}