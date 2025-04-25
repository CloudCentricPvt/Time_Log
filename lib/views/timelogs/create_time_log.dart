import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_date_dialog.dart';
import 'package:time_log/utils/constants/k_loader.dart';
import 'package:time_log/utils/reusable_widgit/k_dropdown.dart';
import 'package:time_log/utils/reusable_widgit/k_info_card.dart';
import 'package:time_log/utils/reusable_widgit/k_size_box.dart';
import 'package:time_log/utils/toasts/k_show_info.dart';
import '../../controllers/time_log_controller.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import '../../utils/reusable_widgit/k_elevated_button.dart';
import '../../utils/reusable_widgit/k_textinputform_field.dart';

class CreateTimeLog extends StatefulWidget {
  const CreateTimeLog({super.key});

  @override
  State<CreateTimeLog> createState() => _CreateTimelogState();
}

class _CreateTimelogState extends State<CreateTimeLog> {

  final TimeLogController _controller =  TimeLogController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key for validation
  String? _selectDate;
  String? selectedProject;
  String? selectedTask;
  bool _isLoading = false;
  double lat = 0.000;
  double long = 0.000;


  final List<String> projectItems = [
    "Leave/Holiday (April 2024 - March 2025)",
    "Self Study (April 2024 - March 2025)",
    "UI/UX Designing FY 24-25"
  ];

  final List<String> taskItems = [
    "UI/ux CloudCentric",
    "Uux FieldBan",
     "ui/ux CloudConics",
     "UI/ux SocialPols",
     "ui/ux Desers",
     "Other"
  ];


  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: KCustomAppBar(
          screenTitle: 'Create Time Log',
          showHistory: false,
          onHistoryTap: () {
            Navigator.pushNamed(context, '/leave_history_screen');
          },
        ),
      ),
      body: Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: KInfoCard(
                      children: [
                        Column(
                          children: [
                            /// --- Design for select project list
                            KSizedBox.h20,
                            KDropdownField(
                              value: _controller.selectedProject,
                              onChanged: (value) {
                                setState(() {
                                  _controller.selectedProject = value;
                                });
                              },
                              title: 'Project',
                              hint: 'Select Project',
                              leaveTypes: projectItems,
                              isRequired: true,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              dropdownIconType: DropdownIconType.chevronDown,
                            ),

                            /// --- Design for select task list
                            KSizedBox.h20,
                            KDropdownField(
                              value: _controller.selectedTask,
                              onChanged: (value){
                                setState(() {
                                  _controller.selectedTask = value;
                                });
                              },
                              title: 'Task',
                              hint: 'Select Task',
                              leaveTypes: taskItems,
                              isRequired: true,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              dropdownIconType: DropdownIconType.chevronDown,
                            ),

                            /// --- Design for select Hours and Minutes
                            KSizedBox.h20,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: KTextInputFormField(
                                    labelText: 'Hours',
                                    hintText: '00',
                                    isRequired: true,
                                    controller: _controller.hrsController,
                                  ),
                                ),
                                const SizedBox(width: 10), // Add spacing between fields
                                Expanded(
                                  child: KTextInputFormField(
                                    labelText: 'Minutes',
                                    hintText: '00',
                                    isRequired: true,
                                    controller: _controller.minController,
                                  ),
                                ),
                              ],
                            ),

                            /// --- Design for select date
                            KSizedBox.h20,
                            KTextInputFormField(
                              labelText: 'Date',
                              hintText: 'Select date',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              isRequired: true,
                              controller: _controller.dateController,
                              keyboardType: TextInputType.text,
                              onChange: (value) {
                                _controller.dateController.text = value!;
                                return null;
                              },
                              readOnly: true,
                              prefixIcon: null,
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  String? selectedDate =
                                      await KDateDialog.futureDate(
                                          context: context);
                                  if (selectedDate != null) {
                                    setState(() {
                                      _controller.dateController.text = selectedDate;
                                    });
                                  }
                                },
                                icon: SvgPicture.asset(KAssets.calenderIcon),
                              ),
                            ),

                            /// --- Design for Time Log description
                            KSizedBox.h20,
                            KTextInputFormField(
                              labelText: 'Description',
                              hintText: 'Enter description here..',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              controller: _controller.descriptionController,
                              useMaxLines: true,
                              isRequired: true,
                              maxLines: 3,
                              onChange: (value) {
                                _controller.descriptionController.text = value!;
                                return null;
                              },
                            ),
                            KSizedBox.h10,
                            GestureDetector(
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    KAssets.voiceIcon,
                                  ),
                                  KSizedBox.w10,
                                  const Text(
                                    'Check to Add Description vai Speak',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: KColors.textColor),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                /*await _requestPermission(); // Ensure mic permission is granted
                                _showSpeakUpDialog(); // Show dialog
                                Future.delayed(Duration(milliseconds: 500), () {
                                  // Delay to allow UI update
                                  _startListening(); // Start speech recognition after dialog is shown
                                });*/
                              },
                            ),
                            KSizedBox.h10,
                          ],
                        )
                      ],
                    ),
                  ),

                  KSizedBox.h20,
                  Center(
                    child: _isLoading ? const KLoader(): CustomElevatedButton(
                      text: 'Apply',
                      onPressed: () async {
                        if(_controller.selectedProject!.isEmpty && _controller.selectedTask!.isEmpty){
                          KShowInfo.showErrorMessage(context, "Please select Project and Task.");
                          print("PROJECT:is jbjsjdbjsd",);

                        }else{
                          setState(() {
                            _isLoading = true;
                          });

                          await _controller.applyTimeLog(context,_controller.selectedTask!,_controller.selectedTask!,_controller.dateController.text,_controller.hrsController.text,_controller.minController.text,_controller.descriptionController.text);

                          // If not successful, stop loader
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _getUserLocation() async {
    Location location = Location();
    bool _serviceEnable;
    PermissionStatus _permissionGranted;
    _serviceEnable = await location.serviceEnabled();
    if(!_serviceEnable){
      _serviceEnable = await  location.requestService();
      if(!_serviceEnable){
        normalConfirmationDialog('Location is Disable App want to access  your location','Please Enable your Location','Enable Location');
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await location.requestPermission();

      if(_permissionGranted != PermissionStatus.granted){
        normalConfirmationDialog('Denied the location permission, please go to setting and give access','Location permission denied','Open Setting');
        print('Location_Service:');
        return;
      }
    }
    location.onLocationChanged.listen((LocationData CurrentLocation) async {
      
      print('Location: ${CurrentLocation.latitude},${CurrentLocation.longitude}');
      setState(() {
        lat = CurrentLocation.latitude!;
        long = CurrentLocation.longitude!;

        print('#Location:${CurrentLocation.latitude}');
      });

    });
  }
  normalConfirmationDialog(String confirmation, String? title, String? buttonText){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('data')

          ],
        ),
      );

    });

  }
}
