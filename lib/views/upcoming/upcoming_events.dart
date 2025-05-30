import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/utils/constants/k_date_and_time.dart';
import 'package:time_log/utils/constants/k_fonts.dart';
import 'package:time_log/utils/constants/k_loader.dart';

import '../../models/dashboard_res.dart';
import '../../models/upcoming_leaves_res.dart';
import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/popups/k_material_dialog.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';

class UpcomingEvents extends StatefulWidget {
  const UpcomingEvents({super.key});

  @override
  State<UpcomingEvents> createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends State<UpcomingEvents> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();

  List<Event> eventsList = [];
  List<Event> todayEvents = [];
  bool _isLoading = true;
  List<bool> expandedCards = [];

  @override
  void initState() {
    _checkInternetConnection();
    super.initState();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _fetchEvents();
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
          color: Colors.red,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        "No Internet Connection",
        "Please check your internet connection and try again.",
      );
      return; // Stop further API calls
    }
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF84DBFF), // Same as app bar
          statusBarIconBrightness:
              Brightness.dark, // or .light depending on contrast
        ),
        title: KCustomAppBar(
          screenTitle: 'Upcoming Events',
          showHistory: false,
          onHistoryTap: () {
            Navigator.pushNamed(context, '/leave_history_screen');
          },
        ),
      ),
      body: _isLoading
          ? KLoader()
          : eventsList.isEmpty
              ? const Center(
                  child: Text("No Upcoming events found!"),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                            visible: eventsList.isEmpty ? false : true,
                            child: Text(
                              'Today Events',
                              style: KFonts.normalBold,
                            )),
                        SizedBox(
                          height: 10,
                        ),

                        _showTodayEvents(),

                        /// ---- Leave balance List UI
                        SizedBox(
                          height: 10,
                        ),

                        Visibility(
                            visible: eventsList.isEmpty ? false : true,
                            child: Text(
                              'Upcoming Birthday & Anniversary',
                              style: KFonts.normalBold,
                            )),

                        //_showUpcomingBirthdayAndAnniversary(),
                        SizedBox(
                          height: 10,
                        ),
                        _showUpcomingEvents()
                      ],
                    ),
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
        return Colors.grey; // Default color if no match
    }
  }

  /// --- get all events from the backend
  Future<void> _fetchEvents() async {
    final response = await getDashboard(context);
    if (response is DashboardResponse) {
      setState(() {

        eventsList = response.data.events;
        print('#Events List1');
        todayEvents = response.data.todayEvents;
        expandedCards = List.generate(todayEvents.length, (index) => false);
        _isLoading = false;
        print('#Events List2');
        print('#Today events:$todayEvents');
      });
    }
  }

  /// ---  show Today events
  Widget _showTodayEvents() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Visibility(
      visible: eventsList.isEmpty ? false : true,
      child: SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: todayEvents.length,
          itemBuilder: (context, index) {
            final item = todayEvents[index];

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                width: screenWidth * 0.90,
                child: Card(
                  elevation: 0,
                  color: KColors.appPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.eventDescription ?? " ",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            letterSpacing: 1,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.personName ?? '',
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            KDateAndTime().useFormatDateInMyApp(
                                todayEvents[0].eventDate.toString() ?? ''),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// ---  show anniversary and birthday
  Widget _showUpcomingEvents() {
    return Visibility(
      visible: eventsList.isNotEmpty,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          // prevent inner scroll
          itemCount: eventsList.length,
          separatorBuilder: (context, index) => SizedBox(height: 10),
          // space between cards
          itemBuilder: (context, index) {
            final item = eventsList[index];
            return Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: KColors.appColorWhite,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: KColors.cardShadowColor,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 65,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Image.asset(
                          item.eventName == "Birthday"
                              ? KAssets.birthday_image
                              : KAssets.anniversary,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.personName ?? '',
                              style: KFonts.normalHeading),
                          SizedBox(height: 5),
                          Text(item.eventName ?? '', style: KFonts.thin),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Container(
                              width: 2, height: 30, color: KColors.colorGray),
                          SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                (item.remainingDays ?? '').toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: KColors.appPrimary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text('Days'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 7,
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
                          Text(
                            widget.consumed,
                            maxLines: 2,
                          )
                        ],
                      )),
                  Expanded(
                      flex: 3,
                      child: Row(
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
                      )),
                ],
              ),
            ],
          ),
        ));
  }
}
