import 'package:flutter/material.dart';
import 'package:time_log/utils/constants/k_date_and_time.dart';
import 'package:time_log/utils/constants/k_fonts.dart';
import 'package:time_log/utils/constants/k_loader.dart';

import '../../models/dashboard_res.dart';
import '../../models/upcoming_leaves_res.dart';
import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';

class UpcomingEvents extends StatefulWidget {
  const UpcomingEvents({super.key});

  @override
  State<UpcomingEvents> createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends State<UpcomingEvents> {
  List<Event> eventsList = [];
  bool _isLoading = true;
  List<bool> expandedCards = [];

  @override
  void initState() {
    _fetchEvents();
    super.initState();
  }

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
      body: _isLoading
          ? KLoader()
          : eventsList.isEmpty
              ? const Center(
                  child: Text("No Upcoming events found!"),
                )
              : Padding(
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

                      _showUpcomingBirthdayAndAnniversary(),
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
        return Colors.grey; // Default color if no match
    }
  }

  /// --- get all events from the backend
  Future<void> _fetchEvents() async {
    final response = await getDashboard(context);
    if (response is DashboardResponse) {
      setState(() {
        eventsList = response.data.events;
        expandedCards = List.generate(eventsList.length, (index) => false);
        _isLoading = false;
        print('Check working hrs');
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
        height: 165, // Max height needed when a card is expanded
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: eventsList.length,
          itemBuilder: (context, index) {
            final events = eventsList[index];
            final isExpanded = expandedCards[index];

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: screenWidth * 0.90,
                  height: isExpanded ? 230 : 140,
                  // Vary height dynamically
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: KColors.appPrimary,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            events.eventName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: screenWidth * 0.045,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        const SizedBox(height: 0),
                        Text(
                          'Wishing you and your family a vibrant and joyous Holi filled with colors of happiness, love, and laughter. May this festival of colors bring new energy and positivity to your life. Happy Holi!',
                          maxLines: isExpanded ? 4 : 2,
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              expandedCards[index] = !expandedCards[index];
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              isExpanded ? 'Show less' : 'Read more',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            KDateAndTime()
                                .useFormatDateInMyApp(events.eventDate ?? ''),
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
  Widget _showUpcomingBirthdayAndAnniversary() {
    return Visibility(
      visible: eventsList.isEmpty ? false : true,
      child: Expanded(
        child: ListView.builder(
          itemCount: eventsList.length,
          itemBuilder: (context, index) {
            final events = eventsList[index];
            return UpcomingEventsList(
              type: events.personName ?? '',
              consumed: events.eventName ?? '',
              color: KColors.appPrimary,
              remain: KDateAndTime().getDay(events.eventDate ?? ''),
              iconAsset: events.eventName == "Birthday"
                  ? KAssets.birthday_image
                  : KAssets.aniversary_image,
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
