
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

UpcomingLeavesResponse upcomingLeavesResponseFromJson(String str) => UpcomingLeavesResponse.fromJson(json.decode(str));

String upcomingLeavesResponseToJson(UpcomingLeavesResponse data) => json.encode(data.toJson());

Future<dynamic> getUpcomingLeaves(BuildContext context) async {
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");
  var ddd = "employeeId=$empID";

  try {
    var response =
    await apiNetwork.getRequest("${KApiEndPoints.getUpcomingAllLeave}?employeeId=$empID",context);
    print("GET_URL: ${KApiEndPoints.getUpcomingAllLeave}?=$empID");

    if (response != null && response['status'] == true) {
      UpcomingLeavesResponse allTimeLogResponse =
      UpcomingLeavesResponse.fromJson(response);
      return allTimeLogResponse;
    } else {

      return []; // or throw an exception / show an error
    }
  } catch (e) {
    print("Error in getAllTimeLog: $e");
    return []; // or rethrow if you want to handle it higher up
  }
}


class UpcomingLeavesResponse {
  bool status;
  String message;
  List<UpcomingLeave> data;
  int code;
  String apiVersion;
  String apiUrl;

  UpcomingLeavesResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory UpcomingLeavesResponse.fromJson(Map<String, dynamic> json) => UpcomingLeavesResponse(
    status: json["status"],
    message: json["message"],
    data: List<UpcomingLeave>.from(json["data"].map((x) => UpcomingLeave.fromJson(x))),
    code: json["code"],
    apiVersion: json["api_version"],
    apiUrl: json["api_url"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "code": code,
    "api_version": apiVersion,
    "api_url": apiUrl,
  };
}

class UpcomingLeave {
  String type;
  DateTime startDate;
  String month;

  UpcomingLeave({
    required this.type,
    required this.startDate,
    required this.month,
  });

  factory UpcomingLeave.fromJson(Map<String, dynamic> json) => UpcomingLeave(
    type: json["type"],
    startDate: DateTime.parse(json["startDate"]),
    month: json["month"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "startDate": "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
    "month": month,
  };
}
