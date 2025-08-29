
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:time_log/utils/constants/k_fonts.dart';
import '../../controllers/time_log_controller.dart';
import '../../models/assign_project_res.dart';
import '../../models/assign_task_res.dart';
import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/constants/k_date_dialog.dart';
import '../../utils/constants/k_loader.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import '../../utils/reusable_widgit/k_elevated_button.dart';
import '../../utils/reusable_widgit/k_info_card.dart';
import '../../utils/reusable_widgit/k_size_box.dart';
import '../../utils/reusable_widgit/k_textinputform_field.dart';
//import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:dropdown_search/dropdown_search.dart';


class EditTimeLog extends StatefulWidget {
  const EditTimeLog({super.key});

  @override
  State<EditTimeLog> createState() => _EditTimeLogState();
}

class _EditTimeLogState extends State<EditTimeLog> {
  final TimeLogController _controller = TimeLogController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key for validation
  // stt.SpeechToText _speech = stt.SpeechToText();
  String _text = "";
  bool _isListening = false;
  String selectedDescription= '';
  String formattedMonths = '';
  String selectedDate= '';
  String selectedTask1= '';
  String selectedHrs= '';
  String selectedMin= '';

  List<Lstproject> assignProject = [];
  List<String> assignTask = [];
  late String timeLogId;
  late String projectName;
  late String projectId;
  late String taskName;
  late String hrs;
  late String min;
  late String date;
  late String des;
  late String monthsYear;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    timeLogId = args['timeLodId'];
    projectId = args['projectId'];
    projectName = args['projectName'];
    taskName = args['taskName'];
    hrs = args['hrs'];
    min = args['min'];
    date = args['date'];
    des = args['des'];
    monthsYear = args['monthsYear'];
    // Remove the comma after 'May' and concatenate
    formattedMonths = monthsYear.replaceFirst(', ', ' ');
    _controller.projectController.text = projectName ?? '';
    selectedDescription = des ?? '';
    selectedHrs = hrs ?? '';
    selectedMin = min ?? '';
    selectedDate='$date, $formattedMonths';


    // only seed the controller if it's empty
    if (_controller.dateController.text.isEmpty) {
      _controller.dateController.text = selectedDate;
    }
    if(_controller.descriptionController.text.isEmpty){
      _controller.descriptionController.text = selectedDescription;
    }
    if(_controller.minController.text.isEmpty){
      _controller.minController.text = selectedMin;
    }
    if(_controller.hrsController.text.isEmpty){
      _controller.hrsController.text = selectedHrs;
    }

    loadTasksFromApi();

  }

  String? selectedTask;
  bool _isLoading = false;

  @override
  /*
  void initState() {
    _speech = stt.SpeechToText();
    super.initState();
  }

   */
  /*
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "notListening") {
          Navigator.pop(context); // Close dialog when speech stops
        }
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
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
        setState(() => _isListening = false);
        Navigator.pop(context); // Close dialog
      } as FutureOr Function(Object error, StackTrace stackTrace));
    }
  }


   */
  /*
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


   */
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
          statusBarIconBrightness: Brightness.dark, // or .light depending on contrast
        ),
        title: KCustomAppBar(
          screenTitle: 'Edit Time Log',
          showHistory: false,
          onHistoryTap: () {
            Navigator.pushNamed(context, '/leave_history_screen');
          },
        ),
      ),
      body: SingleChildScrollView(
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
                          _selectHrsAndMin(),

                          /// --- Design for select date
                          KSizedBox.h20,
                          _selectDate(),

                          /// --- Design for Time Log description
                          KSizedBox.h20,

                          _description(),
                          KSizedBox.h10,
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

                      await _controller.updateTimeLog(context,timeLogId,projectId,selectedTask,_controller.dateController.text,_controller.hrsController.text,_controller.minController.text,_controller.descriptionController.text);
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
    );
  }

  Future<void> loadTasksFromApi() async {
    final response = await assignTaskFormSF(context);
    if (mounted && response is AssignTaskResponse) {
      setState(() {
        assignTask = response.taskTypes;

        // Set the received task only if selectedTask is not set yet
        if ((selectedTask == null || selectedTask!.isEmpty) &&
            assignTask.contains(taskName)) {
          selectedTask = taskName;
        }

      });
    } else {
    }
  }

  Widget _selectProject() {
    return Column(
      children: [
        KTextInputFormField(
          labelText: 'Project',
          hintText: '',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          controller: _controller.projectController,
          useMaxLines: true,
          isRequired: true,
          readOnly: true,
          disableBgColor: true,
          maxLines: 1,
          onChange: (value) {
            _controller.projectController.text = value!;
            return null;
          },

        ),
      ],
    );
  }

  Widget _selectTask() {
    return DropdownSearch<String>(
      items: assignTask , // List<String>
      selectedItem: selectedTask ?? "",
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search task...",
            border: OutlineInputBorder(),
          ),
        ),
      ),
      dropdownButtonProps: DropdownButtonProps(
        icon: Icon(Icons.keyboard_arrow_down_outlined, color: Colors.black),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          label: RichText(
              text: TextSpan(
                  text: 'Select Task',
                  style: KFonts.normal,
                  children: [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
              )
          ),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.only(left: 20,),
        ),
      ),
      onChanged: (value) {
        setState(() {
          selectedTask = value!;
        });
      },
    );
  }


  Widget _selectDate() {
    return KTextInputFormField(
      labelText: 'Date',
      hintText: 'Select date',
      isRequired: true,
      controller: _controller.dateController,
      readOnly: true,
      suffixIcon: IconButton(
        onPressed: () async {
          String? selectedDateStr = await KDateDialog.selectDate(context: context);

          if (selectedDateStr != null && selectedDateStr.isNotEmpty) {
            setState(() {
              _controller.dateController.text = selectedDateStr;
            });
          }
        },
        icon: SvgPicture.asset(KAssets.calenderIcon),
      ),
    );
  }



  Widget _description() {
    return KTextInputFormField(
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
    );
  }

  Widget _selectHrsAndMin() {
    return Row(
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
              MinuteRangeFormatter(), // Ensures value is between 1–59
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
              MinuteRangeFormatter(), // Ensures value is between 1–59
            ],
          ),
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
        //  _showSpeakUpDialog(); // Show dialog
        Future.delayed(Duration(milliseconds: 500), () {
          // Delay to allow UI update
          //     _startListening(); // Start speech recognition after dialog is shown
        });
      },
    );
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