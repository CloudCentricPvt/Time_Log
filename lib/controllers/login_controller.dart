
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/models/login_res.dart';

import '../network/auth_service.dart';
import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';

class LoginController {
  final KNetworkApiServices networkApiServices = KNetworkApiServices();
  final AuthService authService = AuthService(); // Instance of AuthService

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordPassController = TextEditingController();
  
  final storage = GetStorage();

  Future<LoginResponse?> login(BuildContext context, String username, String password) async {
    if (userNameController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter user name"),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    if (passwordPassController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter password"),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    /// --- Step 1: Get OAuth Token
    String? token = await authService.fetchToken();
    if (token == null) {
      showErrorMessage(context, "Failed to get authentication token.");
      return null;
    }

    /// --- call Login API
    var loginPayload = {
      'Username': username,
      'Password': password,
    };

    print("PAYLOAD: $loginPayload");


    try {
      var response = await networkApiServices.postRequest(loginPayload, KApiEndPoints.login);
          print("RESPONSE: $response");

      if (response != null) {
        // Check for success
        if (response['code'] == 200 && response['status'] == true) {
          var user = response['users']?[0];
          String userName = user?['User_Name__c'] ?? '';
          bool isActive = user?['Is_Active__c'] ?? false;
          await storage.write('Is_Active', isActive);
          String employeeID = user?['Id'].toString() ?? '';

          storage.write('User_Id', userName);
          storage.write('EMP_ID', employeeID);
          var ss = storage.read('Is_Active');
          print('#SSSSS: $ss');

          showSuccessMessage(context, response['message']?.toString() ?? 'No message');
          Navigator.pushReplacementNamed(context, '/home_screen');

        } else {
          // Show the API message when credentials are wrong or account inactive
          showErrorMessage(context, response['message'] ?? "Login failed");
        }
      } else {
        showSuccessMessage(context, response['message']?.toString() ?? 'No message');
        showErrorMessage(context, "No response from server.");
      }
    } catch (e) {
      showErrorMessage(context, "An error occurred: $e");
    }
  }




    void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

