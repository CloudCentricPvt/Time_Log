// To parse this JSON data, do
//
//     final compOffHistoryResponse = compOffHistoryResponseFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

CompOffHistoryResponse compOffHistoryResponseFromJson(String str) => CompOffHistoryResponse.fromJson(json.decode(str));

String compOffHistoryResponseToJson(CompOffHistoryResponse data) => json.encode(data.toJson());

Future<dynamic> getCompOffHistory(BuildContext context) async {
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");

  try {
    var response =
    await apiNetwork.getRequest("${KApiEndPoints.getCompOff}?employeeId=$empID",context);
    print("GET_URL_Comm_Off_HISTORY: ${KApiEndPoints.getCompOff}?=$empID");

    if (response != null && response['status'] == true) {
      CompOffHistoryResponse compOffHistoryResponse =
      CompOffHistoryResponse.fromJson(response);
      return compOffHistoryResponse;
    } else {

      return []; // or throw an exception / show an error
    }
  } catch (e) {
    print("Error in getAllCompOff Records: $e");
    return []; // or rethrow if you want to handle it higher up
  }
}

class CompOffHistoryResponse {
  bool status;
  String message;
  List<CompOff> data;
  int code;
  String apiVersion;
  String apiUrl;

  CompOffHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory CompOffHistoryResponse.fromJson(Map<String, dynamic> json) => CompOffHistoryResponse(
    status: json["status"],
    message: json["message"],
    data: List<CompOff>.from(json["data"].map((x) => CompOff.fromJson(x))),
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

class CompOff {
  String status;
  String startDate;
  String requestType;
  String requestName;
  dynamic remarks;
  double numberOfDays;
  String endDate;
  String description;
  dynamic approvedBy;
  dynamic approvalTimestamp;

  CompOff({
    required this.status,
    required this.startDate,
    required this.requestType,
    required this.requestName,
    required this.remarks,
    required this.numberOfDays,
    required this.endDate,
    required this.description,
    required this.approvedBy,
    required this.approvalTimestamp,
  });

  factory CompOff.fromJson(Map<String, dynamic> json) => CompOff(
    status: json["status"],
    startDate: json["startDate"],
    requestType: json["requestType"],
    requestName: json["requestName"],
    remarks: json["remarks"],
    numberOfDays: json["numberOfDays"],
    endDate: json["endDate"],
    description: json["description"],
    approvedBy: json["approvedBy"],
    approvalTimestamp: json["approvalTimestamp"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "startDate": startDate,
    "requestType": requestType,
    "requestName": requestName,
    "remarks": remarks,
    "numberOfDays": numberOfDays,
    "endDate": endDate,
    "description": description,
    "approvedBy": approvedBy,
    "approvalTimestamp": approvalTimestamp,
  };
}
