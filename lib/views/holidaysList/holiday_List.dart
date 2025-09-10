import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _refreshData() async {
    // Your logic to refresh data
    await Future.delayed(
        Duration(seconds: 1)); // Simulate API call or database load
    setState(() {
      fetchOfficialHolidays();
    });
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
          color: KColors.appPrimaryRed,
          textStyle: const TextStyle(color: KColors.appColorWhite),
          iconColor: KColors.appColorWhite,
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
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF84DBFF),
          statusBarIconBrightness: Brightness.dark,
        ),
        title: KCustomAppBar(
          screenTitle: 'Holiday List 2025',
          showHistory: false,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.only(top: 14, right: 16, left: 16),
          child: _showOfficialHolidaysInListView(),
        ),
      ),
    );
  }

  Widget _showOfficialHolidaysInListView() {
    return _isLoading
        ? KLoader()
        : ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: officialHolidays.length + 1,
      itemBuilder: (context, index) {
        if (index < officialHolidays.length) {
          final item = officialHolidays[index];
          return Column(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.21,
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
                              (KDateAndTime()
                                    .getMonthName(item.formattedDate) ??
                                    '').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.07,
                                width: MediaQuery.of(context).size.width * 0.18,
                                child: Card(
                                  color: getCardColor(index),
                                  shadowColor: KColors.cardShadowColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(5.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      KDateAndTime().getDateNumber(
                                          item.formattedDate) ??
                                          '',
                                      style: const TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                               SizedBox(height: MediaQuery.of(context).size.height * 0.001),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                 SizedBox(width: MediaQuery.of(context).size.width * 0.06,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.holidayTitle ?? '',
                        style: const TextStyle(
                          color: KColors.appBlackColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Card(
                        color: getCardColor(index),
                        shadowColor: KColors.cardShadowColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.height * 0.12,
                          child: Padding(
                            padding:
                             EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height * 0.01,),
                            child: Text(
                              KDateAndTime()
                                  .getDayName(item.formattedDate) ??
                                  '',
                              style: const TextStyle(
                                color: KColors.appColorWhite,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (index != officialHolidays.length - 1)
                const Divider(
                  color: KColors.grayLight,
                  thickness: 1,
                ),
            ],
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 20),
            child: Card(
              elevation: 0,
              color: KColors.appColorWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Note',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Colors.pink,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text:
                        'Apart from Holidays, Company provides the RH (Restricted Holiday) of Employee\'s ',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: KColors.appBlackColor,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Marriage Anniversary',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: KColors.appBlackColor,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Birthday',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:KColors.appBlackColor,
                            ),
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

}
