import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/utils/reusable_widgit/k_size_box.dart';

import '../../utils/constants/k_colors.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import '../../utils/reusable_widgit/k_elevated_button.dart';

class BalanceLeaveScreen extends StatefulWidget {
  const BalanceLeaveScreen({super.key});

  @override
  State<BalanceLeaveScreen> createState() => _BalanceLeaveScreenState();
}

class _BalanceLeaveScreenState extends State<BalanceLeaveScreen> {
  // Static List of Leave Balances
  final List<Map<String, dynamic>> leaveBalances = [
    {
      "type": "Casual/Paid Leaves",
      "consumed": "2 days Consumed",
      "left": 7,
      "total": 9,
      "color": Colors.purple,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "type": "Sick Leaves",
      "consumed": "1 day Consumed",
      "left": 4,
      "total": 5,
      "color": Colors.green,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "type": "LWP Leave",
      "consumed": "5 days Consumed",
      "left": 10,
      "total": 15,
      "color": Colors.blue,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "type": "Maternity Leave",
      "consumed": "5 days Consumed",
      "left": 10,
      "total": 15,
      "color": Colors.blue,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "type": "Earn Leave",
      "consumed": "5 days Consumed",
      "left": 10,
      "total": 15,
      "color": Colors.blue,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "type": "Paternity Leave",
      "consumed": "5 days Consumed",
      "left": 10,
      "total": 15,
      "color": Colors.blue,
      "icons": "assets/images/profile_img.jpeg",
    },
  ];

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: leaveBalances.length,
                itemBuilder: (context, index) {
                  final leave = leaveBalances[index];
                  return BalanceLeave(
                    type: leave["type"],
                    consumed: leave["consumed"],
                    left: leave["left"],
                    total: leave["total"],
                    color: getLeaveColor(leave["type"] ?? ""),  // Assign color
                    iconAsset: leave["icons"],
                  );
                },
              ),
            ),
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
              child: Image.asset(
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
