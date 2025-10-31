
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/network/k_network_api_service.dart';
import 'package:time_log/utils/constants/api_container.dart';

ProfileDetailsResponse profileDetailsResponseFromJson(String str) => ProfileDetailsResponse.fromJson(json.decode(str));

String profileDetailsResponseToJson(ProfileDetailsResponse data) => json.encode(data.toJson());

Future<dynamic>getProfileDetails(BuildContext context)async{
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read('EMP_ID');

  try{
    var response = await apiNetwork.getRequest('${KApiEndPoints.getProfileDetails}?employeeId=$empID',context);
    print("GET_URL_Profile: ${KApiEndPoints.getProfileDetails}?employeeId=$empID");

    if(response != null && response['status'] == true){
      ProfileDetailsResponse profileDetailsResponse = ProfileDetailsResponse.fromJson(response);
      return profileDetailsResponse;

    }else{
      return [];
    }

  }catch(e){
    print("Error in get profile detalis: $e");
    return [];
  }
}


class ProfileDetailsResponse {
  ProfileDetails data;
  bool status;
  String message;
  int code;
  String apiVersion;
  String apiUrl;

  ProfileDetailsResponse({
    required this.data,
    required this.status,
    required this.message,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory ProfileDetailsResponse.fromJson(Map<String, dynamic> json) => ProfileDetailsResponse(
    data: ProfileDetails.fromJson(json["data"]),
    status: json["status"],
    message: json["message"],
    code: json["code"],
    apiVersion: json["api_version"],
    apiUrl: json["api_url"],
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "status": status,
    "message": message,
    "code": code,
    "api_version": apiVersion,
    "api_url": apiUrl,
  };
}

class ProfileDetails {
  List<LstemployeeDetail> lstemployeeDetails;

  ProfileDetails({
    required this.lstemployeeDetails,
  });

  factory ProfileDetails.fromJson(Map<String, dynamic> json) => ProfileDetails(
    lstemployeeDetails: List<LstemployeeDetail>.from(json["lstemployeeDetails"].map((x) => LstemployeeDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "lstemployeeDetails": List<dynamic>.from(lstemployeeDetails.map((x) => x.toJson())),
  };
}

class LstemployeeDetail {
  /*String employeePhone;
  String employeeName;
  dynamic employeeManagerPhone;
  dynamic employeeManagerName;
  dynamic employeeManagerEmail;
  String employeeJoiningDate;
  String employeeId;
  String employeeGender;
  String employeeEmail;
  String employeeDob;
  String employeeDesignation;
  String employeeDepartment;
  String employeeCode;
  String? employeeAnniversaryDate;
  String employeeAddress;*/

  String? employeePhone;
  String? employeeName;
  String? employeeManagerPhone;
  String? employeeManagerName;
  String? employeeManagerEmail;
  String? employeeJoiningDate;
  String? employeeId;
  String? employeeGender;
  String? employeeEmail;
  String? employeeDob;
  String? employeeDesignation;
  String? employeeDepartment;
  String? employeeCode;
  String? employeeAnniversaryDate;
  String? employeeAddress;

  LstemployeeDetail({
    required this.employeePhone,
    required this.employeeName,
    required this.employeeManagerPhone,
    required this.employeeManagerName,
    required this.employeeManagerEmail,
    required this.employeeJoiningDate,
    required this.employeeId,
    required this.employeeGender,
    required this.employeeEmail,
    required this.employeeDob,
    required this.employeeDesignation,
    required this.employeeDepartment,
    required this.employeeCode,
    this.employeeAnniversaryDate,
    required this.employeeAddress,
  });

  /*factory LstemployeeDetail.fromJson(Map<String, dynamic> json) => LstemployeeDetail(
    employeePhone: json["employeePhone"],
    employeeName: json["employeeName"],
    employeeManagerPhone: json["employeeManagerPhone"],
    employeeManagerName: json["employeeManagerName"],
    employeeManagerEmail: json["employeeManagerEmail"],
    employeeJoiningDate: json["employeeJoiningDate"],
    employeeId: json["employeeID"],
    employeeGender: json["employeeGender"],
    employeeEmail: json["employeeEmail"],
    employeeDob: json["employeeDOB"],
    employeeDesignation: json["employeeDesignation"],
    employeeDepartment: json["employeeDepartment"],
    employeeCode: json["employeeCode"],
    employeeAnniversaryDate: json["employeeAnniversaryDate"],
    employeeAddress: json["employeeAddress"],
  );*/

  factory LstemployeeDetail.fromJson(Map<String, dynamic> json) => LstemployeeDetail(
    employeePhone: json["employeePhone"] ?? '',
    employeeName: json["employeeName"] ?? '',
    employeeManagerPhone: json["employeeManagerPhone"],
    employeeManagerName: json["employeeManagerName"],
    employeeManagerEmail: json["employeeManagerEmail"],
    employeeJoiningDate: json["employeeJoiningDate"] ?? '',
    employeeId: json["employeeID"] ?? '',
    employeeGender: json["employeeGender"] ?? '',
    employeeEmail: json["employeeEmail"] ?? '',
    employeeDob: json["employeeDOB"] ?? '',
    employeeDesignation: json["employeeDesignation"] ?? '',
    employeeDepartment: json["employeeDepartment"] ?? '',
    employeeCode: json["employeeCode"] ?? '',
    employeeAnniversaryDate: json["employeeAnniversaryDate"],
    employeeAddress: json["employeeAddress"],
  );


  Map<String, dynamic> toJson() => {
    "employeePhone": employeePhone,
    "employeeName": employeeName,
    "employeeManagerPhone": employeeManagerPhone,
    "employeeManagerName": employeeManagerName,
    "employeeManagerEmail": employeeManagerEmail,
    "employeeJoiningDate": employeeJoiningDate,
    "employeeID": employeeId,
    "employeeGender": employeeGender,
    "employeeEmail": employeeEmail,
    "employeeDOB": employeeDob,
    "employeeDesignation": employeeDesignation,
    "employeeDepartment": employeeDepartment,
    "employeeCode": employeeCode,
    "employeeAnniversaryDate": employeeAnniversaryDate,
    "employeeAddress": employeeAddress,
  };
}
