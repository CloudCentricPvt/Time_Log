import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/utils/reusable_widgit/k_elevated_button.dart';
import 'package:time_log/utils/reusable_widgit/k_info_card.dart';
import 'package:time_log/utils/reusable_widgit/k_size_box.dart';
import '../../controllers/request_comp_off_controller.dart';
import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/constants/k_date_dialog.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import '../../utils/reusable_widgit/k_text_form_field.dart';
import '../../utils/reusable_widgit/k_textinputform_field.dart';

class RequestCompOFF extends StatefulWidget {
  const RequestCompOFF({super.key});

  @override
  State<RequestCompOFF> createState() => _CompOffScreenState();
}

class _CompOffScreenState extends State<RequestCompOFF> {

  final RequestCompOFFController _descriptionController = RequestCompOFFController();
  String? _startDate;
  String? _endDate;

  int? _differenceInDays;

  Future<void> _selectStartDate() async {
    String? selectedDate = await KDateDialog.selectFutureOrCurrentDate(context: context);
    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
        _calculateDateDifference(); // Recalculate difference
      });
    }
  }

  Future<void> _selectEndDate() async {
    String? selectedDate = await KDateDialog.selectFutureOrCurrentDate(context: context);
    if (selectedDate != null) {
      setState(() {
        _endDate = selectedDate;
        _calculateDateDifference(); // Calculate difference when end date is selected
      });
    }
  }

// Function to calculate date difference
  void _calculateDateDifference() {
    if (_startDate != null && _endDate != null) {
      DateTime startDate = DateTime.parse(_startDate!);
      DateTime endDate = DateTime.parse(_endDate!);

      setState(() {
        _differenceInDays = endDate.difference(startDate).inDays + 1;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
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
                              _startDate == null ? "Select Start Date" : "From Date",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  fontSize: 16),
                            ),
                            Text(
                              _startDate ?? "YYY-MM-DD",
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
                              _endDate == null ? "Select End Date" : "To Date",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  fontSize: 16),
                            ),
                            Text(
                              _endDate?? "YYY-MM-DD",
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
                    controller: _descriptionController.descriptionController,
                    useMaxLines: true,
                    useMaxLength: true,
                    maxLines: 4,
                    maxLength: 1000,
                    onChange: (value) {
                      _descriptionController.descriptionController.text = value!;
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(KAssets.voiceIcon,),
                      KSizedBox.w10,
                      const Text(
                        'Check to Add Description vai Speak',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: KColors.appPrimary),
                      ),
                    ],
                  )
                ],
              ),
            ),
            KSizedBox.h14,
            CustomElevatedButton(
              text: 'Apply',
              onPressed: () async {
                if (_startDate == null || _endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select both Start Date and End Date'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  await _descriptionController.checkDescription(context);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
