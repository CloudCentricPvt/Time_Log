import 'dart:convert';

CreateExpensePayload createExpenseReqFromJson(String str) => CreateExpensePayload.fromJson(json.decode(str));

String createExpenseReqToJson(CreateExpensePayload data) => json.encode(data.toJson());

class CreateExpensePayload {
  // Employee Information
  String? employeeId;
  String? userName;

  // Expense Details
  String? expenseType;
  double? expenseAmount;
  String? description;
  String? expenseDate;

  // Payment Information
  String? modeOfPayment;

  // Related Object
  String? relatedObject;
  String? relatedRecordId;

  // Related Records
  String? accountId;
  String? projectId;
  String? monthlyExpenseId;

  // Receipt Information
  bool? hasReceipt;
  String? receiptLostReason;
  String? fileName;
  String? fileData;

  // Travel Details
  String? modeOfTravel;
  String? fromCity;
  String? toCity;
  double? odometerIn;
  double? odometerOut;
  double? distanceTravelled;

  // Additional Fields
  String? approvalStatus;
  String? expenseCategory;
  String? currencyIsoCode;

  CreateExpensePayload({
    this.employeeId,
    this.userName,
    this.expenseType,
    this.expenseAmount,
    this.description,
    this.expenseDate,
    this.modeOfPayment,
    this.relatedObject,
    this.relatedRecordId,
    this.accountId,
    this.projectId,
    this.monthlyExpenseId,
    this.hasReceipt,
    this.receiptLostReason,
    this.fileName,
    this.fileData,
    this.modeOfTravel,
    this.fromCity,
    this.toCity,
    this.odometerIn,
    this.odometerOut,
    this.distanceTravelled,
    this.approvalStatus,
    this.expenseCategory,
    this.currencyIsoCode,
  });

  factory CreateExpensePayload.fromJson(Map<String, dynamic> json) => CreateExpensePayload(
    employeeId: json["employeeId"],
    userName: json["userName"],
    expenseType: json["expenseType"],
    expenseAmount: (json["expenseAmount"] as num?)?.toDouble(),
    description: json["description"],
    expenseDate: json["expenseDate"],
    modeOfPayment: json["modeOfPayment"],
    relatedObject: json["relatedObject"],
    relatedRecordId: json["relatedRecordId"],
    accountId: json["accountId"],
    projectId: json["projectId"],
    monthlyExpenseId: json["monthlyExpenseId"],
    hasReceipt: json["hasReceipt"],
    receiptLostReason: json["receiptLostReason"],
    fileName: json["fileName"],
    fileData: json["fileData"],
    modeOfTravel: json["modeOfTravel"],
    fromCity: json["fromCity"],
    toCity: json["toCity"],
    odometerIn: (json["odometerIn"] as num?)?.toDouble(),
    odometerOut: (json["odometerOut"] as num?)?.toDouble(),
    distanceTravelled: (json["distanceTravelled"] as num?)?.toDouble(),
    approvalStatus: json["approvalStatus"],
    expenseCategory: json["expenseCategory"],
    currencyIsoCode: json["currencyIsoCode"],
  );

  Map<String, dynamic> toJson() => {
    "employeeId": employeeId,
    "userName": userName,
    "expenseType": expenseType,
    "expenseAmount": expenseAmount,
    "description": description,
    "expenseDate": expenseDate,
    "modeOfPayment": modeOfPayment,
    "relatedObject": relatedObject,
    "relatedRecordId": relatedRecordId,
    "accountId": accountId,
    "projectId": projectId,
    "monthlyExpenseId": monthlyExpenseId,
    "hasReceipt": hasReceipt,
    "receiptLostReason": receiptLostReason,
    "fileName": fileName,
    "fileData": fileData,
    "modeOfTravel": modeOfTravel,
    "fromCity": fromCity,
    "toCity": toCity,
    "odometerIn": odometerIn,
    "odometerOut": odometerOut,
    "distanceTravelled": distanceTravelled,
    "approvalStatus": approvalStatus,
    "expenseCategory": expenseCategory,
    "currencyIsoCode": currencyIsoCode,
  };

  // Helper method to remove null and empty values
  Map<String, dynamic> toJsonWithNonNull() {
    final map = {
      "employeeId": employeeId,
      "userName": userName,
      "expenseType": expenseType,
      "expenseAmount": expenseAmount,
      "description": description,
      "expenseDate": expenseDate,
      "modeOfPayment": modeOfPayment,
      "relatedObject": relatedObject,
      "relatedRecordId": relatedRecordId,
      "accountId": accountId,
      "projectId": projectId,
      "monthlyExpenseId": monthlyExpenseId,
      "hasReceipt": hasReceipt,
      "receiptLostReason": receiptLostReason,
      "fileName": fileName,
      "fileData": fileData,
      "modeOfTravel": modeOfTravel,
      "fromCity": fromCity,
      "toCity": toCity,
      "odometerIn": odometerIn,
      "odometerOut": odometerOut,
      "distanceTravelled": distanceTravelled,
      "approvalStatus": approvalStatus,
      "expenseCategory": expenseCategory,
      "currencyIsoCode": currencyIsoCode,
    };

    // Remove null values AND empty strings
    map.removeWhere((key, value) =>
    value == null ||
        (value is String && value.isEmpty) ||
        (value is double && value == 0.0)
    );

    return map;
  }
}