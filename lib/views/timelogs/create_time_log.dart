import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:time_log/models/assign_task_res.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_date_dialog.dart';
import 'package:time_log/utils/constants/k_loader.dart';
import 'package:time_log/utils/reusable_widgit/k_dropdown.dart';
import 'package:time_log/utils/reusable_widgit/k_info_card.dart';
import 'package:time_log/utils/reusable_widgit/k_size_box.dart';
import '../../controllers/time_log_controller.dart';
import '../../models/assign_project_res.dart';
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
  stt.SpeechToText _speech = stt.SpeechToText();
  String _text = "";
  bool _isListening = false;
  final TimeLogController _controller =  TimeLogController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key for validation
  List<Lstproject> assignProject = [];
  List<String> assignTask = [];
  String? selectedProjectId;
  String? _selectDate;
  Lstproject? selectedProject;
  String? selectedTask;
  bool _isLoading = false;
  double lat = 0.000;
  double long = 0.000;

  @override
  void initState() {
    _controller.dateController.text =
        DateFormat("dd, MMMM yyyy").format(DateTime.now());
    fetchAssignProject();
    fetchAssignTask();
    _speech = stt.SpeechToText();
    super.initState();

  }
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Speech recognition status: $status");
        if (status == "notListening") {
          Navigator.pop(context); // Close dialog when speech stops
        }
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          print("Recognized words: ${result.recognizedWords}");
          setState(() {
            _text = result.recognizedWords;
            _controller.descriptionController.text =
                _text; // Update TextField
            _controller.descriptionController.selection =
                TextSelection.fromPosition(
                  TextPosition(
                      offset: _controller.descriptionController.text
                          .length), // Move cursor to the end
                );
          });
        },
      ).onError((error) {
        // Handle errors using `.onError`
        print("Speech recognition error: $error");
        setState(() => _isListening = false);
        Navigator.pop(context); // Close dialog
      } as FutureOr Function(Object error, StackTrace stackTrace));
    }
  }

  ///--- open dialog until the voice recording
  Future<void> _showSpeakUpDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent closing manually
      builder: (BuildContext context) {
        bool isListening = true; // Track listening state
        Timer? _timer;

        return StatefulBuilder(
          builder: (context, setState) {
            // Start animation timer
            _timer ??= Timer.periodic(Duration(milliseconds: 500), (timer) {
              setState(() {
                isListening = !isListening; // Toggle mic animation
              });
            });

            return AlertDialog(
              title: const Text('Please speak up'),
              icon: AnimatedSwitcher(
                duration: Duration(milliseconds: 600), // Smooth transition
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none, // Toggle icon
                  key: ValueKey<bool>(isListening), // Important for animation
                  color: Colors.red,
                  size: isListening ? 40 : 30, // Change size dynamically
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _speech.stop(); // Stop speech when dialog closes
    });
  }

  /// --- request permission for mice
  Future<void> _requestPermission() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      // Permission denied by the user
      print("Microphone permission denied");
    } else if (status.isPermanentlyDenied) {
      // Open app settings if the permission is permanently denied
      openAppSettings();
    }
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
                            _selectProject(),


                            /// --- Design for select task list
                            KSizedBox.h20,
                            _selectTask(),


                            /// --- Design for select Hours and Minutes
                            KSizedBox.h20,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: KTextInputFormField(
                                    labelText: 'Hours',
                                    hintText: '00',
                                    keyboardType: TextInputType.number,
                                    isRequired: true,
                                    controller: _controller.hrsController,
                                  ),
                                ),
                                const SizedBox(width: 10), // Add spacing between fields
                                Expanded(
                                  child: KTextInputFormField(
                                    labelText: 'Minutes',
                                    hintText: '00',
                                    keyboardType: TextInputType.number,
                                    isRequired: false,
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
                              isRequired: true,
                              controller: _controller.dateController,
                              readOnly: true,
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  String? selectedDateStr = await KDateDialog.selectDate(context: context);

                                  if (selectedDateStr != null) {
                                    setState(() {
                                      _controller.dateController.text = selectedDateStr;
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
                            /// --- text voice reorganisation
                            _performSpeakAndSetTextInTextField(),
                            KSizedBox.h10,
                          ],
                        )
                      ],
                    ),
                  ),

                  KSizedBox.h20,
                  Center(
                    child: _isLoading ? const KLoader(): CustomElevatedButton(
                      text: 'SUBMIT',
                      onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });

                          await _controller.applyTimeLog(context,selectedProjectId,selectedTask,_controller.dateController.text,_controller.hrsController.text,_controller.minController.text,_controller.descriptionController.text);

                          // If not successful, stop loader
                          setState(() {
                            _isLoading = false;
                          });

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

  Future<void> fetchAssignProject() async {
    final response = await assignProjectFormSF(context);
    if (mounted) {
      setState(() {
        assignProject = response.lstprojects ?? [];
        assignProject = List.from(assignProject); // initially show all
      });
    }
  }

  Future<void> fetchAssignTask() async {
    final response = await assignTaskFormSF(context);
    if (mounted && response is AssignTaskResponse) {
      setState(() {
        assignTask = response.taskTypes;
      });
    }
  }

  /// --- Select Assign Project
  Widget  _selectProject(){
    return Column(
      children: [
        KDropdownField<Lstproject>(
          value: selectedProject,
          onChanged: (value) {
            setState(() {
              selectedProject = value;
              selectedProjectId = selectedProject?.projectId;

            });
          },
          title: 'Project',
          hint: 'Select Project',
          leaveTypes: _isLoading ? [] : assignProject,
          getLabel: (project) => project.projectName,
          isRequired: true,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          dropdownIconType: DropdownIconType.chevronDown,
        ),
      ],
    );
  }

  /// --- Select Assign Task
  Widget  _selectTask(){
    return Column(
      children: [
        KDropdownField<String>(
        value: selectedTask,
        onChanged: (value) {
        setState(() {
        selectedTask = value;
        });
      },
       title: 'Task Type',
       hint:'Select Task',
       leaveTypes: _isLoading ? [] : assignTask,
       getLabel: (task) => task,
       isRequired: true, fontSize: 14,
       fontWeight: FontWeight.w400,
       dropdownIconType: DropdownIconType.chevronDown,
       ),
      ],
    );
  }

  /// --- Speak to something and set in the text field.
  Widget _performSpeakAndSetTextInTextField() {
    return GestureDetector(
      child: Row(
        children: [
          SvgPicture.asset(
            KAssets.voiceIcon,
          ),
          KSizedBox.w10,
          const Text(
            'Tap to add description by speaking.',
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                fontSize: 14,
                color: KColors.appPrimary),
          ),
        ],
      ),
      onTap: () async {
        await _requestPermission(); // Ensure mic permission is granted
        _showSpeakUpDialog(); // Show dialog
        Future.delayed(Duration(milliseconds: 500), () {
          // Delay to allow UI update
          _startListening(); // Start speech recognition after dialog is shown
        });
      },
    );
  }
}


