import 'package:flutter/material.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/utils/constants/k_date_and_time.dart';
import 'package:time_log/utils/constants/k_loader.dart';
import 'package:time_log/utils/reusable_widgit/k_custom_app_bar.dart';
import 'package:time_log/utils/reusable_widgit/k_size_box.dart';
import '../../models/official_holidays_res.dart';
import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/popups/k_material_dialog.dart';

class HolidayList extends StatefulWidget {
  const HolidayList({super.key});

  @override
  State<HolidayList> createState() => _HolidayListState();
}

class _HolidayListState extends State<HolidayList> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();
  List<OfficialHolidays> officialHolidays = [];
  bool _isLoading = false;

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
  void initState() {
    _checkInternetConnection();
    super.initState();
  }

  /// --- check internet connection
  void _checkInternetConnection() async {
    bool connected = await _checkInternet.isConnected();
    if (!connected) {
      // Show no internet dialog or handle no connectivity case
      KMaterialDialogs.noInternetFound(
        context,
        IconsButton(
          onPressed: () {
            Navigator.pop(context);
            // Maybe retry or do something else
          },
          text: 'Okay',
          color: Colors.red,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        "No Internet Connection",
        "Please check your internet connection and try again.",
      );
      return; // Stop further API calls
    }
    fetchOfficialHolidays();
  }

  void fetchOfficialHolidays() async {
    setState(() {
      _isLoading = true;
    });
    var result = await getOfficialHolidays(context);
    print('Official_Holidays: $result');

    if (result is OfficialHolidaysResponse) {
      setState(() {
        officialHolidays = result.holidays;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // You may also want to show an error message here
    }
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
        child: _showOfficialHolidaysInListView(),
      ),
    );
  }



  Widget _showOfficialHolidaysInListView() {
    return _isLoading? KLoader():ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: officialHolidays.length,
      itemBuilder: (context, index) {
        final item = officialHolidays[index];
        return officialHolidays.isEmpty
          ?const Center(child: Text("No data found!")):
         Column(
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
                             const SizedBox(height: 2),
                             Text(
                               KDateAndTime().getMonthName(item.formattedDate) ?? '',
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
                                     KDateAndTime().getDateNumber(item.formattedDate) ?? '',
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
                             const SizedBox(height: 5),
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
                       item.holidayTitle ?? '',
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
                           KDateAndTime().getDayName(item.formattedDate) ?? '',
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
         );
      },
    );
  }

}
