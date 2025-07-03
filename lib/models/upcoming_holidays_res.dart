

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/network/k_network_api_service.dart';
import 'package:time_log/utils/constants/api_container.dart';

UpcomingHolidaysResponse upcomingHolidaysResponseFromJson(String str) => UpcomingHolidaysResponse.fromJson(json.decode(str));

String upcomingHolidaysResponseToJson(UpcomingHolidaysResponse data) => json.encode(data.toJson());

Future<dynamic> getUpcomingHolidays(BuildContext context) async {
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");

  try {
    var response =
    await apiNetwork.getRequest(KApiEndPoints.getUpcomingHolidays,context);
    print("GET_URL_Upcoming Holidays: ${KApiEndPoints.getUpcomingHolidays}");

    if (response != null && response['status'] == true) {
      UpcomingHolidaysResponse upcomingHolidaysResponse =
      UpcomingHolidaysResponse.fromJson(response);
      return upcomingHolidaysResponse;
    } else {

      return []; // or throw an exception / show an error
    }
  } catch (e) {
    print("Error in getAllCompOff Records: $e");
    return []; // or rethrow if you want to handle it higher up
  }
}

class UpcomingHolidaysResponse {
  List<Holiday> holidays;
  bool status;
  String message;
  int code;
  String apiVersion;
  String apiUrl;

  UpcomingHolidaysResponse({
    required this.holidays,
    required this.status,
    required this.message,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory UpcomingHolidaysResponse.fromJson(Map<String, dynamic> json) => UpcomingHolidaysResponse(
    holidays: List<Holiday>.from(json["holidays"].map((x) => Holiday.fromJson(x))),
    status: json["status"],
    message: json["message"],
    code: json["code"],
    apiVersion: json["api_version"],
    apiUrl: json["api_url"],
  );

  Map<String, dynamic> toJson() => {
    "holidays": List<dynamic>.from(holidays.map((x) => x.toJson())),
    "status": status,
    "message": message,
    "code": code,
    "api_version": apiVersion,
    "api_url": apiUrl,
  };
}

class Holiday {
  String holidayTitle;
  dynamic holidayImage;
  String holidayDescription;
  DateTime holidayDate;
  String formattedDate;

  Holiday({
    required this.holidayTitle,
    required this.holidayImage,
    required this.holidayDescription,
    required this.holidayDate,
    required this.formattedDate,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) => Holiday(
    holidayTitle: json["holidayTitle"],
    holidayImage: json["holidayImage"],
    holidayDescription: json["holidayDescription"],
    holidayDate: DateTime.parse(json["holidayDate"]),
    formattedDate: json["formattedDate"],
  );

  Map<String, dynamic> toJson() => {
    "holidayTitle": holidayTitle,
    "holidayImage": holidayImage,
    "holidayDescription": holidayDescription,
    "holidayDate": "${holidayDate.year.toString().padLeft(4, '0')}-${holidayDate.month.toString().padLeft(2, '0')}-${holidayDate.day.toString().padLeft(2, '0')}",
    "formattedDate": formattedDate,
  };
}
