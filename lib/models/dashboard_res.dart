// To parse this JSON data, do
//
//     final dashboardResponse = dashboardResponseFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/models/upcoming_holidays_res.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

DashboardResponse dashboardResponseFromJson(String str) =>
    DashboardResponse.fromJson(json.decode(str));

String dashboardResponseToJson(DashboardResponse data) =>
    json.encode(data.toJson());

Future<dynamic> getDashboard(BuildContext context) async {
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");

  print("GET_URL_Dashboard: ${KApiEndPoints.getDashboardDetails}?=$empID");
  try {
    var response = await apiNetwork.getRequest("${KApiEndPoints.getDashboardDetails}?employeeId=$empID", context);
    print("GET_URL_Dashboard: ${KApiEndPoints.getDashboardDetails}?=$empID");

    if (response != null && response['status'] == true) {
      DashboardResponse dashboardResponse = DashboardResponse.fromJson(response);
      return dashboardResponse;
    } else {
      return []; // or throw an exception / show an error
    }
  } catch (e) {
    print("Error in get Dashboard details : $e");
    return []; // or rethrow if you want to handle it higher up
  }
}

class DashboardResponse {
  bool status;
  String message;
  Data data;
  int code;
  String apiVersion;
  String apiUrl;

  DashboardResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) =>
      DashboardResponse(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
        code: json["code"],
        apiVersion: json["api_version"],
        apiUrl: json["api_url"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
        "code": code,
        "api_version": apiVersion,
        "api_url": apiUrl,
      };
}

class Data {
  List<WorkingHourDetail> workingHourDetails;
  List<UpcomingLeaf> upcomingLeaves;
  String totalWorkingHrs;
  dynamic totalLeavesTaken;
  List<Event> todayEvents;
  String pendingTimeLogEntryCount;
  List<Holiday> holidays;
  List<Event> events;
  List<AnnualLeaveDetail> annualLeaveDetails;

