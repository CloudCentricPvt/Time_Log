import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/utils/constants/k_date_and_time.dart';

import '../network/k_network_api_service.dart';
import '../utils/constants/api_container.dart';
import '../utils/toasts/k_show_info.dart';

class EditProfileController{

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController anniversaryController = TextEditingController();
  final TextEditingController mailingAddressController = TextEditingController();
  final storage = GetStorage();
  final KNetworkApiServices networkApiServices = KNetworkApiServices();

  Future<void>editProfile(BuildContext context) async {

    if (fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter full name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (genderController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter gender"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter mobile number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter email"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (dobController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Date of birth"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (anniversaryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please Anniversary Date."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (mailingAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter mailing address."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var editProfilePayload = {
      "employeeID": storage.read('EMP_ID'),
      "employeePhone": phoneController.text,
      "employeeAddress": mailingAddressController.text,
      "employeeAnniversaryDate": KDateAndTime().convertToStandardDateFormatYYYY_MM_DD(anniversaryController.text),
    };
    print("#Edit_ProfileLeavePayLoad: $editProfilePayload");

    try{
      var response = await networkApiServices.putRequest(editProfilePayload, KApiEndPoints.updateProfile,context);
      print("#Update_profile_RESPONSE: $response");

      if(response!=null){
        if(response['code'] == 200 && response['status'] == true){
          KShowInfo.showSuccessMessage(context, response['message']);
          print('Update_Profile:"success"');
          await Future.delayed(Duration(seconds: 1));
          if (context.mounted) {
            Navigator.pop(context, true);
          }

        }else{
          KShowInfo.showInfoMessage(context, response['message']);
          print('Update_Profile:"else_failed"');
        }
      }else{
        KShowInfo.showInfoMessage(context, response['message']);
        print('Update_Profile:"res_null"');
      }

    }catch(e){
      KShowInfo.showInfoMessage(context, "An error occurred: $e");
    }

  }

}