

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

AnnualLeaveGraphResponse annualLeaveGraphResponseFromJson(String str) => AnnualLeaveGraphResponse.fromJson(json.decode(str));

String annualLeaveGraphResponseToJson(AnnualLeaveGraphResponse data) => json.encode(data.toJson());

Future<dynamic> getAnnualLeaveDetailsForGraph(BuildContext context) async {
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");

  /// --- call API
  try{
    var response = await apiNetwork.getRequest("${KApiEndPoints.getAnnualLeaveDetailsForGraph}?employeeId=$empID",context);

    if (response != null && response['status'] == true) {
      try {
        AnnualLeaveGraphResponse annualLeaveDetailsResponse = AnnualLeaveGraphResponse.fromJson(response);
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


class AnnualLeaveGraphResponse {
  bool status;
  String message;
  List<AnnualLeaveData> annualDataForGraph;
  int code;
  String apiVersion;
  String apiUrl;

  AnnualLeaveGraphResponse({
    required this.status,
    required this.message,
    required this.annualDataForGraph,
    required this.code,
    required this.apiVersion,
    required this.apiUrl,
  });

  factory AnnualLeaveGraphResponse.fromJson(Map<String, dynamic> json) =>
      AnnualLeaveGraphResponse(
        status: json["status"],
        message: json["message"],
        annualDataForGraph: List<AnnualLeaveData>.from(
            (json["lstLeaveData"] ?? []).map((x) => AnnualLeaveData.fromJson(x))),
        code: json["code"],
        apiVersion: json["api_version"],
        apiUrl: json["api_url"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "lstLeaveData": List<dynamic>.from(annualDataForGraph.map((x) => x.toJson())),
    "code": code,
    "api_version": apiVersion,
    "api_url": apiUrl,
  };
}

class AnnualLeaveData {
  String strMonthName;
  dynamic intWfhCount;
  dynamic intLeaveCount;
  dynamic intCumulativeLeaveCount;
  dynamic intCompOffCount;

  AnnualLeaveData({
    required this.strMonthName,
    required this.intWfhCount,
    required this.intLeaveCount,
    required this.intCumulativeLeaveCount,
    required this.intCompOffCount,
  });

  factory AnnualLeaveData.fromJson(Map<String, dynamic> json) => AnnualLeaveData(
    strMonthName: json["strMonthName"],
    intWfhCount: json["intWFHCount"],
    intLeaveCount: json["intLeaveCount"]?.toDouble(),
    intCumulativeLeaveCount: json["intCumulativeLeaveCount"]?.toDouble(),
    intCompOffCount: json["intCompOffCount"],
  );

  Map<String, dynamic> toJson() => {
    "strMonthName": strMonthName,
    "intWFHCount": intWfhCount,
    "intLeaveCount": intLeaveCount,
    "intCumulativeLeaveCount": intCumulativeLeaveCount,
    "intCompOffCount": intCompOffCount,
  };
}
