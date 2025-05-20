

import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/utils/toasts/k_snack_bar_events.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

AllTimeLogResponse allTimeLogResponseFromJson(String str) => AllTimeLogResponse.fromJson(json.decode(str));

String allTimeLogResponseToJson(AllTimeLogResponse data) => json.encode(data.toJson());


Future<dynamic> getAllTimeLog(BuildContext context) async {
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");

  try {
    var response =
    await apiNetwork.getRequest("${KApiEndPoints.allTimeLogs}?employeeId=$empID",context);
    print("GET_URL: ${KApiEndPoints.allTimeLogs}?=$empID");

    if (response != null && response['status'] == true) {
      AllTimeLogResponse allTimeLogResponse =
      AllTimeLogResponse.fromJson(response);
      return allTimeLogResponse;
    } else {

      return []; // or throw an exception / show an error
    }
  } catch (e) {
    print("Error in getAllTimeLog: $e");
    return []; // or rethrow if you want to handle it higher up
  }
}

class AllTimeLogResponse {
  bool? status;
  String? message;
  Data? data;
  int? code;
  String? apiVersion;
  String? apiUrl;

  AllTimeLogResponse({
    this.status,
    this.message,
    this.data,
    this.code,
    this.apiVersion,
    this.apiUrl,
  });

  factory AllTimeLogResponse.fromJson(Map<String, dynamic> json) => AllTimeLogResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    code: json["code"],
    apiVersion: json["api_version"],
    apiUrl: json["api_url"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
    "code": code,
    "api_version": apiVersion,
    "api_url": apiUrl,
  };
}

class Data {
  double? totalMonthlyHours;
  int? rejectedCount;
  int? pendingCount;
  List<LstTimeLog>? lstTimeLogs;

  Data({
    this.totalMonthlyHours,
    this.rejectedCount,
    this.pendingCount,
    this.lstTimeLogs,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalMonthlyHours: json["totalMonthlyHours"]?.toDouble(),
    rejectedCount: json["rejectedCount"],
    pendingCount: json["pendingCount"],
    lstTimeLogs: json["lstTimeLogs"] == null ? [] : List<LstTimeLog>.from(json["lstTimeLogs"]!.map((x) => LstTimeLog.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "totalMonthlyHours": totalMonthlyHours,
    "rejectedCount": rejectedCount,
    "pendingCount": pendingCount,
    "lstTimeLogs": lstTimeLogs == null ? [] : List<dynamic>.from(lstTimeLogs!.map((x) => x.toJson())),
  };
}

class LstTimeLog {
  String? timelogId;
  String? projectId;
  String? taskName;
  String? status;
  String? projectName;
  int? minutes;
  int? hours;
  String? formattedDate;
  String? description;

  LstTimeLog({
    this.timelogId,
    this.projectId,
    this.taskName,
    this.status,
    this.projectName,
    this.minutes,
    this.hours,
    this.formattedDate,
    this.description,
  });

  factory LstTimeLog.fromJson(Map<String, dynamic> json) => LstTimeLog(
    timelogId:json["timelogId"],
    projectId:json["projectId"],
    taskName: json["taskName"],
    status: json["status"],
    projectName: json["projectName"],
    minutes: json["minutes"],
    hours: json["hours"],
    formattedDate: json["formattedDate"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "timelogId":timelogId,
    "projectId":timelogId,
    "taskName": taskName,
    "status": status,
    "projectName": projectName,
    "minutes": minutes,
    "hours": hours,
    "formattedDate": formattedDate,
    "description": description,
  };
}
