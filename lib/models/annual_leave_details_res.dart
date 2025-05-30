
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

AnnualLeaveDetailsResponse annualLeaveDetailsResponseFromJson(String str) => AnnualLeaveDetailsResponse.fromJson(json.decode(str));

String annualLeaveDetailsResponseToJson(AnnualLeaveDetailsResponse data) => json.encode(data.toJson());

Future<dynamic> getAnnualLeaveDetails(BuildContext context) async {
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");

  /// --- call API
  try{
    var response = await apiNetwork.getRequest("${KApiEndPoints.getAnnualLeaveDetails}?employeeId=$empID",context);
    print("GET_URL_leave_details: ${KApiEndPoints.getAnnualLeaveDetails}?employeeId=$empID");
    print("GET_URL_leave_details_RES_COD: ${response['code']}");
    print("Check_Res: ${response['leaveDetails']}");

    if (response != null && response['status'] == true) {
      print('Check_Res:"Success"');
      try {
        AnnualLeaveDetailsResponse annualLeaveDetailsResponse = AnnualLeaveDetailsResponse.fromJson(response);
        return annualLeaveDetailsResponse;
      } catch (e) {
        print('Error in fromJson: $e');
      }
    } else {
      print('Check_Res:"failed else block"');
      return [];
    }
  }catch(e){
    print("Error in getAllTimeLog: $e");
  }
}

class AnnualLeaveDetailsResponse {
  LeaveBal data;
  bool status;
  String message;
  int code;
  String apiVersion;
  String apiUrl;

  AnnualLeaveDetailsResponse({
    required this.data,
    required this.status,
    required this.message,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory AnnualLeaveDetailsResponse.fromJson(Map<String, dynamic> json) => AnnualLeaveDetailsResponse(
    data: LeaveBal.fromJson(json["data"]),
    status: json["status"],
    message: json["message"],
    code: json["code"],
    apiVersion: json["api_version"],
    apiUrl: json["api_url"],
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "status": status,
    "message": message,
    "code": code,
    "api_version": apiVersion,
    "api_url": apiUrl,
  };
}

class LeaveBal {
  double leaveBalance;
  double totalLeave;
  double totalCasualLeave;
  double totalSickLeave;
  double totalCompOffLeave;
  double totalElLeave;
  int usedLeave;
  double casualLeaveBal;
  double sickLeaveBal;
  double compOffLeaveBal;
  double elLeaveBal;
  double lwpAvailed;
  String calendarYear;

  LeaveBal({
    required this.leaveBalance,
    required this.totalLeave,
    required this.totalCasualLeave,
    required this.totalSickLeave,
    required this.totalCompOffLeave,
    required this.totalElLeave,
    required this.usedLeave,
    required this.casualLeaveBal,
    required this.sickLeaveBal,
    required this.compOffLeaveBal,
    required this.elLeaveBal,
    required this.lwpAvailed,
    required this.calendarYear,
  });

  factory LeaveBal.fromJson(Map<String, dynamic> json) => LeaveBal(
    leaveBalance: json["leaveBalance"],
    totalLeave: json["totalLeave"],
    totalCasualLeave: json["totalCasualLeave"],
    totalSickLeave: json["totalSickLeave"],
    totalCompOffLeave: json["totalCompOffLeave"],
    totalElLeave: json["totalElLeave"],
    usedLeave: json["usedLeave"],
    casualLeaveBal: json["casualLeaveBal"],
    sickLeaveBal: json["sickLeaveBal"],
    compOffLeaveBal: json["compOffLeaveBal"],
    elLeaveBal: json["elLeaveBal"],
    lwpAvailed: json["lwpAvailed"],
    calendarYear: json["calendarYear"],
  );

  Map<String, dynamic> toJson() => {
    "leaveBalance": leaveBalance,
    "totalLeave": totalLeave,
    "totalCasualLeave": totalCasualLeave,
    "totalSickLeave": totalSickLeave,
    "totalCompOffLeave": totalCompOffLeave,
    "totalElLeave": totalElLeave,
    "usedLeave": usedLeave,
    "casualLeaveBal": casualLeaveBal,
    "sickLeaveBal": sickLeaveBal,
    "compOffLeaveBal": compOffLeaveBal,
    "elLeaveBal": elLeaveBal,
    "lwpAvailed": lwpAvailed,
    "calendarYear": calendarYear,
  };
}
