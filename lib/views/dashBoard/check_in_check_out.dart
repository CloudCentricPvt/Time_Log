
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:time_log/controllers/check_in_check_out_controller.dart';
import 'package:time_log/utils/reusable_widgit/k_elevated_button.dart';
import 'package:time_log/utils/reusable_widgit/k_upcoming_holidays.dart';
import '../../utils/constants/k_drawer_menu.dart';
import '../../utils/constants/k_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/constants/k_loader.dart';
import '../../utils/constants/k_nav_header.dart';
import '../../utils/reusable_widgit/k_upcoming_events.dart';


class CheckInCheckOut extends StatefulWidget {
  const CheckInCheckOut({super.key});

  @override
  State<CheckInCheckOut> createState() => _CheckInCheckOutState();
}

class _CheckInCheckOutState extends State<CheckInCheckOut> {
  final CheckInCheckOutController _controller = CheckInCheckOutController();
  String lat = '25.36522';
  String long = '21.35855';
  double lat1 = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    //getLocation();
  }

  final List<Map<String, dynamic>> upcomingBirthdayAnniversary = [
    {
      "title": "SABIR HUSSAIN ANSARI",
      "consumed": "2nd Anniversary on Feb,26",
      "days": "04",
      "color": KColors.appColorWhite,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "title": "EID-UL-FITER",
      "consumed": "24 Birthday on Jun,20",
      "days": "16",
      "color": KColors.appColorWhite,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "title": "Rohit",
      "consumed": "5 days Consumed",
      "days": "01",
      "color": KColors.appColorWhite,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "title": "Maternity Leave",
      "consumed": "5 days Consumed",
      "days": "09",
      "color": KColors.appColorWhite,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "title": "Earn Leave",
      "consumed": "5 days Consumed",
      "days": "06",
      "color": KColors.appColorWhite,
      "icons": "assets/images/profile_img.jpeg",
    },
    {
      "title": "Paternity Leave",
      "consumed": "5 days Consumed",
      "days": "03",
      "color": KColors.appColorWhite,
      "icons": "assets/images/profile_img.jpeg",
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

 /* void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    //lat1 = position.latitude;
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KCustomDrawer.customDrawer(
        context: context,
        title: "Hello Sabir",
        subtitle: "Welcome to TimeSync",
        showBellIcon: true,
        // Show Bell Icon
        showProfileIcon: true, // Hide Profile Icon
      ),
      drawer: CustomDrawerMenu(context: context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      color: KColors.appPrimary,
                      width: double.infinity,
                      height: 65,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                  height: 100,
                                  width: 120,
                                  child: Card(
                                    elevation: 2,
                                    color: KColors.appSkyGary,
                                    shadowColor: KColors.cardShadowColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: const Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "120hrs",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Total working hours this months",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: KColors.textColorGray),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              SizedBox(
                                  height: 100,
                                  width: 120,
                                  child: Card(
                                    elevation: 2,
                                    color: KColors.appLightBlue,
                                    shadowColor: KColors.cardShadowColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: const Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "04",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Leaves Taken in this months",
                                            style: TextStyle(
                                              color: KColors.textColorGray,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                              SizedBox(
                                  height: 100,
                                  width: 120,
                                  child: Card(
                                    elevation: 2,
                                    color: KColors.appLightYellow,
                                    shadowColor: KColors.cardShadowColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: const Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "02",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Pending Time Logs",
                                            style: TextStyle(
                                              color: KColors.textColorGray,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),

                          ///--- Start check in UI
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20, right: 15, left: 15),
                            child: Visibility(
                              visible: true,
                              child: SizedBox(
                                width: double.infinity,
                                child: Card(
                                  color: KColors.appColorWhite,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Text(
                                        "Your Shift is open",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 64,
                                        height: 64,
                                        child: SvgPicture.asset(
                                            'assets/icons/watch_icon.svg'),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        "00:35:00",
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20, bottom: 20),
                                        child: TextFormField(
                                          controller:
                                              _controller.descriptionController,
                                          maxLines: 2,
                                          maxLength: 500,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            labelText:
                                                'Type Check-in Description',
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                                // Border color
                                                width:
                                                    1.0, // Stroke width (1dp)
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide(
                                                color: Colors.blue,
                                                // Border color when focused
                                                width:
                                                    1.0, // Focused stroke width
                                              ),
                                            ),
                                          ),
                                          style: const TextStyle(
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w400,
                                              color: KColors.textColor),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20, bottom: 20),
                                        child: _isLoading
                                            ? const KLoader() // or any custom loader
                                            : CustomElevatedButton(
                                                text: "START CHECK-IN",
                                                onPressed: () async {
                                                  setState(() {
                                                    _isLoading = true;
                                                  });

                                                  await _controller.checkIn(
                                                    context,
                                                    _controller
                                                        .descriptionController
                                                        .text,
                                                    lat,
                                                    long,
                                                  );

                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                },
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20, bottom: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: SvgPicture.asset(
                                                  'assets/icons/timer_icon.svg'),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Text(
                                              "10:00 AM to 07:00 PM (Day)",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          ///-- Check out UI
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20, right: 15, left: 15),
                            child: Visibility(
                              visible: false,
                              // only pass isCheckedOut place of false
                              child: SizedBox(
                                width: double.infinity,
                                child: Card(
                                  color: KColors.appColorWhite,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Text(
                                        "Your Work for",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 64,
                                        height: 64,
                                        child: SvgPicture.asset(
                                            'assets/icons/watch_icon.svg'),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        "00:35:00",
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20, bottom: 20),
                                        child: TextFormField(
                                          maxLines: 2,
                                          maxLength: 500,
                                          controller:
                                              _controller.descriptionController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            labelText:
                                                'Type Check-out Description',
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                                // Border color
                                                width:
                                                    1.0, // Stroke width (1dp)
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide(
                                                color: Colors.blue,
                                                // Border color when focused
                                                width:
                                                    1.0, // Focused stroke width
                                              ),
                                            ),
                                          ),
                                          style: const TextStyle(
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w400,
                                              color: KColors.textColor),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20, bottom: 20),
                                        child: _isLoading
                                            ? const KLoader()
                                            : CustomElevatedButton(
                                                text: "CHECK OUT",
                                                onPressed: () async {
                                                  setState(() {
                                                    _isLoading = true;
                                                  });

                                                  await _controller.checkOut(
                                                    context,
                                                    _controller
                                                        .descriptionController
                                                        .text,
                                                    lat,
                                                    long,
                                                  );

                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                }),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20, bottom: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: SvgPicture.asset(
                                                  'assets/icons/timer_icon.svg'),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Text(
                                              "10:00 AM to 07:00 PM (Day)",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          ///--- Your are check out for today UI
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20, right: 15, left: 15),
                            child: SizedBox(
                              width: double.infinity,
                              child: Card(
                                color: KColors.appColorWhite,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      "Your are check out for today",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: 64,
                                      height: 64,
                                      child: SvgPicture.asset(
                                          'assets/icons/watch_icon.svg'),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "00:35:00",
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),

                                    ///-- Check-In UI details
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, right: 15, left: 15),
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            // Background color
                                            border: Border.all(
                                              color: Colors.grey,
                                              // Border color
                                              width: 1.0, // Border width
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                5), // Rounded corners
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10,
                                                left: 20,
                                                right: 20,
                                                bottom: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Check-In",
                                                  style: TextStyle(
                                                      color: KColors.appPrimary,
                                                      fontSize: 16,
                                                      fontFamily: "Poppins",
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                const SizedBox(height: 10),
                                                const Text(
                                                  "This is Check-in Description-In",
                                                  style: TextStyle(
                                                      color: KColors.textColor,
                                                      fontSize: 12,
                                                      fontFamily: "Poppins",
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                      width: 12,
                                                      height: 12,
                                                      child: SvgPicture.asset(
                                                          'assets/icons/location_icon.svg'),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    const Expanded(
                                                      child: Text(
                                                        "Noida Sector 63- 201301",
                                                        style: TextStyle(
                                                            color: KColors
                                                                .textColor,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Poppins",
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    SizedBox(
                                                      width: 12,
                                                      height: 12,
                                                      child: SvgPicture.asset(
                                                          'assets/icons/timer_icon.svg'),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    const Expanded(
                                                      child: Text(
                                                        "Feb 26, 2025 | 09:56:00 AM",
                                                        style: TextStyle(
                                                            color: KColors
                                                                .textColor,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Poppins",
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          )),
                                    ),

                                    ///-- Check-Out UI details
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, right: 15, left: 15),
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            // Background color
                                            border: Border.all(
                                              color: Colors.grey,
                                              // Border color
                                              width: 1.0, // Border width
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                5), // Rounded corners
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10,
                                                left: 20,
                                                right: 20,
                                                bottom: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Check-Out",
                                                  style: TextStyle(
                                                      color: KColors.appPrimary,
                                                      fontSize: 16,
                                                      fontFamily: "Poppins",
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                const SizedBox(height: 10),
                                                const Text(
                                                  "This is Check-out Description-In",
                                                  style: TextStyle(
                                                      color: KColors.textColor,
                                                      fontSize: 12,
                                                      fontFamily: "Poppins",
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                      width: 12,
                                                      height: 12,
                                                      child: SvgPicture.asset(
                                                          'assets/icons/location_icon.svg'),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    const Expanded(
                                                      child: Text(
                                                        "Noida Sector 63- 201301",
                                                        style: TextStyle(
                                                            color: KColors
                                                                .textColor,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Poppins",
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    SizedBox(
                                                      width: 12,
                                                      height: 12,
                                                      child: SvgPicture.asset(
                                                          'assets/icons/timer_icon.svg'),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    const Expanded(
                                                      child: Text(
                                                        "Feb 26, 2025 | 09:56:00 AM",
                                                        style: TextStyle(
                                                            color: KColors
                                                                .textColor,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Poppins",
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          )),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          ///--- Upcoming Leave UI
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Your Upcoming Leaves",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                        width: 100,
                                        child: Card(
                                          elevation: 2,
                                          color: KColors.appColorWhite,
                                          shadowColor: KColors.cardShadowColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "MARCH",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: Card(
                                                  color: KColors.orangeColor,
                                                  shadowColor:
                                                      KColors.cardShadowColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.0)),
                                                  child: const Center(
                                                    child: Text(
                                                      "07",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Text(
                                                "EL",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        )),
                                    SizedBox(
                                        width: 100,
                                        child: Card(
                                          elevation: 2,
                                          color: KColors.appColorWhite,
                                          shadowColor: KColors.cardShadowColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "MAY",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: Card(
                                                  color: KColors.pinkColor,
                                                  shadowColor:
                                                      KColors.cardShadowColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.0)),
                                                  child: const Center(
                                                    child: Text(
                                                      "02",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Text(
                                                "CL",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        )),
                                    SizedBox(
                                        width: 100,
                                        child: Card(
                                          elevation: 2,
                                          color: KColors.appColorWhite,
                                          shadowColor: KColors.cardShadowColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "JULY",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: Card(
                                                  color: KColors.greenColor,
                                                  shadowColor:
                                                      KColors.cardShadowColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.0)),
                                                  child: const Center(
                                                    child: Text(
                                                      "15",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Text(
                                                "EL",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          ///--- Upcoming Events UI
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Upcoming Events",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  child: const Text(
                                    "Read more",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: KColors.appPrimary),
                                  ),
                                  onTap: (){Navigator.pushNamed(context, '/upcoming_events_screen');},
                                ),
                              ],
                            ),
                          ),

                          /// --- show upcoming events
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 8),
                            child: SizedBox(
                              height: 72,
                              child: KUpcomingEvents(
                                  upcomingItems: upcomingBirthdayAnniversary),
                            ),
                          ),

                          /// --- upcoming holidays Test title.

                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Upcoming Holidays",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                    child: const Text(
                                  "Read more",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: KColors.appPrimary),
                                ),
                                  onTap: (){Navigator.pushNamed(context, '/holiday_list_screen');},
                                ),
                              ],
                            ),
                          ),

                          /// --- show Holidays list
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 8),
                            child: SizedBox(
                              height: 98,
                              child: KUpcomingHolidays(upcomingItems: holidays),
                            ),
                          ),

                          ///--- flow chart
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "Annual Leave Details",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                buildLegend([
                                  {
                                    "color": Colors.blue,
                                    "text": "Monthly Leave"
                                  },
                                  {
                                    "color": Colors.yellow,
                                    "text": "Annual Leave"
                                  },
                                  {
                                    "color": Colors.red,
                                    "text": "Comp Off Request"
                                  },
                                  {
                                    "color": Colors.green,
                                    "text": "WFH Request"
                                  },
                                ]),
                                const SizedBox(height: 10),
                                _buildAnnualLeaveChart(),
                                const SizedBox(height: 20),
                                const Text(
                                  "Working Hours Details",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                buildLegend([
                                  {
                                    "color": Colors.blue,
                                    "text": "Working Hours"
                                  },
                                  {
                                    "color": Colors.orange,
                                    "text": "Self Study Hours"
                                  },
                                ]),
                                const SizedBox(height: 10),
                                _buildWorkingHoursChart(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///--- Annual Leave Chart
  Widget _buildAnnualLeaveChart() {
    return _buildChart(
      [
        LineChartBarData(
          spots: [
            const FlSpot(1, 1.0), // January
            const FlSpot(2, 0.5), // March
            const FlSpot(3, 0.0), // May
            const FlSpot(4, 0.0), // July
            const FlSpot(5, 0.0), // September
            const FlSpot(6, 0.0), // December
          ],
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }

  ///--- Working Hours Chart
  Widget _buildWorkingHoursChart() {
    return _buildChart(
      [
        LineChartBarData(
          spots: [
            const FlSpot(1, 200), // January
            const FlSpot(2, 100), // March
            const FlSpot(3, 50), // May
            const FlSpot(4, 0), // July
            const FlSpot(5, 0), // September
            const FlSpot(6, 0), // December
          ],
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(show: false),
        ),
        LineChartBarData(
          spots: [
            const FlSpot(1, 50), // January
            const FlSpot(2, 25), // March
            const FlSpot(3, 10), // May
            const FlSpot(4, 0), // July
            const FlSpot(5, 0), // September
            const FlSpot(6, 0), // December
          ],
          isCurved: true,
          color: Colors.orange,
          barWidth: 2,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }

  ///--- General Chart Builder
  Widget _buildChart(List<LineChartBarData> lineBarsData) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: KColors.appColorWhite,
        borderRadius: BorderRadius.circular(4),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = [
                    "",
                    "January",
                    "March",
                    "May",
                    "July",
                    "September",
                    "December"
                  ];
                  return SideTitleWidget(
                    axisSide: meta.axisSide, // ✅ Required argument
                    fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                    child: Text(
                      months[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                interval: 1,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: lineBarsData,
        ),
      ),
    );
  }

  Widget buildLegend(List<Map<String, dynamic>> items) {
    return Wrap(
      spacing: 12, // Space between legend items
      runSpacing: 8, // Space between rows if wrapped
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 12,
              decoration: BoxDecoration(
                color: item["color"],
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            const SizedBox(width: 5),
            Text(item["text"], style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}
