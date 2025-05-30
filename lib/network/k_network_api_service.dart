import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as https;
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import '../utils/constants/k_colors.dart';
import '../utils/popups/k_material_dialog.dart';
import '../utils/toasts/k_snack_bar_events.dart';
import 'k_base_api_service.dart';


class KNetworkApiServices extends KBaseApiServices {

  final localStorage = GetStorage();
  bool _isNoInternetDialogShowing = false;


  /* @override
  Future<dynamic> getRequest(String url) async {

    var auth = localStorage.read("Access_token")?? "";
    var userId = localStorage.read("User_Id")?? "";
    var empId = localStorage.read("EMP_ID")?? "";
    log("API Url: $url");
    log("UserId: $userId");
    log("AuthToken: $auth");
    final headers = {
      "Content-Type": "application/json",
      'auth_token': auth!.toString(),
      'user_code': userId!.toString(),
      'Authorization': 'Bearer $auth',
    };
    dynamic responseJson;
    try {
      final response = await https.get(
        Uri.parse(url.toString()),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      responseJson = returnApiResponse(response);
      if (responseJson['status'] == false && responseJson['code'] == 401) {
        return KMaterialDialogs.sessionTimeOut(
            Get.context!,
            IconsButton(
              onPressed: () {
                final localStorage = GetStorage();
                localStorage.erase();
                //Get.offAll(() => const OtpScreen());
                Get.offAll(() => const LoginScreen());
                //Navigator.pushReplacementNamed(context, '/login_screen');
              },
              text: 'Okay',
              color: Colors.red,
              textStyle: const TextStyle(color: Colors.white),
              iconColor: Colors.white,
            ),
            "Session time out!",
            "Your sessions has been expired, please do login again to continue.");
      }
    } on SocketException {
      throw KSnackBarEvents.errorSnackBar(title: "Opps", message: "No internet connectivity.");
    } on TimeoutException {
      throw KSnackBarEvents.errorSnackBar(
          title: "Opps", message: "Request timeout");
    } catch (e) {
      log("Catch On Get API");
      //throw KSnackBarEvents.errorSnackBar(title: "Opps", message: "Something went wrong");
    }
    return responseJson;
  }*/

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

    dynamic responseJson;
    try {
      final response = await https
          .post(Uri.parse(url), body: jsonEncode(data), headers: headers)
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
    log("User_Id: $userId");
    log("Auth_Token: $auth");
    log("API_URL : $url");
    log("Payload : $data");
    log("Header : $headers");
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
        KMaterialDialogs.sessionTimeOut(
          context,
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(color: KColors.appPrimaryRed),
            ),
          ),
          "Session Expired",
          "Your session has expired. Please login again.",
        );


        log("GetAPIStatusCode:401 : ${response.statusCode}");
        throw KSnackBarEvents.errorSnackBar(
            title: "Opps", message: "Invalid request");
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
