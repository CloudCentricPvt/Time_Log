import 'package:flutter/material.dart';
import 'package:time_log/utils/constants/k_fonts.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> leaveBalances = [
    {
      "type": "Work from home request starting on 13 March,2025 has been Approved.",
      "consumed": "Approved",
      "left": 7,
      "total": 9,
      "color": Colors.purple,
      "icons": "assets/images/profile_img.jpeg",
      "status":"Approved"
    },
    {
      "type": "Work from home request starting on 13 March,2025 has been Approved.",
      "consumed": "Approved",
      "left": 4,
      "total": 5,
      "color": Colors.green,
      "icons": "assets/images/profile_img.jpeg",
      "status":"Rejected"
    },
    {
      "type": "Work from home request starting on 13 March,2025 has been Approved.",
      "consumed": "Approved",
      "left": 10,
      "total": 15,
      "color": Colors.blue,
      "icons": "assets/images/profile_img.jpeg",
      "status":"Approved"
    },
    {
      "type": "Work from home request starting on 13 March,2025 has been Approved.",
      "consumed": "Approved",
      "left": 10,
      "total": 15,
      "color": Colors.blue,
      "icons": "assets/images/profile_img.jpeg",
      "status":"Rejected"
    },
    {
      "type": "Work from home request starting on 13 March,2025 has been Approved.",
      "consumed": "Approved",
      "left": 10,
      "total": 15,
      "color": Colors.blue,
      "icons": "assets/images/profile_img.jpeg",
      "status":"Rejected"
    },
    {
      "type": "Work from home request starting on 13 March,2025 has been Approved.",
      "consumed": "Approved",
      "left": 10,
      "total": 15,
      "color": Colors.blue,
      "icons": "assets/images/profile_img.jpeg",
      "status":"Approved"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: KCustomAppBar(
          screenTitle: 'Notification Screen',
          showHistory: false,
          onHistoryTap: () {
            Navigator.pushNamed(context, '/leave_history_screen');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today',
                  style: KFonts.normalBold,
                ),
                Text(
                  'Mark All Read',
                  style: KFonts.normalBoldWithBlueColor,
                ),
              ],
            ),

            /// ---- toady notification
            SizedBox(
              width: double.infinity,
              height: 100,
              child: Card(
                shadowColor: KColors.cardShadowColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),

              ),
            ),

            /// ---- last months notification
            Text(
              'Last Month',
              style: KFonts.normalBold,
            ),

            Expanded(
              child: ListView.builder(
                itemCount: leaveBalances.length,
                itemBuilder: (context, index) {
                  final leave = leaveBalances[index];
                  return CustomNotificationCard(
                    type: leave["type"],
                    consumed: leave["consumed"],
                    left: leave["left"],
                    total: leave["total"],
                    color: getLeaveColor(leave["status"] ?? ""),
                    // Assign color
                    iconAsset: leave["icons"],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getLeaveColor(String? type) {
    switch (type) {
      case "Approved":
        return KColors.purpleColor;
      case "Approved":
        return KColors.greenColor;
      case "Approved":
        return KColors.appPrimary;
      case "Rejected":
        return KColors.appPrimaryRed;
      case "Approved":
        return KColors.orangeColor;
      case "Approved":
        return KColors.appPrimaryYellow;
      case "Approved":
        return KColors.pinkColor;
      default:
        return Colors.grey; // Default color if no match
    }
  }
}

class CustomNotificationCard extends StatelessWidget {
  final String type;
  final String consumed;
  final int left;
  final int total;
  final Color color;
  final String iconAsset;

  const CustomNotificationCard(
      {super.key,
      required this.type,
      required this.consumed,
      required this.left,
      required this.total,
      required this.color,
      required this.iconAsset});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      color: Colors.white,
      shadowColor: KColors.cardShadowColor,
      // Card background set to white
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
              width: 40,
              child: Center(
                child: Image.asset(
                  iconAsset,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
             // spacing between icon and text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      type,
                      style: KFonts.normal,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                    Text('Approved by: Rakesh', style: KFonts.normal),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('No. of days: 1', style: KFonts.normal),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
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
                    )
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
