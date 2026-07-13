import 'dart:convert';

ExpenseListResponse expenseListResponseFromJson(String str) =>
    ExpenseListResponse.fromJson(json.decode(str));

class ExpenseListResponse {
  bool? status;
  String? message;
  List<MonthlyExpenseGroup>? data;
  int? code;

  ExpenseListResponse({this.status, this.message, this.data, this.code});

  factory ExpenseListResponse.fromJson(Map<String, dynamic> json) =>
      ExpenseListResponse(
        status: json["status"],
        message: json["message"],
        code: json["code"],
        data: json["data"] == null
            ? []
            : List<MonthlyExpenseGroup>.from(
                json["data"].map((x) => MonthlyExpenseGroup.fromJson(x))),
      );
}

class MonthlyExpenseGroup {
  String? year;
  String? month;
  String? status;
  String? monthlyExpenseName;
  String? monthlyExpenseId;
  String? employeeName;
  String? employeeId;
  List<ExpenseModel>? expenses;

  MonthlyExpenseGroup({
    this.year,
    this.month,
    this.status,
    this.monthlyExpenseName,
    this.monthlyExpenseId,
    this.employeeName,
    this.employeeId,
    this.expenses,
  });

  factory MonthlyExpenseGroup.fromJson(Map<String, dynamic> json) =>
      MonthlyExpenseGroup(
        year: json["year"],
        month: json["month"],
        status: json["status"],
        monthlyExpenseName: json["monthlyExpenseName"],
        monthlyExpenseId: json["monthlyExpenseId"],
        employeeName: json["employeeName"],
        employeeId: json["employeeId"],
        expenses: json["expenses"] == null
            ? []
            : List<ExpenseModel>.from(
                json["expenses"].map((x) => ExpenseModel.fromJson(x))),
      );
}

class ExpenseModel {
  String? expenseId;
  String? expenseName;
  String? expenseType;
  double? expenseAmount;
  String? formattedDate;
  String? description;
  String? modeOfPayment;
  String? modeOfTravel;
  String? fromCity;
  String? toCity;
  bool? hasReceipt;
  String? fileName;
  String? employeeId;
  double? odometerIn;
  double? odometerOut;
  double? distanceTravelled;

  ExpenseModel({
    this.expenseId,
    this.expenseName,
    this.expenseType,
    this.expenseAmount,
    this.formattedDate,
    this.description,
    this.modeOfPayment,
    this.modeOfTravel,
    this.fromCity,
    this.toCity,
    this.hasReceipt,
    this.fileName,
    this.employeeId,
    this.odometerIn,
    this.odometerOut,
    this.distanceTravelled,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        expenseId: json["expenseId"],
        expenseName: json["expenseName"],
        expenseType: json["expenseType"],
        expenseAmount: (json["expenseAmount"] as num?)?.toDouble(),
        formattedDate: json["formattedDate"],
        description: json["description"],
        modeOfPayment: json["modeOfPayment"],
        modeOfTravel: json["modeOfTravel"],
        fromCity: json["fromCity"],
        toCity: json["toCity"],
        hasReceipt: json["hasReceipt"],
        fileName: json["fileName"],
        employeeId: json["employeeId"],
        odometerIn: (json["odometerIn"] as num?)?.toDouble(),
        odometerOut: (json["odometerOut"] as num?)?.toDouble(),
        distanceTravelled: (json["distanceTravelled"] as num?)?.toDouble(),
      );
}
