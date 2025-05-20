// To parse this JSON data, do
//
//     final assignTaskResponse = assignTaskResponseFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

AssignTaskResponse assignTaskResponseFromJson(String str) => AssignTaskResponse.fromJson(json.decode(str));

String assignTaskResponseToJson(AssignTaskResponse data) => json.encode(data.toJson());

Future<dynamic> assignTaskFormSF(BuildContext context) async{
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");
  try{
    var response = await apiNetwork.getRequest(KApiEndPoints.getAssignTask,context);
    if(response!=null && response['status']== true){
      AssignTaskResponse assignTaskResponse = AssignTaskResponse.fromJson(response);
      print('Project_TASK:$assignTaskResponse');
      return assignTaskResponse;

    }else{

      return [];
    }

  }catch(e){
    print("Error in assignProject: $e");
    return [];
  }
}



class AssignTaskResponse {
  List<String> taskTypes;
  bool status;
  String message;
  int code;
  String apiVersion;
  String apiUrl;

  AssignTaskResponse({
    required this.taskTypes,
    required this.status,
    required this.message,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory AssignTaskResponse.fromJson(Map<String, dynamic> json) => AssignTaskResponse(
    taskTypes: List<String>.from(json["taskTypes"].map((x) => x)),
    status: json["status"],
    message: json["message"],
    code: json["code"],
    apiVersion: json["api_version"],
    apiUrl: json["api_url"],
  );

  Map<String, dynamic> toJson() => {
    "taskTypes": List<dynamic>.from(taskTypes.map((x) => x)),
    "status": status,
    "message": message,
    "code": code,
    "api_version": apiVersion,
    "api_url": apiUrl,
  };
}
