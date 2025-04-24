import 'package:flutter/material.dart';
import 'package:time_log/utils/constants/k_fonts.dart';

import '../../utils/constants/k_colors.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import '../leaves/balance_leave_screen.dart';
class UpcomingEvents extends StatefulWidget {
  const UpcomingEvents({super.key});

  @override
  State<UpcomingEvents> createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends State<UpcomingEvents> {

  final List<Map<String, String>> events = [
    {
      "title": "No Birthday Today",
      "des": "Wish you a very happy and colorful Holi",
      "date": "Friday, 25 Mar",
    },
    {
      "title": "No Anniversary Today",
      "des": "Join us for the latest tech trends and innovations",
      "date": "Saturday, 30 Mar",
    },
    {
      "title": "Food Festival",
      "des": "Enjoy delicious food from around the world",
      "date": "Friday, 5 Apr",
    },
    {
      "title": "Sports Meet",
      "des": "Come and cheer for your favorite team",
      "date": "Wednesday, 10 Apr",
    },
  ];
  final List<Map<String, dynamic>> upcomingBirthdayAnniversary = [
    {
      "title": "Sabir Hussain",
      "consumed": "2nd Anniversary on Feb,26",
      "days": "04",
      "color": Colors.purple,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "title": "Keshav Arya",
      "consumed": "24 Birthday on Jun,20",
      "days": "04",
      "color": Colors.green,
      "icons": "assets/images/profile_img.jpeg",
    },
  ];



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: KCustomAppBar(
          screenTitle: 'Upcoming Events',
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
            Text('Today Events',style: KFonts.normalBold,),
            SizedBox(height: 10,),
            SizedBox(
              height: 120,
              child: ListView.builder(

                  scrollDirection: Axis.horizontal,
                  itemCount: events.length,
                  itemBuilder: (context,index){
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Container(
                            width: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: KColors.appPrimary,
                            ),
                            child: Row(

                              children: [
                                Expanded(
                                  flex: 7,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 6,),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${events[index]["title"]}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: screenWidth * 0.045,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),

                                        Text(
                                          '${events[index]["des"]}',
                                          maxLines: 3,
                                          style: TextStyle(fontSize: screenWidth * 0.035,color: Colors.white, fontWeight: FontWeight.w400, fontFamily: 'Poppins',),
                                        ),

                                        const Spacer(),
                                        Text(
                                          textAlign: TextAlign.end,
                                          '${events[index]["date"]}',
                                          style: TextStyle(fontSize: screenWidth * 0.035,color: Colors.white, fontWeight: FontWeight.w500, fontFamily: 'Poppins',),

                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                    );
                  }),
            ),

            /// ---- Leave balance List UI
            SizedBox(height: 10,),
             Text('Upcoming Birthday & Anniversary',style: KFonts.normalBold,),
            Expanded(
              child: ListView.builder(
                itemCount: upcomingBirthdayAnniversary.length,
                itemBuilder: (context, index) {
                  final leave = upcomingBirthdayAnniversary[index];
                  return UpcomingEventsList(
                    type: leave["title"] ?? '',
                    consumed: leave["consumed"] ?? '',
                    color: leave["color"] ?? Colors.blue,
                    remain:leave["days"] ?? '',
                    iconAsset: leave["icons"] ?? '',
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
class UpcomingEventsList extends StatefulWidget {
  final String type;
  final String consumed;
  final String remain;
  final Color color;
  final String iconAsset;

  const UpcomingEventsList({
    super.key,
    required this.type,
    required this.consumed,
    required this.remain,
    required this.color,
    required this.iconAsset,
  });

  @override
  State<UpcomingEventsList> createState() => _UpcomingEventCardState();
}

class _UpcomingEventCardState extends State<UpcomingEventsList> {
  @override
  Widget build(BuildContext context) {
    
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Card(
      elevation: 0,
      shadowColor: KColors.cardShadowColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 50,
                  width: 45,
                  child: Expanded(
                    flex: 2,
                      child: Image.asset(
                        widget.iconAsset,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.type,
                          maxLines: 2,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(widget.consumed,maxLines: 2,)
                      ],
                    )
                ),

                Expanded(
                  flex: 2,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 1,
                            height: 40,
                            color: KColors.grayLight,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              widget.remain,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: KColors.appPrimary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text('Days')
                          ],
                        )
                      ],
                    )

                ),

              ],
            ),
          ],
        ),
      )
    );
  }
}

