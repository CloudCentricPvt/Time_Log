import 'package:flutter/material.dart';
import 'package:time_log/utils/reusable_widgit/k_custom_app_bar.dart';
import 'package:time_log/utils/reusable_widgit/k_size_box.dart';
import '../../utils/constants/k_colors.dart';

class HolidayList extends StatefulWidget {
  const HolidayList({super.key});

  @override
  State<HolidayList> createState() => _HolidayListState();
}

class _HolidayListState extends State<HolidayList> {
  final List<Map<String, String>> events = [
    {"title": "New Year","month": "JANUARY","date": "05", "year": "2025", "days": "Sunday" },
    {"title": "Republic Day","month": "FEBRUARY","date": "19", "year": "2025", "days": "Sunday" },
    {"title": "Independence Day","month": "JUN","date": "22", "year": "2025", "days": "Sunday" },
    {"title": "New Year","month": "MARCH","date": "29", "year": "2025", "days": "Sunday" },
    {"title": "New Year","month": "DEC","date": "17", "year": "2025", "days": "Sunday" },
    {"title": "New Year","month": "OCT","date": "11", "year": "2025", "days": "Sunday" },
    {"title": "New Year","month": "OCT","date": "15", "year": "2025", "days": "Sunday" },

  ];

  // Define a list of different-2 colors
  final List<Color> cardColors = [
    KColors.orangeColor,
    KColors.greenColor,
    KColors.pinkColor,
    KColors.purpleColor,
    KColors.appPrimary,
    KColors.appPrimaryYellow,
    KColors.pinkColor,
  ];

  // Function to get color based on index (cycles through the list)
  Color getCardColor(int index) {
    List<Color> colors = [
      KColors.orangeColor,
      KColors.greenColor,
      KColors.pinkColor,
      KColors.purpleColor,
      KColors.appPrimaryRed, // Add more colors as needed
      KColors.appStatusBarColor,
    ];

    return colors[(index ~/ 2) % colors.length]; // Alternate colors in pairs
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: KCustomAppBar(screenTitle: 'Holiday List 2025',showHistory: false,),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 14, right: 16, left: 16),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: events.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(2),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Card(
                              elevation: 2,
                              color: KColors.appColorWhite,
                              shadowColor: KColors.cardShadowColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    events[index]["month"] ?? "",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Card(
                                      color: getCardColor(index),
                                      // Apply dynamic color
                                      shadowColor: KColors.cardShadowColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          events[index]["date"] ?? "",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // Ensure text is visible
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      KSizedBox.w14,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            events[index]["title"] ?? "",
                            style: const TextStyle(
                              color: KColors.textHeadingColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Card(
                            color: getCardColor(index), // Apply dynamic color
                            shadowColor: KColors.cardShadowColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                events[index]["days"] ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(
                    color: KColors.grayLight,
                    thickness: 1,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
