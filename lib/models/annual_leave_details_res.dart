
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

AnnualLeaveDetailsResponse annualLeaveDetailsResponseFromJson(String str) =>
    AnnualLeaveDetailsResponse.fromJson(json.decode(str));

String annualLeaveDetailsResponseToJson(AnnualLeaveDetailsResponse data) =>
    json.encode(data.toJson());

Future<AnnualLeaveDetailsResponse?> getAnnualLeaveDetails(BuildContext context) async {
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");

  try {
    var response = await apiNetwork.getRequest(
      "${KApiEndPoints.getAnnualLeaveDetails}?employeeId=$empID",
      context,
    );

    print("GET_URL_leave_details: ${KApiEndPoints.getAnnualLeaveDetails}?employeeId=$empID");
    print("GET_URL_leave_details_RES_CODE: ${response['code']}");
    print("Check_Res: ${response['leaveDetails']}");

    if (response != null && response['status'] == true) {
      try {
        AnnualLeaveDetailsResponse annualLeaveDetailsResponse =
        AnnualLeaveDetailsResponse.fromJson(response);
        print("✅ Leave details parsed successfully");
        return annualLeaveDetailsResponse;
      } catch (e) {
        print("❌ Error parsing JSON to model: $e");
        return null;
      }
    } else {
      print("⚠️ API returned failure status or empty response");
      return null;
    }
  } catch (e) {
    print("❌ Error in getAnnualLeaveDetails: $e");
    return null;
  }
}

class AnnualLeaveDetailsResponse {
  List<LeaveDetail> leaveDetails;
  bool status;
  String message;
  int code;
  String apiVersion;
  String apiUrl;

  AnnualLeaveDetailsResponse({
    required this.leaveDetails,
    required this.status,
    required this.message,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory AnnualLeaveDetailsResponse.fromJson(Map<String, dynamic> json) =>
      AnnualLeaveDetailsResponse(
        leaveDetails: List<LeaveDetail>.from(
            json["leaveDetails"].map((x) => LeaveDetail.fromJson(x))),
        status: json["status"],
        message: json["message"],
        code: json["code"],
        apiVersion: json["api_version"],
        apiUrl: json["api_url"],
      );

  Map<String, dynamic> toJson() => {
    "leaveDetails": List<dynamic>.from(leaveDetails.map((x) => x.toJson())),
    "status": status,
    "message": message,
    "code": code,
    "api_version": apiVersion,
    "api_url": apiUrl,
  };
}

class LeaveDetail {
  Attributes attributes;
  String id;
  double totalLeave;
  double totalCl;
  double totalEl;
  double totalSl;
  double totalCompOffLeave;
  String totalAvailedLeave;
  double balancedCl;
  double balancedCompOff;
  double balancedEl;
  double balancedSl;
  double availedLwp;
  double pendingLwp;
  String calendarYear;

  LeaveDetail({
    required this.attributes,
    required this.id,
    required this.totalLeave,
    required this.totalCl,
    required this.totalEl,
    required this.totalSl,
    required this.totalCompOffLeave,
    required this.totalAvailedLeave,
    required this.balancedCl,
    required this.balancedCompOff,
    required this.balancedEl,
    required this.balancedSl,
    required this.availedLwp,
    required this.pendingLwp,
    required this.calendarYear,
  });

  factory LeaveDetail.fromJson(Map<String, dynamic> json) => LeaveDetail(
    attributes: Attributes.fromJson(json["attributes"]),
    id: json["Id"],
    totalLeave: (json["Total_Leave__c"] ?? 0).toDouble(),
    totalCl: (json["Total_CL__c"] ?? 0).toDouble(),
    totalEl: (json["Total_EL__c"] ?? 0).toDouble(),
    totalSl: (json["Total_SL__c"] ?? 0).toDouble(),
    totalCompOffLeave: (json["Total_Comp_Off_Leave__c"] ?? 0).toDouble(),
    totalAvailedLeave: json["Total_Availed_Leave__c"] ?? "0",
    balancedCl: (json["Balanced_CL__c"] ?? 0).toDouble(),
    balancedCompOff: (json["Balanced_Comp_Off__c"] ?? 0).toDouble(),
    balancedEl: (json["Balanced_EL__c"] ?? 0).toDouble(),
    balancedSl: (json["Balanced_SL__c"] ?? 0).toDouble(),
    availedLwp: (json["Availed_LWP__c"] ?? 0).toDouble(),
    pendingLwp: (json["Pending_LWP__c"] ?? 0).toDouble(),
    calendarYear: json["Calendar_Year__c"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "attributes": attributes.toJson(),
    "Id": id,
    "Total_Leave__c": totalLeave,
    "Total_CL__c": totalCl,
    "Total_EL__c": totalEl,
    "Total_SL__c": totalSl,
    "Total_Comp_Off_Leave__c": totalCompOffLeave,
    "Total_Availed_Leave__c": totalAvailedLeave,
    "Balanced_CL__c": balancedCl,
    "Balanced_Comp_Off__c": balancedCompOff,
    "Balanced_EL__c": balancedEl,
    "Balanced_SL__c": balancedSl,
    "Availed_LWP__c": availedLwp,
    "Pending_LWP__c": pendingLwp,
    "Calendar_Year__c": calendarYear,
  };
}

class Attributes {
  String type;
  String url;

  Attributes({
    required this.type,
    required this.url,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
    type: json["type"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "url": url,
  };
}
