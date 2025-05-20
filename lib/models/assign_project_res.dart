

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/network/k_network_api_service.dart';
import 'package:time_log/utils/constants/api_container.dart';

AssignProjectResponse assignProjectResponseFromJson(String str) => AssignProjectResponse.fromJson(json.decode(str));

String assignProjectResponseToJson(AssignProjectResponse data) => json.encode(data.toJson());

 Future<dynamic> assignProjectFormSF(BuildContext context) async{
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");
  try{
    var response = await apiNetwork.getRequest("${KApiEndPoints.getAssignProject}?employeeId=$empID",context);
    print("GET_URL_Assign_Project: ${KApiEndPoints.allTimeLogs}?=$empID");
    if(response!=null && response['status']== true){
      AssignProjectResponse assignProjectResponse = AssignProjectResponse.fromJson(response);
      print('Project:$assignProjectResponse');
      return assignProjectResponse;

    }else{

      return [];
    }
    
  }catch(e){
    print("Error in assignProject: $e");
    return [];
  }
}


class AssignProjectResponse {
  List<Lstproject> lstprojects;
  bool status;
  String message;
  int code;
  String apiVersion;
  String apiUrl;

  AssignProjectResponse({
    required this.lstprojects,
    required this.status,
    required this.message,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory AssignProjectResponse.fromJson(Map<String, dynamic> json) => AssignProjectResponse(
    lstprojects: List<Lstproject>.from(json["lstprojects"].map((x) => Lstproject.fromJson(x))),
    status: json["status"],
    message: json["message"],
    code: json["code"],
    apiVersion: json["api_version"],
    apiUrl: json["api_url"],
  );

  Map<String, dynamic> toJson() => {
    "lstprojects": List<dynamic>.from(lstprojects.map((x) => x.toJson())),
    "status": status,
    "message": message,
    "code": code,
    "api_version": apiVersion,
    "api_url": apiUrl,
  };
}

class Lstproject {
  String projectName;
  String projectId;

  Lstproject({
    required this.projectName,
    required this.projectId,
  });

  factory Lstproject.fromJson(Map<String, dynamic> json) => Lstproject(
    projectName: json["projectName"],
    projectId: json["projectId"],
  );

  Map<String, dynamic> toJson() => {
    "projectName": projectName,
    "projectId": projectId,
  };
}
