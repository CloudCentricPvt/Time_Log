import 'package:flutter/material.dart';

class EditProfileController{

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController anniversaryController = TextEditingController();
  final TextEditingController mailingAddressController = TextEditingController();

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);

  }

}