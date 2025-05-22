
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

AppliedLeaveHistoryResponse appliedLeaveHistoryResponseFromJson(String str) => AppliedLeaveHistoryResponse.fromJson(json.decode(str));

String appliedLeaveHistoryResponseToJson(AppliedLeaveHistoryResponse data) => json.encode(data.toJson());

Future<dynamic> getAllAppliedLeave(BuildContext context) async{
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");

  try {
    var response =
    await apiNetwork.getRequest("${KApiEndPoints.getAppliedLeave}?employeeId=$empID",context);
    print("GET_URL_Comm_Off_HISTORY: ${KApiEndPoints.getAppliedLeave}?=$empID");

    if (response != null && response['status'] == true) {
      AppliedLeaveHistoryResponse appliedLeaveHistoryResponse =
      AppliedLeaveHistoryResponse.fromJson(response);
      return appliedLeaveHistoryResponse;
    } else {

      return []; // or throw an exception / show an error
    }
  } catch (e) {
    print("Error in getAllAppliedLeave Records: $e");
    return []; // or rethrow if you want to handle it higher up
  }
}

/*Future<dynamic> getAllAppliedLeave(BuildContext context, int page, int pageSize) async {
  final apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  final empID = storage.read("EMP_ID");

  if (empID == null) {
    print("EMP_ID is null");
    return []; // or show a toast/snackbar
  }

  final url = "${KApiEndPoints.getAppliedLeave}?employeeId=$empID";
  print("GET_URL_Comm_Off_HISTORY: $url");

  try {
    final response = await apiNetwork.getRequest(url, context);

    if (response != null && response['status'] == true) {
      final appliedLeaveHistoryResponse = AppliedLeaveHistoryResponse.fromJson(response);
      return appliedLeaveHistoryResponse;
    } else {
      print("API returned unsuccessful status or null data");
      return []; // Consider returning a default response model instead
    }
  } catch (e, stacktrace) {
    print("Error in getAllAppliedLeave: $e");
    print("StackTrace: $stacktrace");
    return []; // or throw Exception("API error")
  }
}*/

class AppliedLeaveHistoryResponse {
  bool status;
  String message;
  List<AppliedLeaveHistory> data;
  int code;
  String apiVersion;
  String apiUrl;

  AppliedLeaveHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory AppliedLeaveHistoryResponse.fromJson(Map<String, dynamic> json) => AppliedLeaveHistoryResponse(
    status: json["status"],
    message: json["message"],
    data: List<AppliedLeaveHistory>.from(json["data"].map((x) => AppliedLeaveHistory.fromJson(x))),
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

class AppliedLeaveHistory {
  String type;
  String status;
  String startDate;
  dynamic remarks;
  double numberOfDays;
  String leaveId;
  String endDate;
  String? description;

  AppliedLeaveHistory({
    required this.type,
    required this.status,
    required this.startDate,
    required this.remarks,
    required this.numberOfDays,
    required this.leaveId,
    required this.endDate,
    required this.description,
  });

  factory AppliedLeaveHistory.fromJson(Map<String, dynamic> json) => AppliedLeaveHistory(
    type: json["type"]!,
    status: json["status"]!,
    startDate: json["startDate"],
    remarks: json["remarks"],
    numberOfDays: json["numberOfDays"],
    leaveId: json["leaveId"],
    endDate: json["endDate"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "type": typeValues.reverse[type],
    "status": statusValues.reverse[status],
    "startDate": startDate,
    "remarks": remarks,
    "numberOfDays": numberOfDays,
    "leaveId": leaveId,
    "endDate": endDate,
    "description": description,
  };
}

enum Status {
  APPROVED,
  PENDING
}

final statusValues = EnumValues({
  "Approved": Status.APPROVED,
  "Pending": Status.PENDING
});

enum Type {
  CL,
  EL,
  SL
}

final typeValues = EnumValues({
  "CL": Type.CL,
  "EL": Type.EL,
  "SL": Type.SL
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
