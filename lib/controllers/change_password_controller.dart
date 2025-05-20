import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';
import '../utils/toasts/k_show_info.dart';

class ChangePasswordController{

  final KNetworkApiServices networkApiServices = KNetworkApiServices();
  final storage = GetStorage();


  final TextEditingController currentPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();




  Future<void>changePassword(BuildContext context,String? currentPass,String? newPass,String? confirmPass) async {

    if (currentPassController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter current password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (newPassController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please new password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (confirmPassController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter confirm password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    ///--- API call


    var changPassPayload = {
      "Username": storage.read('User_Id'),
      "current_pass": currentPass,
      "new_pass": newPass,
      "con_pass": confirmPass,
    };
    print("#PAYLOAD_CHANG_PASS: $changPassPayload");

    try{
      var response = await networkApiServices.postRequest(changPassPayload, KApiEndPoints.changPassWord,context);
      if (response != null) {
        // Check for success
        if (response['code'] == 204) {
          KShowInfo.showSuccessMessage(context, response['message']);
          Navigator.pop(context, true);
        } else {
          KShowInfo.showInfoMessage(context, response['message']);
        }
      } else {
        KShowInfo.showInfoMessage(context, response['message']);
      }

    }catch(e){

      KShowInfo.showInfoMessage(context, "An error occurred: $e");

    }
  }
}