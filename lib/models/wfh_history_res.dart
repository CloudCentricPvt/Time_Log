
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

WfhHistoryResponse wfhHistoryResponseFromJson(String str) => WfhHistoryResponse.fromJson(json.decode(str));

String wfhHistoryResponseToJson(WfhHistoryResponse data) => json.encode(data.toJson());

Future<dynamic> getWFHHistory(BuildContext context) async {
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");

  try {
    var response =
    await apiNetwork.getRequest("${KApiEndPoints.wfhHistory}?employeeId=$empID",context);
    print("GET_URL_WFH_HISTORY: ${KApiEndPoints.wfhHistory}?=$empID");

    if (response != null && response['status'] == true) {
      WfhHistoryResponse wfhHistoryResponse =
      WfhHistoryResponse.fromJson(response);
      return wfhHistoryResponse;
    } else {

      return []; // or throw an exception / show an error
    }
  } catch (e) {
    print("Error in get WFH  history list: $e");
    return []; // or rethrow if you want to handle it higher up
  }
}

class WfhHistoryResponse {
  bool? status;
  String? message;
  Data? data;
  int? code;
  String? apiVersion;
  String? apiUrl;

  WfhHistoryResponse({
    this.status,
    this.message,
    this.data,
    this.code,
    this.apiVersion,
    this.apiUrl,
  });

  factory WfhHistoryResponse.fromJson(Map<String, dynamic> json) => WfhHistoryResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] != null ? Data.fromJson(json["data"]) : null,
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
  List<WFHRequest>? lstWFHRequests;

  Data({this.lstWFHRequests});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    lstWFHRequests: json["lstWFHRequests"] == null
        ? []
        : List<WFHRequest>.from(
        json["lstWFHRequests"].map((x) => WFHRequest.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "lstWFHRequests":
    lstWFHRequests?.map((x) => x.toJson()).toList(),
  };
}

class WFHRequest {
  String? wfhId;
  String? status;
  String? startDate;
  String? requestType;
  String? requestName;
  String? remarks;
  double? numberOfDays;
  String? endDate;
  String? description;
  String? approvedBy;
  String? approvalTimestamp;

  WFHRequest({
    this.wfhId,
    this.status,
    this.startDate,
    this.requestType,
    this.requestName,
    this.remarks,
    this.numberOfDays,
    this.endDate,
    this.description,
    this.approvedBy,
    this.approvalTimestamp,
  });

  factory WFHRequest.fromJson(Map<String, dynamic> json) => WFHRequest(
    wfhId: json["wfhId"],
    status: json["status"],
    startDate: json["startDate"],
    requestType: json["requestType"],
    requestName: json["requestName"],
    remarks: json["remarks"],
    numberOfDays: (json["numberOfDays"] as num?)?.toDouble(),
    endDate: json["endDate"],
    description: json["description"],
    approvedBy: json["approvedBy"],
    approvalTimestamp: json["approvalTimestamp"],
  );

  Map<String, dynamic> toJson() => {
    "wfhId": wfhId,
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

class WfhFilters {
  String? quickFilter;
  String? statusFilter;
  DateTime? fromDate;
  DateTime? toDate;
  String? project;
  String? task;

  WfhFilters({
    this.quickFilter,
    this.statusFilter,
    this.fromDate,
    this.toDate,
    this.project,
    this.task,
  });
}




