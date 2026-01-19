import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:time_log/utils/constants/k_loader.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../controllers/leave_controller.dart';
import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/constants/k_date_dialog.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import '../../utils/reusable_widgit/k_elevated_button.dart';
import '../../utils/reusable_widgit/k_info_card.dart';
import '../../utils/reusable_widgit/k_size_box.dart';
import '../../utils/reusable_widgit/k_textinputform_field.dart';
class RequestWorkFromHome extends StatefulWidget {
  const RequestWorkFromHome({super.key});

  @override
  State<RequestWorkFromHome> createState() => _RequestWorkFromHomeState();
}

class _RequestWorkFromHomeState extends State<RequestWorkFromHome> with SingleTickerProviderStateMixin {
  stt.SpeechToText _speech = stt.SpeechToText();

  //late stt.SpeechToText _speech;

  final ApplyLeaveController _controller = ApplyLeaveController();
  String? _startDate;
  String? _endDate;
  int? _differenceInDays;
  bool _isLoading = false;


  bool _isListening = false;
  String _previousText = '';
  BuildContext? _bottomSheetContext;
  late AnimationController _animationController;
  late Animation<double> _animation;

  Future<void> _selectStartDate() async {
    String? selectedDate = await KDateDialog.futureDate(context: context);
    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
        _calculateDateDifference(); // Recalculate difference
      });
    }
  }

  Future<void> _selectEndDate() async {
    String? selectedDate = await KDateDialog.futureDate(context: context);
    if (selectedDate != null) {
      setState(() {
        _endDate = selectedDate;
        _calculateDateDifference(); // Calculate difference when end date is selected
      });
    }
  }

// Function to calculate date difference
 /* void _calculateDateDifference() {
    if (_startDate != null &&
        _endDate != null &&
        _startDate!.isNotEmpty &&
        _endDate!.isNotEmpty) {
      try {
        // Use the correct format
        DateFormat inputFormat = DateFormat("dd, MMMM yyyy");

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
  }*/

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
    //_speech = stt.SpeechToText();
    _animationController = AnimationController(
      vsync: this, // Now this will work
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.4).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addVoiceNote() async {
    // Always create a fresh instance to avoid previous bindings
    _speech = stt.SpeechToText();

    if (_speech.isListening) {
      await _speech.stop();
      _animationController.stop();
      if (_bottomSheetContext != null) {
        Navigator.of(_bottomSheetContext!).pop();
        _bottomSheetContext = null;
      }
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          _stopListeningAndCloseDialog();
        }
      },
      onError: (error) {
        print('Speech error: $error');
        _stopListeningAndCloseDialog();
      },
    );

    if (available) {
      _previousText = _controller.descriptionController.text;

      setState(() => _isListening = true);
      _animationController.repeat(reverse: true);

      _showMicBottomSheet();

      _speech.listen(
        onResult: (result) {
          print('Recognized: ${result.recognizedWords}');
          setState(() {
            _controller.descriptionController.text = '$_previousText ${result.recognizedWords}'.trim();
            _controller.descriptionController.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.descriptionController.text.length),
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
          screenTitle: 'Request WFH',
          showHistory: true,
          onHistoryTap: () {
            Navigator.pushNamed(context, '/wfh_history_screen');
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
                    hintText: 'Enter reason of WFH Request here..',
                    controller: _controller.descriptionController,
                    useMaxLines: true,
                    useMaxLength: true,
                    maxLines: 10,
                    maxLength: 1000,
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
                        //_speechManager.forceStopListening();
                        _addVoiceNote();
                      }
                  )
                ],
              ),
            ),
            KSizedBox.h14,
            _clickPerformOnButton(),

          ],
        ),
      ),
    );
  }

  Widget _clickPerformOnButton() {
    return Center(
      child: _isLoading ? const KLoader() : CustomElevatedButton(
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
              await _controller.applyWFH(context,_startDate,_endDate,_differenceInDays.toString(),_controller.descriptionController.text);
              setState(() {
                _isLoading = false;
              });

            }
          }
      ),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: KColors.appPrimary),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _speech.stop();
                    _animationController.stop();
                    Navigator.of(bottomSheetContext).pop(); // Close the bottom sheet
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

  void _stopListeningAndCloseDialog() async {
    if (_speech.isListening) {
      await _speech.stop(); // Stop the speech recognition
    }

    _animationController.stop(); // Stop the mic animation

    if (mounted) { // Check if widget is still active
      setState(() {
        _isListening = false;
      });
    }

    // Safely dismiss the bottom sheet if it's still open
    if (_bottomSheetContext != null) {
      if (Navigator.of(_bottomSheetContext!).canPop()) {
        Navigator.of(_bottomSheetContext!).pop();
      }
      _bottomSheetContext = null; // Clear the context
    }
  }

}
