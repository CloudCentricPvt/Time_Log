import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _CreateTimelogState extends State<CreateTimeLog>
    with SingleTickerProviderStateMixin {
  stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  String _previousText = '';
  BuildContext? _bottomSheetContext;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final TimeLogController _controller = TimeLogController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Form key for validation
  List<Lstproject> assignProject = [];
  List<String> assignTask = [];
  String? selectedProjectId;
  String? _selectDate;
  Lstproject? selectedProject;
  String? selectedTask;
  bool _isLoading = false;
  double lat = 0.000;
  double long = 0.000;

  bool isProjectValid = true;
  String? projectErrorMessage;

  @override
  void initState() {
    _controller.dateController.text =
        DateFormat("dd, MMMM yyyy").format(DateTime.now());
    fetchAssignProject();
    fetchAssignTask();
    _speech = stt.SpeechToText();

    _animationController = AnimationController(
      vsync: this, // Now this will work
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.4).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addVoiceNote() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
          _animationController.stop();
          _speech.stop();

          if (_bottomSheetContext != null) {
            Navigator.of(_bottomSheetContext!).pop();
          }
        }
      },
      onError: (error) {
        print('Speech error: $error');
        setState(() => _isListening = false);
        _animationController.stop();

        if (_bottomSheetContext != null) {
          Navigator.of(_bottomSheetContext!).pop();
        }
      },
    );

    if (available) {
      // Save the existing text when starting the mic
      _previousText = _controller.descriptionController.text;

      setState(() => _isListening = true);
      _animationController.repeat(reverse: true);

      _showMicBottomSheet();

      _speech.listen(
        onResult: (result) {
          print('Recognized: ${result.recognizedWords}');
          setState(() {
            /// Combine previous text + current recognized words
            _controller.descriptionController.text =
                '$_previousText ${result.recognizedWords}'.trim();
            _controller.descriptionController.selection =
                TextSelection.fromPosition(
              TextPosition(
                  offset: _controller.descriptionController.text.length),
            );
          });
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  /// --- request permission for mice
  Future<void> _requestPermission() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      // Permission denied by the user
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
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF84DBFF), // Same as app bar
          statusBarIconBrightness:
              Brightness.dark, // or .light depending on contrast
        ),
        title: KCustomAppBar(
          screenTitle: 'Create Time Log',
          showHistory: false,
          onHistoryTap: () {
            Navigator.pushNamed(context, '/leave_history_screen');
          },
        ),
      ),
      backgroundColor: KColors.appBgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: KInfoCard(
                    children: [
                      Column(
                        spacing: 16.0,
                        children: [
                          /// --- Design for select project list
                          _selectProject(),

                          /// --- Design for select task list
                          _selectTask(),

                          /// --- Design for select Hours and Minutes
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
                                  maxLength: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                    MinuteRangeFormatter(),
                                    // Ensures value is between 1–59
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Add spacing between fields
                              Expanded(
                                child: KTextInputFormField(
                                  labelText: 'Minutes',
                                  hintText: '00',
                                  keyboardType: TextInputType.number,
                                  isRequired: true,
                                  controller: _controller.minController,
                                  maxLength: 2,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                    MinuteRangeFormatter(),
                                    // Ensures value is between 1–59
                                  ],
                                ),
                              ),
                            ],
                          ),

                          /// --- Design for select date
                          KTextInputFormField(
                            labelText: 'Date',
                            hintText: 'Select date',
                            isRequired: true,
                            controller: _controller.dateController,
                            readOnly: true,
                            suffixIcon: IconButton(
                              onPressed: () async {
                                String? selectedDateStr =
                                    await KDateDialog.selectDate(
                                        context: context);

                                if (selectedDateStr != null) {
                                  setState(() {
                                    _controller.dateController.text =
                                        selectedDateStr;
                                  });
                                }
                              },
                              icon: SvgPicture.asset(KAssets.calenderIcon),
                            ),
                          ),

                          /// --- Design for Time Log description
                          KTextInputFormField(
                            labelText: 'Description',
                            hintText: 'Enter description here..',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            controller: _controller.descriptionController,
                            useMaxLines: true,
                            isRequired: true,
                            useMaxLength: true,
                            maxLength: 32768,
                            maxLines: 10,

                            /* onChange: (value) {
                              _controller.descriptionController.text = value!;
                              return null;
                            },*/
                          ),

                          /// --- text voice reorganisation
                          _performSpeakAndSetTextInTextField(),
                        ],
                      )
                    ],
                  ),
                ),
                KSizedBox.h20,
                Center(
                  child: _isLoading
                      ? const KLoader()
                      : CustomElevatedButton(
                          text: 'SUBMIT',
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await _controller.applyTimeLog(
                                context,
                                selectedProjectId,
                                selectedTask,
                                _controller.dateController.text,
                                _controller.hrsController.text,
                                _controller.minController.text,
                                _controller.descriptionController.text);
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
  Widget _selectProject() {
    return Column(
      children: [
        KDropdownField<Lstproject>(
          value: selectedProject,
          onChanged: (value) {
            setState(() {
              selectedProject = value;
              selectedProjectId = selectedProject?.projectId;
              isProjectValid = true; // Hide error when project is selected
            });
          },
          title: 'Project',
          hint: 'Select Project',
          items: _isLoading ? [] : assignProject,
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
  Widget _selectTask() {
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
          hint: 'Select Task',
          items: _isLoading ? [] : assignTask,
          getLabel: (task) => task,
          isRequired: true,
          fontSize: 14,
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
          const Text('Tap to add description by speaking.',
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
        _addVoiceNote();
      },
    );
  }

  void _showMicBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        // Save the bottom sheet's own context
        _bottomSheetContext = bottomSheetContext;

        return WillPopScope(
          onWillPop: () async => false,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _animation,
                  child: Icon(Icons.mic, size: 44, color: Colors.red),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Listening... Please speak",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: KColors.appPrimary),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _speech.stop();
                    _animationController.stop();
                    Navigator.of(bottomSheetContext)
                        .pop(); // Close the bottom sheet
                  },
                  child: const Text("Stop"),
                )
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      // When bottom sheet is dismissed, clear the context
      _bottomSheetContext = null;
    });
  }
}

/// Restricts input to a valid minute value (1–59).
class MinuteRangeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final int? value = int.tryParse(newValue.text);
    if (value == null || value < 1 || value > 59) {
      return oldValue;
    }
    return newValue;
  }
}
