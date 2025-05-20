import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_loader.dart';
import 'package:time_log/utils/reusable_widgit/k_size_box.dart';

import '../../models/annual_leave_details_res.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import '../../utils/reusable_widgit/k_elevated_button.dart';

class BalanceLeaveScreen extends StatefulWidget {
  const BalanceLeaveScreen({super.key});

  @override
  State<BalanceLeaveScreen> createState() => _BalanceLeaveScreenState();
}

class _BalanceLeaveScreenState extends State<BalanceLeaveScreen> {
  bool _isLoading = true;
  double casualLeave = 0.0;
  double casualLeaveBal = 0.0;
  LeaveBal? data;


  @override
  void initState() {
    fetchAnnualLeaveDetails();
    super.initState();
  }

  Future<void> fetchAnnualLeaveDetails() async {
    try {
      final response = await getAnnualLeaveDetails(context);

      if (response is AnnualLeaveDetailsResponse) {
        setState(() {

          final dataList = response.data;
          data = dataList;
          _isLoading = false;

        });

      } else {
        setState(() {
          _isLoading = false;
        });
        print("Error: Response is not of type AnnualLeaveDetailsResponse.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error in fetchAnnualLeaveDetails: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: const KCustomAppBar(
          screenTitle: 'Balance Leave',
        ),
      ),
      body: _isLoading ? KLoader() : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            data?.totalCasualLeave != null && data!.totalCasualLeave != 0
                ? _showCasualLeave()
                : SizedBox(),

            data?.totalSickLeave != null && data!.totalSickLeave != 0
                ? _showSickLeave()
                : SizedBox(),// or SizedBox.shrink() if you want it to take no space

            data?.totalElLeave != null && data!.totalElLeave != 0
                ? _showEarnLeave()
                : SizedBox(),

            data?.totalCompOffLeave != null && data!.totalCompOffLeave != 0
                ? _showCompOffLeave()
                : SizedBox(),

            //_showLWPLeave(),
            //_showMaternityLeave(),
            //_showPaternityLeave(),
            SizedBox(height: 10,),
            CustomElevatedButton(text: 'Apply Leave', onPressed: () { Navigator.pushNamed(context, '/apply_leave_screen');},),
            KSizedBox.h14,
          ],
        ),
      ),
    );
  }

  // Function to assign colors based on leave type
  Color getLeaveColor(String? type) {
    switch (type) {
      case "Casual/Paid Leaves":
        return KColors.purpleColor;
      case "Sick Leaves":
        return KColors.greenColor;
      case "LWP Leave":
        return KColors.appPrimary;
      case "Maternity Leave":
        return KColors.appPrimaryRed;
      case "Earn Leave":
        return KColors.orangeColor;
      case "Paternity Leave":
        return KColors.appPrimaryYellow;
      case "Comp Off Leave":
        return KColors.pinkColor;
      default:
        return Colors.grey;  // Default color if no match
    }
  }

  Widget _showCasualLeave() {
    int left = data?.casualLeaveBal?.toInt() ?? 0;
    int total = data?.totalCasualLeave?.toInt() ?? 0;
    int consumed = total - left;
    return BalanceLeave(
      type: "Casual Leave/Paid Leave",
      consumed: ('$consumed Day'),
      left: data?.casualLeaveBal.toInt() ?? 0,
      total: data?.totalCasualLeave.toInt() ?? 0,
      color: KColors.purpleColor,
      iconAsset: KAssets.casualLeave,
    );
  }

  Widget _showSickLeave() {
    int left = data?.sickLeaveBal?.toInt() ?? 0;
    int total = data?.totalSickLeave?.toInt() ?? 0;
    int consumed = total - left;
    return BalanceLeave(
      type: "Sick Leaves",
      consumed: ('$consumed Day'),
      left: data?.sickLeaveBal.toInt() ?? 0,
      total: data?.totalSickLeave.toInt() ?? 0,
      color: KColors.greenColor,
      iconAsset: KAssets.sickLeave,
    );
  }

  Widget _showEarnLeave() {
    int left = data?.elLeaveBal?.toInt() ?? 0;
    int total = data?.totalElLeave?.toInt() ?? 0;
    int consumed = total - left;
    return BalanceLeave(
      type: "Earn Leave",
      consumed: ('$consumed Day'),
      left: data?.elLeaveBal.toInt() ?? 0,
      total: data?.totalElLeave.toInt() ?? 0,
      color: KColors.orangeColor,
      iconAsset: KAssets.earnLeave,
    );
  }

  Widget _showCompOffLeave() {
    return BalanceLeave(
      type: "Comp Off Leave",
      consumed: '0 days',
      left: data?.compOffLeaveBal.toInt() ?? 0,
      total: data?.totalCompOffLeave.toInt() ?? 0,
      color: KColors.pinkColor,
      iconAsset: KAssets.compOffLeave,
    );
  }

  Widget _showLWPLeave() {
    return BalanceLeave(
      type: "LWP Leave",
      consumed: '0 days',
      left: 1,
      total: (casualLeave.toInt()),
      color: KColors.appPrimary,
      iconAsset: KAssets.lwpLeave,
    );
  }

  Widget _showMaternityLeave() {
    return BalanceLeave(
      type: "Maternity Leave",
      consumed: '0 days',
      left: 1,
      total: (casualLeave.toInt()),
      color: KColors.appPrimaryRed,
      iconAsset: KAssets.compOffLeave,
    );
  }

  Widget _showPaternityLeave() {
    return BalanceLeave(
      type: "Paternity Leave",
      consumed: '0 days',
      left: 1,
      total: (casualLeave.toInt()),
      color: KColors.appPrimaryYellow,
      iconAsset: KAssets.compOffLeave,
    );
  }
}

class BalanceLeave extends StatelessWidget {
  final String type;
  final String consumed;
  final int left;
  final int total;
  final Color color;
  final String iconAsset;

  const BalanceLeave({
    super.key,
    required this.type,
    required this.consumed,
    required this.left,
    required this.total,
    required this.color,
    required this.iconAsset
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      color: Colors.white,
      shadowColor: KColors.cardShadowColor,// Card background set to white
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 75,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///---Vertical Colored Line (Only at Start)
            Padding(
              padding: const EdgeInsets.only(top: 1,bottom: 1),
              child: Container(
                width: 4,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
            ),

            ///-- Set Icons
            const SizedBox(width: 20,),
            Center(
              child: SvgPicture.asset(
                iconAsset,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8), // Spacing between icon and text

            ///---- Expanded Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Icon and Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 6),
                              Text(
                                type,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: KColors.textHeadingColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Consumed Days Tag
                          Container(
                            //padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4,),
                            padding: const EdgeInsets.only(left: 8,right: 8,top: 1,bottom: 1),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(0),

                            ),
                            child: Text(
                              consumed,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Leave Count (Right Side)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Left/Total",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "$left/$total",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: KColors.textColorGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
