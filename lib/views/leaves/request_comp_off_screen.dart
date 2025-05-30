import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:time_log/controllers/leave_controller.dart';
import 'package:time_log/utils/constants/k_loader.dart';
import 'package:time_log/utils/reusable_widgit/k_elevated_button.dart';
import 'package:time_log/utils/reusable_widgit/k_info_card.dart';
import 'package:time_log/utils/reusable_widgit/k_size_box.dart';
import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/constants/k_date_dialog.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import '../../utils/reusable_widgit/k_textinputform_field.dart';

class RequestCompOFF extends StatefulWidget {
  const RequestCompOFF({super.key});

  @override
  State<RequestCompOFF> createState() => _CompOffScreenState();
}

class _CompOffScreenState extends State<RequestCompOFF> {

  final ApplyLeaveController _controller = ApplyLeaveController();
  stt.SpeechToText _speech = stt.SpeechToText();
  String _text = "";
  bool _isListening = false;
  bool _isLoading = false;

  String? _startDate;
  String? _endDate;

  int? _differenceInDays;

  Future<void> _selectStartDate() async {
    String? selectedDate = await KDateDialog.selectDate(context: context);
    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
        _calculateDateDifference(); // Recalculate difference
      });
    }
  }

  Future<void> _selectEndDate() async {
    String? selectedDate = await KDateDialog.selectDate(context: context);
    if (selectedDate != null) {
      setState(() {
        _endDate = selectedDate;
        _calculateDateDifference(); // Calculate difference when end date is selected
      });
    }
  }

// Function to calculate date difference
  void _calculateDateDifference() {
    if (_startDate != null &&
        _endDate != null &&
        _startDate!.isNotEmpty &&
        _endDate!.isNotEmpty) {
      try {
        DateFormat inputFormat = DateFormat("dd, MMM yyyy");

        DateTime startDate = inputFormat.parse(_startDate!.trim());
        DateTime endDate = inputFormat.parse(_endDate!.trim());

        if (startDate.isAfter(endDate)) {
          print("Start date is after end date");
          return;
        }

        setState(() {
          _differenceInDays = endDate.difference(startDate).inDays + 1;
        });

        print("Days between: $_differenceInDays");
      } catch (e) {
        print("Date parsing error: $e");
      }
    } else {
      print("One or both dates are null or empty");
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

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
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF84DBFF), // Same as app bar
          statusBarIconBrightness: Brightness.dark, // or .light depending on contrast
        ),
        title: KCustomAppBar(
          screenTitle: 'Request Comp Off',
          showHistory: true,
          onHistoryTap: () {
            Navigator.pushNamed(context, '/comp_off_history_screen');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: KInfoCard(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _startDate == null ? "From Date" : "From Date",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  fontSize: 16),
                            ),
                            Text(
                              _startDate ?? "Start Date",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: KColors.appPrimary),
                            )
                          ],
                        ),
                        onTap: () async {
                          _selectStartDate();
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Card(
                              color: KColors.appColorWhite,
                              shadowColor: KColors.cardShadowColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                // Rounded corners
                                side: const BorderSide(
                                    color: KColors.colorGray,
                                    width: 1), // Stroke border
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 3, bottom: 3),
                                child: Text(
                                    _differenceInDays != null ? "$_differenceInDays Day" : "0 Day",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: KColors.appPrimaryRed)),
                              ))
                        ],
                      ),
                      GestureDetector(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _endDate == null ? "To Date" : "To Date",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  fontSize: 16),
                            ),
                            Text(
                              _endDate?? "End Date",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: KColors.appPrimary),
                            )
                          ],
                        ),
                        onTap: () async {
                          _selectEndDate();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            KSizedBox.h14,
            SizedBox(
              width: double.infinity,
              child: KInfoCard(
                children: [
                  KSizedBox.h10,
                  KTextInputFormField(
                    labelText: 'Description',
                    hintText: 'Enter reason of Comp Off Request here..',
                    controller: _controller.descriptionController,
                    useMaxLines: true,
                    useMaxLength: true,
                    maxLines: 4,
                    maxLength: 32768,
                    /*onChange: (value) {
                      _controller.descriptionController.text = value!;
                      return null;
                    },*/
                  ),
                  GestureDetector(
                    child: Row(
                      children: [
                        SvgPicture.asset(KAssets.voiceIcon,),
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
                  )
                ],
              ),
            ),
            KSizedBox.h14,
            _onClickButton(),

          ],
        ),
      ),
    );
  }
  /// --- click perform on button
  Widget _onClickButton() {
    return Center(
      child: _isLoading ? const KLoader(): CustomElevatedButton(
        text: 'SUBMIT',
        onPressed: () async {
          if (_startDate == null || _endDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select both Start Date and End Date'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            setState(() {
              _isLoading = true;
            });
            await _controller.applyCompOff(context,_startDate,_endDate,_differenceInDays.toString(),_controller.descriptionController.text);
            setState(() {
              _isLoading = false;
            });
          }
        },
      ),
    );
  }
}
