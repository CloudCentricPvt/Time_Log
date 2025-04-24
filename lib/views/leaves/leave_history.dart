import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/utils/constants/k_fonts.dart';
import 'package:time_log/utils/reusable_widgit/k_filter_header.dart';

import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/popups/k_filter_dialog.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';

class LeaveHistory extends StatefulWidget {
  const LeaveHistory({super.key});

  @override
  State<LeaveHistory> createState() => _LeaveHistoryState();
}

class _LeaveHistoryState extends State<LeaveHistory> {
  final List<Map<String, dynamic>> leaveBalances = [
    {
      "type": "Casual/Paid Leaves",
      "day": "2 Days",
      "startDate": "13 March 2025",
      "endDate": "20 March 2025",
      "status": "Pending",
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "type": "Sick Leave",
      "day": "3 Days",
      "startDate": "10 April 2025",
      "endDate": "13 April 2025",
      "status": "Rejected",
      "icons": "assets/images/profile_img.jpeg",
    },
  ];
  String selectedProject = "Select Project";
  String selectedTask = "Select Task";
  final List<String> projectItems = [
    "Select Project",
    "Leave/Holiday (April 2024 - March 2025)",
    "Self Study (April 2024 - March 2025)",
    "UI/UX Designing FY 24-25"
  ];

  final List<String> taskItems = [
    "Select Task",
    "UI/ux CloudCentric",
    "Uux FieldBan",
    "ui/ux CloudConics",
    "UI/ux SocialPols",
    "ui/ux Desers",
    "Other"
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: KCustomAppBar(
          screenTitle: 'Leave History',
          showHistory: true,
          historyTitle: 'Apply New',
          onHistoryTap: () {
            Navigator.pushNamed(context, '/apply_leave_screen');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                KFilterHeader(
                    width: 65,
                    textTitle: 'All',
                    textColor: KColors.appColorWhite,
                    backgroundColor: KColors.appPrimary,
                    onHistoryTap: () {

                    }),
                KFilterHeader(
                    textTitle: 'Pending',
                    strokeColor: KColors.orangeColor,
                    textColor: KColors.orangeColor,
                    onHistoryTap: () {}),
                KFilterHeader(
                    textTitle: 'Approved',
                    strokeColor: KColors.greenColor,
                    textColor: KColors.greenColor,
                    onHistoryTap: () {}),
                KFilterHeader(
                    textTitle: 'Rejected',
                    strokeColor: KColors.appPrimaryRed,
                    textColor: KColors.appPrimaryRed,
                    onHistoryTap: () {}),
                GestureDetector(child: SvgPicture.asset(KAssets.filterIcon),
                  onTap: (){
                    FilterDialog.showTimeLogFilterDialog(
                      context,
                      projectItems,
                      selectedProject,
                      selectedTask,
                      taskItems,
                      (String? newProject) {
                        setState(() {
                          selectedProject = newProject!;
                        });
                      },
                       (String? newTask) {
                        setState(() {
                          selectedTask = newTask!; // Update the selected task
                        });
                      },
                    );
                },
                ),
              ],
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: leaveBalances.length,
                itemBuilder: (context, index) {
                  final leave = leaveBalances[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: BalanceLeave(
                      type: leave["type"],
                      day: leave["day"],
                      status: leave["status"],
                      startDate: leave["startDate"],
                      endDate: leave["endDate"],
                      iconAsset: leave["icons"],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BalanceLeave extends StatelessWidget {
  final String type;
  final String status;
  final String day;
  final String startDate;
  final String endDate;
  final String iconAsset;

  const BalanceLeave({
    super.key,
    required this.type,
    required this.status,
    required this.day,
    required this.startDate,
    required this.endDate,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    // Define status colors
    Color statusColor;
    switch (status) {
      case "Pending":
        statusColor = KColors.orangeColor;
        break;
      case "Rejected":
        statusColor = KColors.appPrimaryRed;
        break;
      case "Approved":
        statusColor = KColors.greenColor;
        break;
      default:
        statusColor = Colors.grey; // Default color if status is unknown

    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 3,
      shadowColor: KColors.cardShadowColor,
      color: KColors.appColorWhite,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                iconAsset,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(type, style: KFonts.normalHeading),
                    const SizedBox(width: 2,),
                    const Text('|', style: KFonts.normalHeading),
                    const SizedBox(width: 2,),
                    Text(day, style: KFonts.normalHeading),
                  ],),

                  const SizedBox(height: 4),
                  Text("$startDate to $endDate", style: KFonts.normal),
                ],
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 1,
              color: statusColor, // Set background color dynamically
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(status, style: KFonts.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
