

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/utils/constants/api_container.dart';

import '../network/k_network_api_service.dart';

PrivacyPolicyResponse privacyPolicyResponseFromJson(String str) => PrivacyPolicyResponse.fromJson(json.decode(str));

String privacyPolicyResponseToJson(PrivacyPolicyResponse data) => json.encode(data.toJson());

Future<dynamic> privacyPolicy(BuildContext context)async{
  var apiNetwork = KNetworkApiServices();
  final storage = GetStorage();
  var empID = storage.read("EMP_ID");
  try{
    var response = await apiNetwork.getRequest(KApiEndPoints.privacyPolicyPDF,context);
    print("GET_URL_Privacy: ${KApiEndPoints.privacyPolicyPDF}");

    if(response!=null && response['status']==true){
      print('PRIVACY_SUCCESS:$response');
      PrivacyPolicyResponse policyResponse = PrivacyPolicyResponse.fromJson(response);
      return policyResponse;
    }else{
      return [];
    }

  }catch(e){
    print("Error in getAllTimeLog: $e");
    return []; // or rethrow if you want to handle it higher up
  }

}

class PrivacyPolicyResponse {
  bool status;
  int code;
  String message;
  String apiUrl;
  String apiVersion;
  List<Policy> policy;

  PrivacyPolicyResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.apiUrl,
    required this.apiVersion,
    required this.policy,
  });

  factory PrivacyPolicyResponse.fromJson(Map<String, dynamic> json) => PrivacyPolicyResponse(
    status: json["status"],
    code: json["code"],
    message: json["message"],
    apiUrl: json["api_url"],
    apiVersion: json["api_version"],
    policy: List<Policy>.from(json["policy"].map((x) => Policy.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "code": code,
    "message": message,
    "api_url": apiUrl,
    "api_version": apiVersion,
    "policy": List<dynamic>.from(policy.map((x) => x.toJson())),
  };
}

class Policy {
  String policyUrl;

  Policy({
    required this.policyUrl,
  });

  factory Policy.fromJson(Map<String, dynamic> json) => Policy(
    policyUrl: json["policyUrl"],
  );

  Map<String, dynamic> toJson() => {
    "policyUrl": policyUrl,
  };
}
