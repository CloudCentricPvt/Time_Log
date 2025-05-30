// To parse this JSON data, do
//
//     final checkInOutResponse = checkInOutResponseFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/utils/constants/api_container.dart';

import '../network/k_network_api_service.dart';
import '../utils/popups/k_material_dialog.dart';

CheckInOutResponse checkInOutResponseFromJson(String str) => CheckInOutResponse.fromJson(json.decode(str));

String checkInOutResponseToJson(CheckInOutResponse data) => json.encode(data.toJson());

 Future<dynamic> getCheckInOutDetails(BuildContext context) async {

   var apiNetwork = KNetworkApiServices();
   final storage = GetStorage();
   var empID = storage.read("EMP_ID");
   try{
     var response = await apiNetwork.getRequest("${KApiEndPoints.checkInOutDetails}?employeeId=$empID",context);
     print("GET_URL_CHECK_IN: ${KApiEndPoints.checkInOutDetails}?employeeId=$empID");

     if(response!=null && response['status']==true){
       CheckInOutResponse checkInOutResponse = CheckInOutResponse.fromJson(response);
       return checkInOutResponse;

     }else{
       print("expiredtoken");
       if(response.status==false && response.code == 401){
         print("expiredtoken");

       }
       return[];
     }
     
   }catch(e){
     print("Error in getAllTimeLog: $e");
     return []; // or rethrow if you want to handle it higher up
   }
   
 }

class CheckInOutResponse {
  List<CheckInOutList> checkInOutDetails;
  bool status;
  String message;
  int code;
  String apiVersion;
  String apiUrl;

  CheckInOutResponse({
    required this.checkInOutDetails,
    required this.status,
    required this.message,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory CheckInOutResponse.fromJson(Map<String, dynamic> json) => CheckInOutResponse(
    checkInOutDetails: List<CheckInOutList>.from(json["data"].map((x) => CheckInOutList.fromJson(x))),
    status: json["status"],
    message: json["message"],
    code: json["code"],
    apiVersion: json["api_version"],
    apiUrl: json["api_url"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(checkInOutDetails.map((x) => x.toJson())),
    "status": status,
    "message": message,
    "code": code,
    "api_version": apiVersion,
    "api_url": apiUrl,
  };
}

class CheckInOutList {
  dynamic totalHours;
  dynamic formattedDate;
  String checkOutTime;
  dynamic checkOutLocation;
  String checkOutdescription;
  String checkInTime;
  String checkInLocation;
  String checkIndescription;
  String checkInCheckOutId;
  bool checkInCheckOut;

  CheckInOutList({
    required this.totalHours,
    required this.formattedDate,
    required this.checkOutTime,
    required this.checkOutLocation,
    required this.checkOutdescription,
    required this.checkInTime,
    required this.checkInLocation,
    required this.checkIndescription,
    required this.checkInCheckOutId,
    required this.checkInCheckOut,
  });

  factory CheckInOutList.fromJson(Map<String, dynamic> json) => CheckInOutList(
    totalHours: json["totalHours"],
    formattedDate: json["formattedDate"],
    checkOutTime: json["checkOutTime"],
    checkOutLocation: json["checkOutLocation"],
    checkOutdescription: json["checkOutdescription"],
    checkInTime: json["checkInTime"],
    checkInLocation: json["checkInLocation"],
    checkIndescription: json["checkIndescription"],
    checkInCheckOutId: json["checkInCheckOutId"],
    checkInCheckOut: json["checkInCheckOut"],
  );

  Map<String, dynamic> toJson() => {
    "totalHours": totalHours,
    "formattedDate": formattedDate,
    "checkOutTime": checkOutTime,
    "checkOutLocation": checkOutLocation,
    "checkOutdescription": checkOutdescription,
    "checkInTime": checkInTime,
    "checkInLocation": checkInLocation,
    "checkIndescription": checkIndescription,
    "checkInCheckOut": checkInCheckOut,
    "checkInCheckOutId":checkInCheckOutId
  };
}
