import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/utils/constants/k_loader.dart';

import '../../controllers/change_password_controller.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import '../../utils/reusable_widgit/k_elevated_button.dart';
import '../../utils/reusable_widgit/k_size_box.dart';
import '../../utils/reusable_widgit/k_textinputform_field.dart';


class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final ChangePasswordController _changePassProfileController = ChangePasswordController();
  bool _isCurrentPasswordObscure = true;
  bool _isNewPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: const KCustomAppBar(screenTitle: 'Update Password'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              KSizedBox.h20,
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Change Your Password',
                    style: TextStyle(
                        color: KColors.textHeadingColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  )),
              KSizedBox.h10,
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: KColors.appColorWhite,
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      KTextInputFormField(
                        labelText: 'Current Password',
                        hintText: 'Enter your current password',
                        obscureText: _isCurrentPasswordObscure,
                        controller:
                            _changePassProfileController.currentPassController,
                        keyboardType: TextInputType.text,
                        readOnly: false,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isCurrentPasswordObscure = !_isCurrentPasswordObscure;
                            });
                          },
                          icon: SvgPicture.asset(
                            _isCurrentPasswordObscure ? 'assets/icons/eye_with_line.svg' : 'assets/icons/eye_closed.svg',
                          ),
                        ),
                      ),
                      KSizedBox.h30,
                      KTextInputFormField(
                        labelText: 'New Password',
                        hintText: 'Enter new password',
                        obscureText: _isNewPasswordObscure,
                        controller:
                            _changePassProfileController.newPassController,
                        keyboardType: TextInputType.text,
                        readOnly: false,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isNewPasswordObscure = !_isNewPasswordObscure;// Toggle visibility
                            });
                          },
                          icon: SvgPicture.asset(
                            _isNewPasswordObscure ? 'assets/icons/eye_with_line.svg' : 'assets/icons/eye_closed.svg',
                          ),
                        ),
                      ),
                      KSizedBox.h30,
                      KTextInputFormField(
                        labelText: 'Confirm Password',
                        hintText: 'Enter confirm password',
                        obscureText: _isConfirmPasswordObscure,
                        controller:
                            _changePassProfileController.confirmPassController,
                        keyboardType: TextInputType.text,
                        readOnly: false,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordObscure = !_isConfirmPasswordObscure;// Toggle visibility// Toggle visibility
                            });
                          },
                          icon: SvgPicture.asset(
                            _isConfirmPasswordObscure ? 'assets/icons/eye_with_line.svg' : 'assets/icons/eye_closed.svg',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              KSizedBox.h20,
              Center(
                child: _isLoading ? const KLoader() : CustomElevatedButton(
                  width: 260,
                  height: 45,
                  text: 'UPDATE PASSWORD',
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await _changePassProfileController.changePassword(context,_changePassProfileController.currentPassController.text,_changePassProfileController.newPassController.text,_changePassProfileController.confirmPassController.text);
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
