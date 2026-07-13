import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/models/create_expense_req.dart';
import 'package:time_log/models/expense_list_res.dart';
import 'package:time_log/network/k_network_api_service.dart';
import 'package:time_log/utils/constants/api_container.dart';

class ExpenseController {
  final KNetworkApiServices _networkApiService = KNetworkApiServices();
  final storage = GetStorage();

  Future<ExpenseListResponse?> getExpenses(BuildContext context, String month, String year) async {
    try {
      var empID = storage.read("EMP_ID");
      String url = "${KApiEndPoints.getExpenses}?month=$month&year=$year&employeeId=$empID";
      print("GET EXPENSES URL: $url");
      print("EMP_ID: $empID");

      var response = await _networkApiService.getRequest(url, context);
      print("GET EXPENSES RESPONSE: $response");

      if (response != null) {
        bool isSuccess = response['status'] == true ||
            response['status'] == 200 ||
            response['status'].toString().toLowerCase() == 'true';

        if (isSuccess) {
          return ExpenseListResponse.fromJson(response);
        } else {
          print("Expense API error: ${response['message']}");
        }
      } else {
        print("GET EXPENSES: null response received");
      }
      return null;
    } catch (e) {
      print("Error fetching expenses: $e");
      return null;
    }
  }

  Future<bool> createExpense(BuildContext context, CreateExpenseReq payload) async {
    try {
      var response = await _networkApiService.postRequest(
        payload.toJson(), 
        KApiEndPoints.createExpense, 
        context
      );
      
      if (response != null && response is Map<String, dynamic> && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Expense created successfully'), backgroundColor: Colors.green),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response?['message'] ?? 'Failed to create expense'), backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      print("Error creating expense: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred'), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  Future<bool> updateExpense(BuildContext context, Map<String, dynamic> payload) async {
    try {
      var response = await _networkApiService.putRequest(
        payload, 
        KApiEndPoints.updateExpense, 
        context
      );
      
      if (response != null && response is Map<String, dynamic> && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Expense updated successfully'), backgroundColor: Colors.green),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response?['message'] ?? 'Failed to update expense'), backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      print("Error updating expense: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred'), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  Future<bool> submitExpenseApproval(
      BuildContext context, String monthlyExpenseId, String comments) async {
    try {
      var payload = {
        "monthlyExpenseId": monthlyExpenseId,
        "comments": comments,
      };
      print("SUBMIT APPROVAL PAYLOAD: $payload");

      var response = await _networkApiService.postRequest(
        payload,
        KApiEndPoints.submitExpenseApproval,
        context,
      );

      if (response != null) {
        bool isSuccess = response['status'] == true ||
            response['status'] == 200 ||
            response['status'].toString().toLowerCase() == 'true';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ??
                (isSuccess ? 'Submitted for approval' : 'Submission failed')),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
        return isSuccess;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No response from server'),
              backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      print("Error submitting approval: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red),
      );
      return false;
    }
  }
}
