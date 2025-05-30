import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../reusable_widgit/k_info_card.dart';
import 'k_asstes.dart';
import 'k_colors.dart';
import 'k_date_and_time.dart';
import 'k_fonts.dart'; // import your constants

class ShowLeaveHistoryDetailsDialog extends StatelessWidget {
  final String? leaveType;
  final String? des;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? dayCount;

  const ShowLeaveHistoryDetailsDialog({
    super.key,
    this.leaveType,
    this.des,
    this.status,
    this.startDate,
    this.endDate,
    this.dayCount,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(

              children: [
                // --- show svg icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SvgPicture.asset(
                    getIconAccordingToMyScreen(leaveType, status),
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(leaveType!.isEmpty ? '': leaveType!, style: KFonts.normalHeading),
                      Row(
                        children: [
                          Text('Status: '),
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2)),
                            shadowColor: KColors.cardShadowColor,
                            color: getStatusColor1(status),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(status ?? "Pending", style: KFonts.normalWithWithText),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Spacer(),


                const SizedBox(width: 10),
                InkWell(
                  onTap: () => Navigator.pop(context, true),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    color: KColors.colorGray,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(KAssets.crossIcon),
                    ),
                  ),
                )
              ],
            ),

            // Set status


            SizedBox(height: 10,),

            //--- show start date and end date
            SizedBox(
              width: double.infinity,
              child: KInfoCard(
                backgroundColor: KColors.colorGray,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From date',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  fontSize: 16),
                            ),
                            Text(
                              "${KDateAndTime().getDay(startDate ?? "")} ${KDateAndTime().getMonthYear(startDate ?? "")}",

                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: KColors.appPrimary),
                            )
                          ],
                        ),

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
                                    dayCount == null || double.tryParse(dayCount!) == null
                                        ? "0"
                                        : "${double.parse(dayCount!).toInt()} Day",

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
                              'To Date',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  fontSize: 16),
                            ),
                            Text(
                              "${KDateAndTime().getDay(endDate ?? "")} ${KDateAndTime().getMonthYear(endDate ?? "")}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: KColors.appPrimary),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Text(des ?? "", style: KFonts.thin),

          ],
        ),
      ),
    );
  }

  Color getStatusColor1(String? status) {
    return status == "Pending"
        ? KColors.orangeColor
        : status == "Approved"
        ? KColors.greenColor
        : KColors.appPrimaryRed;
  }

  /// ---  show icon behalf of status
  String getIconForStatus(String? status) {

    switch (status) {
      case 'Pending':
        return KAssets.wfhPendingIcon;
      case 'Approved':
        return KAssets.requestWFH;
      case 'Rejected':
        return KAssets.wfhRejectedIcon;
      default:
        return KAssets.wfhPendingIcon; // fallback icon
    }
  }
  /// ---  show comp off icon behalf of status
  String getIconForCompOff(String? status) {

    switch (status) {
      case 'Pending':
        return KAssets.compOffPending;
      case 'Approved':
        return KAssets.compOffApproved;
      case 'Rejected':
        return KAssets.compOffRejected;
      default:
        return KAssets.compOffPending; // fallback icon
    }
  }

  /// ---  show icon behalf of Leave Type
  String getIconForType(String? type) {
    switch (type) {
      case 'SL':
        return KAssets.sickLeave;
      case 'CL':
        return KAssets.casualLeave;
      case 'EL':
        return KAssets.earnLeave;
      case 'Comp Off':
        return KAssets.compOffLeave;
      case 'LWP':
        return KAssets.lwpLeave;
      default:
        return KAssets.casualLeave; // fallback icon
    }
  }

  String getIconAccordingToMyScreen(String? leaveType, String? status) {
    if (leaveType == 'SL' || leaveType == 'CL' || leaveType == 'EL' || leaveType == 'LWP') {
      return getIconForType(leaveType);
    } else if (status == "Pending" || status == "Approved" || status == "Rejected") {
      if (leaveType == "Comp Off") {
        return getIconForCompOff(status);
      } else {
        return getIconForStatus(status);
      }
    }
    // If none of the above conditions match, return a default icon or handle null
    return ""; // or throw, or a default icon path
  }

}
