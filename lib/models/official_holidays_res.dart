
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/network/k_network_api_service.dart';
import 'package:time_log/utils/constants/api_container.dart';

OfficialHolidaysResponse officialHolidaysResponseFromJson(String str) => OfficialHolidaysResponse.fromJson(json.decode(str));

String officialHolidaysResponseToJson(OfficialHolidaysResponse data) => json.encode(data.toJson());

Future<dynamic> getOfficialHolidays(BuildContext context) async {
  var apiNetwork = KNetworkApiServices();
  var storage = GetStorage();
  var empID = storage.read("EMP_ID");
  try{
    var response = await apiNetwork.getRequest(KApiEndPoints.getOfficialHolidays,context);
    if(response != null && response['status'] == true){
      OfficialHolidaysResponse officialHolidaysResponse = OfficialHolidaysResponse.fromJson(response);
      print('Holidays_official:${officialHolidaysResponse.holidays}');
      return officialHolidaysResponse;


    }else{
      return [];
    }

  }catch(e){
    print("Error in get official holidays: $e");
    return [];
  }
}

class OfficialHolidaysResponse {
  List<OfficialHolidays> holidays;
  bool status;
  String message;
  int code;
  String apiVersion;
  String apiUrl;

  OfficialHolidaysResponse({
    required this.holidays,
    required this.status,
    required this.message,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory OfficialHolidaysResponse.fromJson(Map<String, dynamic> json) => OfficialHolidaysResponse(
    holidays: List<OfficialHolidays>.from(json["holidays"].map((x) => OfficialHolidays.fromJson(x))),
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

class OfficialHolidays {
  String holidayTitle;
  dynamic holidayImage;
  String? holidayDescription;
  DateTime holidayDate;
  String formattedDate;

  OfficialHolidays({
    required this.holidayTitle,
    required this.holidayImage,
    required this.holidayDescription,
    required this.holidayDate,
    required this.formattedDate,
  });

  factory OfficialHolidays.fromJson(Map<String, dynamic> json) => OfficialHolidays(
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