  Data({
    required this.workingHourDetails,
    required this.upcomingLeaves,
    required this.totalWorkingHrs,
    required this.totalLeavesTaken,
    required this.todayEvents,
    required this.pendingTimeLogEntryCount,
    required this.holidays,
    required this.events,
    required this.annualLeaveDetails,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        workingHourDetails: List<WorkingHourDetail>.from(
            json["workingHourDetails"]
                .map((x) => WorkingHourDetail.fromJson(x))),
        upcomingLeaves: List<UpcomingLeaf>.from(
            json["upcomingLeaves"].map((x) => UpcomingLeaf.fromJson(x))),
        totalWorkingHrs: json["total_working_hrs"],
        totalLeavesTaken: json["total_leaves_taken"],
        todayEvents:
            List<Event>.from(json["todayEvents"].map((x) => Event.fromJson(x))),
        pendingTimeLogEntryCount: json["pending_time_log_entry_count"],
        //holidays: List<Holiday>.from(json["holidays"].map((x) => x)),
       holidays: List<Holiday>.from(json["holidays"].map((x) => Holiday.fromJson(x))),
        events: List<Event>.from(json["events"].map((x) => Event.fromJson(x))),
        annualLeaveDetails: List<AnnualLeaveDetail>.from(
            json["annualLeaveDetails"]
                .map((x) => AnnualLeaveDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "workingHourDetails":
            List<dynamic>.from(workingHourDetails.map((x) => x.toJson())),
        "upcomingLeaves":
            List<dynamic>.from(upcomingLeaves.map((x) => x.toJson())),
        "total_working_hrs": totalWorkingHrs,
        "total_leaves_taken": totalLeavesTaken,
        "todayEvents": List<dynamic>.from(todayEvents.map((x) => x.toJson())),
        "pending_time_log_entry_count": pendingTimeLogEntryCount,
        //"holidays": List<dynamic>.from(holidays.map((x) => x)),
        "holidays": List<dynamic>.from(holidays.map((x) => x.toJson())),
        "events": List<dynamic>.from(events.map((x) => x.toJson())),
        "annualLeaveDetails":
            List<dynamic>.from(annualLeaveDetails.map((x) => x.toJson())),
      };
}

class AnnualLeaveDetail {
  Attributes attributes;
  String id;
  dynamic totalLeaveC;
  dynamic totalClC;
  dynamic totalElC;
  dynamic totalSlC;
  dynamic totalCompOffLeaveC;
  String totalAvailedLeaveC;
  dynamic balancedClC;
  dynamic balancedCompOffC;
  dynamic balancedElC;
  dynamic balancedSlC;

  AnnualLeaveDetail({
    required this.attributes,
    required this.id,
    required this.totalLeaveC,
    required this.totalClC,
    required this.totalElC,
    required this.totalSlC,
    required this.totalCompOffLeaveC,
    required this.totalAvailedLeaveC,
    required this.balancedClC,
    required this.balancedCompOffC,
    required this.balancedElC,
    required this.balancedSlC
  });

  factory AnnualLeaveDetail.fromJson(Map<String, dynamic> json) =>
      AnnualLeaveDetail(
        attributes: Attributes.fromJson(json["attributes"]),
        id: json["Id"],
        totalLeaveC: json["Total_Leave__c"]?.toDouble(),
        totalClC: json["Total_CL__c"],
        totalElC: json["Total_EL__c"],
        totalSlC: json["Total_SL__c"]?.toDouble(),
        totalCompOffLeaveC: json["Total_Comp_Off_Leave__c"],
        totalAvailedLeaveC: json["Total_Availed_Leave__c"],
        balancedClC: json["Balanced_CL__c"],
        balancedCompOffC: json["Balanced_Comp_Off__c"],
        balancedElC: json["Balanced_EL__c"],
        balancedSlC: json["Balanced_SL__c"]?.toDouble()
      );

  Map<String, dynamic> toJson() => {
        "attributes": attributes.toJson(),
        "Id": id,
        "Total_Leave__c": totalLeaveC,
        "Total_CL__c": totalClC,
        "Total_EL__c": totalElC,
        "Total_SL__c": totalSlC,
        "Total_Comp_Off_Leave__c": totalCompOffLeaveC,
        "Total_Availed_Leave__c": totalAvailedLeaveC,
        "Balanced_CL__c": balancedClC,
        "Balanced_Comp_Off__c": balancedCompOffC,
        "Balanced_EL__c": balancedElC,
        "Balanced_SL__c": balancedSlC
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

class Event {
  int remainingDays;
  String personName;
  String eventName;
  String eventDescription;
  String eventDate;

  Event({
    required this.remainingDays,
    required this.personName,
    required this.eventName,
    required this.eventDescription,
    required this.eventDate,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        remainingDays: json["remainingDays"] ?? 0,
        personName: json["personName"],
        eventName: json["eventName"],
        eventDescription: json["eventDescription"] ?? '',
        eventDate: json["eventDate"],
      );

  Map<String, dynamic> toJson() => {
        "remainingDays": remainingDays,
        "personName": personName,
        "eventName": eventName,
        "eventDescription": eventDescription ?? '',
        "eventDate": eventDate,
      };
}

class UpcomingLeaf {
  String startDate;
  dynamic numberOfDays;
  String leaveType;
  String endDate;

  UpcomingLeaf({
    required this.startDate,
    required this.numberOfDays,
    required this.leaveType,
    required this.endDate,
  });

  factory UpcomingLeaf.fromJson(Map<String, dynamic> json) => UpcomingLeaf(
        startDate: json["startDate"],
        numberOfDays: json["numberOfDays"],
        leaveType: json["leaveType"],
        endDate: json["endDate"],
      );

  Map<String, dynamic> toJson() => {
        "startDate": startDate,
        "numberOfDays": numberOfDays,
        "leaveType": leaveType,
        "endDate": endDate,
      };
}

class WorkingHourDetail {
  String strMonthName;
  dynamic intHourCount;

  WorkingHourDetail({
    required this.strMonthName,
    required this.intHourCount,
  });

  factory WorkingHourDetail.fromJson(Map<String, dynamic> json) =>
      WorkingHourDetail(
        strMonthName: json["strMonthName"],
        intHourCount: json["intHourCount"],
      );

  Map<String, dynamic> toJson() => {
        "strMonthName": strMonthName,
        "intHourCount": intHourCount,
      };
}
