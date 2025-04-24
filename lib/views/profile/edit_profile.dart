import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/controllers/edit_profile_controller.dart';
import 'package:time_log/utils/constants/k_colors.dart';
import 'package:time_log/utils/constants/k_date_dialog.dart';
import 'package:time_log/utils/reusable_widgit/k_custom_app_bar.dart';
import 'package:time_log/utils/reusable_widgit/k_elevated_button.dart';
import 'package:time_log/utils/reusable_widgit/k_size_box.dart';
import 'package:time_log/utils/reusable_widgit/k_textinputform_field.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final EditProfileController _editProfileController = EditProfileController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: const KCustomAppBar(screenTitle: 'Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Align(alignment:Alignment.centerLeft, child: Text('Personal Details',style: TextStyle(color: KColors.textHeadingColor,fontWeight: FontWeight.bold,fontSize: 16),)),
              KSizedBox.h10,
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: KColors.appColorWhite,borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    KTextInputFormField(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      controller: _editProfileController.fullNameController,
                      keyboardType: TextInputType.text,
                      onChange: (value) {
                        _editProfileController.fullNameController.text = value!;
                        return null;
                      },
                      readOnly: false,
                      prefixIcon: null,
                    ),

                    KSizedBox.h14,
                    KTextInputFormField(
                      labelText: 'Gender',
                      hintText: 'Enter Gender name',
                      controller: _editProfileController.genderController,
                      keyboardType: TextInputType.text,
                      onChange: (value) {
                        _editProfileController.genderController.text = value!;
                        return null;
                      },
                      readOnly: false,
                      prefixIcon: null,
                    ),

                    KSizedBox.h14,
                    KTextInputFormField(
                      labelText: 'Phone',
                      hintText: 'Enter Mobile Number',
                      controller: _editProfileController.phoneController,
                      keyboardType: TextInputType.text,
                      onChange: (value) {
                        _editProfileController.phoneController.text = value!;
                        return null;
                      },
                      readOnly: false,
                      prefixIcon: null,
                    ),

                    KSizedBox.h14,
                    KTextInputFormField(
                      labelText: 'Email',
                      hintText: 'Enter Email',
                      controller: _editProfileController.emailController,
                      keyboardType: TextInputType.text,
                      onChange: (value) {
                        _editProfileController.emailController.text = value!;
                        return null;
                      },
                      readOnly: false,
                      prefixIcon: null,
                    ),

                    KSizedBox.h14,
                    KTextInputFormField(
                      labelText: 'Date of Birth',
                      hintText: 'Enter Date of Birth',
                      controller: _editProfileController.dobController,
                      keyboardType: TextInputType.text,
                      onChange: (value) {
                        _editProfileController.dobController.text = value!;
                        return null;
                      },
                      readOnly: false,
                      prefixIcon: null,
                    ),

                    KSizedBox.h14,
                    KTextInputFormField(
                      labelText: 'Select Anniversary',
                      hintText: 'Anniversary Date',
                      controller: _editProfileController.anniversaryController,
                      keyboardType: TextInputType.text,
                      onChange: (value) {
                        _editProfileController.anniversaryController.text = value!;
                        return null;
                      },
                      readOnly: true,
                      prefixIcon:  null,
                      suffixIcon: IconButton(onPressed: () async {
                        String? selectedDate = await KDateDialog.selectDate(context: context);
                        if (selectedDate != null) {
                          setState(() {
                            _editProfileController.anniversaryController.text = selectedDate;
                          });
                        }
                      }, icon:SvgPicture.asset(
                          'assets/icons/calandar_icon.svg'),),
                    ),

                    KSizedBox.h14,
                    KTextInputFormField(
                      labelText: 'Mailing Address',
                      hintText: 'Enter address',
                      useMaxLines: true,
                      useMaxLength: true,
                      maxLines: 3,
                      maxLength: 500,
                      controller: _editProfileController.mailingAddressController,
                      keyboardType: TextInputType.text,
                      onChange: (value) {
                        _editProfileController.mailingAddressController.text = value!;
                        return null;
                      },
                      readOnly: false,
                      prefixIcon: null,
                    ),
                  ],),
                ),
              ),
              KSizedBox.h20,
              CustomElevatedButton(
                width: 260,
                height: 45,
                text: 'UPDATE PROFILE',
                onPressed: () async {
                  await _editProfileController.editProfile(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
