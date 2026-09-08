import 'dart:convert';

CreateExpenseReq createExpenseReqFromJson(String str) => CreateExpenseReq.fromJson(json.decode(str));

String createExpenseReqToJson(CreateExpenseReq data) => json.encode(data.toJson());

class CreateExpenseReq {
  List<ExpensePayload>? expenses;

  CreateExpenseReq({
    this.expenses,
  });

  factory CreateExpenseReq.fromJson(Map<String, dynamic> json) => CreateExpenseReq(
    expenses: json["expenses"] == null
        ? []
        : List<ExpensePayload>.from(
        json["expenses"].map((x) => ExpensePayload.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "expenses": expenses?.map((x) => x.toJson()).toList(),
  };
}

class ExpensePayload {
  String? employeeId;
  String? userName;
  String? date;
  String? expenseType;
  double? expenseAmount;
  String? description;
  String? modeOfPayment;
  String? relatedObject;
  String? relatedRecordId;
  bool? hasReceipt;
  String? receiptLostReason;
  String? modeOfTravel;
  String? fromCity;
  String? toCity;
  double? odometerIn;
  double? odometerOut;
  double? distanceTravelled;
  String? fileName;
  String? fileData;

  ExpensePayload({
    this.employeeId,
    this.userName,
    this.date,
    this.expenseType,
    this.expenseAmount,
    this.description,
    this.modeOfPayment,
    this.relatedObject,
    this.relatedRecordId,
    this.hasReceipt,
    this.receiptLostReason,
    this.modeOfTravel,
    this.fromCity,
    this.toCity,
    this.odometerIn,
    this.odometerOut,
    this.distanceTravelled,
    this.fileName,
    this.fileData,
  });

  factory ExpensePayload.fromJson(Map<String, dynamic> json) => ExpensePayload(
    employeeId: json["employeeId"],
    userName: json["userName"],
    date: json["date"],
    expenseType: json["expenseType"],
    expenseAmount: (json["expenseAmount"] as num?)?.toDouble(),
    description: json["description"],
    modeOfPayment: json["modeOfPayment"],
    relatedObject: json["relatedObject"],
    relatedRecordId: json["relatedRecordId"],
    hasReceipt: json["hasReceipt"],
    receiptLostReason: json["receiptLostReason"],
    modeOfTravel: json["modeOfTravel"],
    fromCity: json["fromCity"],
    toCity: json["toCity"],
    odometerIn: (json["odometerIn"] as num?)?.toDouble(),
    odometerOut: (json["odometerOut"] as num?)?.toDouble(),
    distanceTravelled: (json["distanceTravelled"] as num?)?.toDouble(),
    fileName: json["fileName"],
    fileData: json["fileData"],
  );

  Map<String, dynamic> toJson() => {
    "employeeId": employeeId,
    "userName": userName,
    "date": date,
    "expenseType": expenseType,
    "expenseAmount": expenseAmount,
    "description": description,
    "modeOfPayment": modeOfPayment,
    "relatedObject": relatedObject,
    "relatedRecordId": relatedRecordId,
    "hasReceipt": hasReceipt,
    "receiptLostReason": receiptLostReason,
    "modeOfTravel": modeOfTravel,
    "fromCity": fromCity,
    "toCity": toCity,
    "odometerIn": odometerIn,
    "odometerOut": odometerOut,
    "distanceTravelled": distanceTravelled,
    "fileName": fileName,
    "fileData": fileData,
  };
}
