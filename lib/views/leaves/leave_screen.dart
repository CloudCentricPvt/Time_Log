import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/reusable_widgit/k_size_box.dart';

import '../../utils/constants/k_colors.dart';
import '../../utils/constants/k_drawer_menu.dart';
import '../../utils/constants/k_nav_header.dart';
import '../../utils/reusable_widgit/k_circular_progress.dart';
import '../../utils/reusable_widgit/k_upcoming_holidays.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {

  final List<Map<String, dynamic>> leaveBalances = [
    {
      "month": "MARCH",
      "date": "02",
      "type": "EL",
      "color": Colors.purple,
    },
    {
      "month": "APRIL",
      "date": "07",
      "type": "CL",
      "color": Colors.purple,
    },
    {
      "month": "MAY",
      "date": "18",
      "type": "COMP OFF",
      "color": Colors.purple,
    },
    {
      "month": "JUN",
      "date": "25",
      "type": "COMP OFF",
      "color": Colors.purple,
    },

  ];
  final List<Map<String, dynamic>> holidays = [
    {
      "title": "HOLI",
      "consumed":
      "this week is holi the offical selebration in company at 4:00 PM",
      "date": "#Fridat, 14 March 2025",
      "color": KColors.appSecondary,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "title": "EID-UL-FITER",
      "consumed": "vdkj dfmndfkjdfkgjdfkgjdfkgjdfkjgdfkjdfkv",
      "date": "#Fridat, 14 March 2025",
      "color": KColors.appSecondary,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "title": "Rohit",
      "consumed": "kdkdkdgmdkdfkgffgfgdflgfdfghjk dfdff",
      "date": "#Fridat, 14 March 2025",
      "color": KColors.appSecondary,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "title": "Maternity Leave",
      "consumed": "fkfdjf djfdjfjd ddfjddfjfdff ff",
      "date": "#Fridat, 14 March 2025",
      "color": KColors.appSecondary,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "title": "Earn Leave",
      "consumed": "ttettetttgftyftef efefefefef",
      "date": "#Fridat, 14 March 2025",
      "color": KColors.appSecondary,
      "icons": "assets/images/profile_img.jpeg",
    },
  ];




  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: KCustomDrawer.customDrawer(
        context: context,
        title: "Leaves Details & Apply",
        titleColor: KColors.appBlackColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        showBellIcon: true,
        // Show Bell Icon
        showProfileIcon: false, // Hide Profile Icon
      ),
      drawer: CustomDrawerMenu(context: context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: KColors.appColorWhite),
                child: Column(
                  children: [
                    KSizedBox.h15,
                    const Text(
                      "Annual Leave Details",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                    KSizedBox.h10,

                    Center(
                      child: KCircularProgressBar.circularIndicator(
                        percent: 0.75,
                        value: '15',
                        valueTextSize: 28,
                        label: 'Leave balance',
                        radius: 60.0,
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('Total Leaves'),
                            Text(
                              '21',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Leave Used'),
                            Text('06',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),

                    /// ---- Design Circular progress bar Horizontally
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: KCircularProgressBar.circularIndicator(
                                  progressColor: KColors.purpleColor,
                                  percent: 0.75,
                                  value: '09',
                                  valueTextSize: 18,
                                  radius: 34.0,
                                  bottomLabel: 'Casual Leave',
                                  bottomLabelColor: KColors.textColorGray)),
                          Expanded(
                              child: KCircularProgressBar.circularIndicator(
                                  progressColor: KColors.greenColor,
                                  percent: 0.75,
                                  value: '15',
                                  valueTextSize: 18,
                                  radius: 34.0,
                                  bottomLabel: 'Sick Leave',
                                  bottomLabelColor: KColors.textColorGray)),
                          Expanded(
                              child: KCircularProgressBar.circularIndicator(
                                  progressColor: KColors.orangeColor,
                                  percent: 0.75,
                                  value: '03',
                                  valueTextSize: 18,
                                  radius: 34.0,
                                  bottomLabel: 'Earn Leave',
                                  bottomLabelColor: KColors.textColorGray)),
                          Expanded(
                              child: KCircularProgressBar.circularIndicator(
                                  progressColor: KColors.pinkColor,
                                  percent: 0.75,
                                  value: '05',
                                  valueTextSize: 18,
                                  radius: 34.0,
                                  bottomLabel: 'Comp Off',
                                  bottomLabelColor: KColors.textColorGray)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        child: const Center(
                          child: Text(
                            "View Balance Leave",
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: KColors.appPrimary),
                          ),
                        ),
                        onTap: (){
                          Navigator.pushNamed(context, '/balance_leave_screen');
                        },
                      ),
                    ),
                  ],
                ),
              ),

              /// ---- Design Apply section

              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14, right: 5),
                      child: KFeatureCard(
                        iconAsset: KAssets.applyLeave,
                        title: 'Apply Leaves',
                        onTap: () {
                          Navigator.pushNamed(context, '/apply_leave_screen');
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 14, right: 5, left: 5),
                      child: KFeatureCard(
                        iconAsset: KAssets.requestWFH,
                        title: 'Request WFH',
                        onTap: () {
                          Navigator.pushNamed(context, '/request_wfh_screen');
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 14, right: 5, left: 5),
                      child: KFeatureCard(
                        iconAsset: KAssets.requestCompOFF,
                        title: 'Comp Off',
                        onTap: () {Navigator.pushNamed(context, '/comp_off_screen');},
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14, left: 5),
                      child: KFeatureCard(
                        iconAsset: KAssets.holidaysList,
                        title: 'Holidays List',
                        onTap: () {Navigator.pushNamed(context, '/holiday_list_screen');},
                      ),
                    ),
                  ),
                ],
              ),

              /// ---- Design Upcoming events
              KSizedBox.h14,
              const Text(
                "Upcoming Your Leaves",
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: KColors.textHeadingColor),
              ),
              KSizedBox.h10,
              SizedBox(
                height: 115,
                child: Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: leaveBalances.length,
                    itemBuilder: (context, index) {
                      final leave = leaveBalances[index];
                      return UpcomingLeavesCard(
                        month: leave['month'],
                        date: leave['date'],
                        type: leave['type'],
                        cardColor: getLeaveColor(leave["type"] ?? ""),
                      );
                    },
                  ),
                ),
              ),

              /// --- Upcoming holidays
              KSizedBox.h14,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Upcoming Holidays', style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: KColors.textHeadingColor),),
                  InkWell(
                    child: const Text('Read more', style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: KColors.appPrimary),),
                    onTap: (){Navigator.pushNamed(context, '/holiday_list_screen');},
                  ),
                ],
              ),

              /// ---- Design Holiday banner
              KSizedBox.h10,
              SizedBox(
                height: 95,
                child: KUpcomingHolidays(upcomingItems: holidays),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getLeaveColor(String? type) {
    switch (type) {
      case "EL":
        return KColors.orangeColor;
      case "CL":
        return KColors.greenColor;
      case "COMP OFF":
        return KColors.pinkColor;
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

class UpcomingLeavesCard extends StatelessWidget {
  final String? month;
  final String? date;
  final String? type;
  final Color? cardColor;
  final Color? textColor;
  final Color? shadowColor;

  const UpcomingLeavesCard({
    super.key,
    this.month = "MARCH",
    this.date = "07",
    this.type = "EL",
    this.cardColor,
    this.textColor,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Card(
        elevation: 2,
        color: Colors.white,
        shadowColor: shadowColor ?? Colors.grey.shade300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          children: [
            const SizedBox(height: 5),
            Text(
              month!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.black,
              ),
            ),
            SizedBox(
              height: 60,
              width: 60,
              child: Card(
                color: cardColor ?? KColors.orangeColor,
                shadowColor: shadowColor ?? Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: Center(
                  child: Text(
                    date!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor ?? Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              type!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KFeatureCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final VoidCallback? onTap;

  const KFeatureCard({
    super.key,
    required this.iconAsset,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 91,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: KColors.appColorWhite,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconAsset,
              height: 40,
              width: 40,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center, // Center text
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


