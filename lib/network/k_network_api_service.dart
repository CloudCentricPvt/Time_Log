import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as https;
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/utils/constants/k_storage_key.dart';
import '../utils/constants/k_colors.dart';
import '../utils/popups/k_material_dialog.dart';
import '../utils/toasts/k_snack_bar_events.dart';
import 'k_base_api_service.dart';


class KNetworkApiServices extends KBaseApiServices {

  final localStorage = GetStorage();
  bool _isNoInternetDialogShowing = false;
  bool isSessionExpiredHandled = false;

  @override
  Future<dynamic> getRequest(String url, BuildContext context) async {

    var auth = localStorage.read("Access_token") ?? "";
    var userId = localStorage.read("User_Id") ?? "";
    log("API Url: $url");
    log("UserId: $userId");
    log("AuthToken: $auth");

    final headers = {
      "Content-Type": "application/json",
      'auth_token': auth.toString(),
      'user_code': userId.toString(),
      'Authorization': 'Bearer $auth',
    };

    dynamic responseJson;

    try {
      final response = await https.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      responseJson = returnApiResponse(response, context);


    } on TimeoutException {
      KSnackBarEvents.errorSnackBar(
          title: "Oops", message: "Request timeout");
      return;
    } catch (e) {
      log("Catch On Get API: $e");
      return;
    }

    return responseJson;
  }

  @override
  Future<dynamic> postRequest(var data, String url, BuildContext context) async {
    final localStorage = GetStorage();
    var token = localStorage.read("Access_token") ?? "";
    var userId = localStorage.read("User_Id") ?? "";

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    log("Token: $token");
    log("API_URL : $url");
    log("Payload : $data");

    try {
      final response = await https
          .post(
          Uri.parse(url),
          body: jsonEncode(data),
          headers: headers
      )
          .timeout(const Duration(seconds: 10));

      log("GetAPIStatusCode : ${response.statusCode}");
      log("GetAPIResponse : ${response.body}");

      // Parse the response
      dynamic responseJson;
      try {
        if (response.body.isNotEmpty) {
          responseJson = jsonDecode(response.body);
        } else {
          responseJson = {'success': true, 'message': 'Request successful'};
        }
      } catch (e) {
        log("Error parsing JSON: $e");
        responseJson = {'success': true, 'message': 'Request successful'};
      }

      // Handle different status codes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseJson;
      } else {
        // For error responses, return the error JSON
        return responseJson ?? {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } on SocketException {
      log("SocketException: No internet connection");
      throw Exception('No internet connection found');
    } on TimeoutException {
      log("TimeoutException: Request timeout");
      throw Exception('Request timeout - Please try again');
    } catch (e) {
      log("CatchError : $e");
      throw Exception('Error occurred: ${e.toString()}');
    }
  }

  @override
  Future<dynamic> putRequest(var data, String url, BuildContext context) async {
    final localStorage = GetStorage();
    var token = localStorage.read("Access_token") ?? "";
    var userId = localStorage.read("User_Id") ?? "";
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    log("Token: $token");
    log("API_URL : $url");
    log("Payload : $data");

    dynamic responseJson;
    try {
      final response = await https
          .put(Uri.parse(url), body: jsonEncode(data), headers: headers)
          .timeout(const Duration(seconds: 10));
      responseJson = returnApiResponse(response, context);
    } on SocketException {
      throw KSnackBarEvents.errorSnackBar(title: "Opps", message: "No internet found");
    } on TimeoutException {
      throw KSnackBarEvents.errorSnackBar(title: "Opps", message: "Request timeout");
    } catch (e) {
      log("CatchError : $e");
      throw KSnackBarEvents.errorSnackBar(title: "Error occurred network service", message: e.toString());
    }
    return responseJson;
  }

  @override
  Future<Map<String, dynamic>> httpPost(var data, String url, BuildContext context) async {
    final localStorage = GetStorage();
    var auth = localStorage.read("Auth_Token") ?? "";
    var userId = localStorage.read("User_Id") ?? "";
    final headers = {
      'Authorization': 'Bearer $auth',
    };
    // log("User_Id: $userId");
    // log("Auth_Token: $auth");
    // log("API_URL : $url");
    // log("Payload : $data");
    // log("Header : $headers");
    Map<String, dynamic> responseJson;
    try {
      final response = await https
          .post(Uri.parse(url), body: data, headers: headers)
          .timeout(const Duration(seconds: 10));
      responseJson = returnApiResponse(response, context);
    } on SocketException {
      throw KSnackBarEvents.errorSnackBar(
          title: "Opps", message: "No internet found");
    } on TimeoutException {
      throw KSnackBarEvents.errorSnackBar(
          title: "Opps", message: "Request timeout");
    } catch (e) {
      throw KSnackBarEvents.errorSnackBar(
          title: "Error occurred network service", message: e.toString());
    }
    return responseJson;
  }

  dynamic returnApiResponse(https.Response response, BuildContext context) {
    log("GetAPIStatusCode : ${response.statusCode}");
    log("GetAPIResponse : ${response.body}");
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;

      case 401:
        if (!isSessionExpiredHandled) {
          isSessionExpiredHandled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            KMaterialDialogs.sessionTimeOut(
              context,
              TextButton(
                onPressed: () {
                  isSessionExpiredHandled = false;
                  localStorage.remove("Auth_Token");

                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }

                  if (!context.mounted) return;

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login_screen',
                        (route) => false,
                  );
                },
                child: const Text("OK", style: TextStyle(color: Colors.red,fontFamily: 'Poppins')),
              ),
              "Session Expired",
              "Your session has expired. Please login again.",
            );
          });
        }
        break;
      case 400:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 404:
        return KSnackBarEvents.errorSnackBar(
            title: "Opps",
            message: "Something went wrong, please try again later.");
      default:
        throw KSnackBarEvents.errorSnackBar(
            title: "Opps",
            message: "Something went wrong, please try again later.");
    }
  }
}
