import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/controllers/check_in_check_out_controller.dart';
import 'package:time_log/models/dashboard_res.dart';
import 'package:time_log/utils/constants/k_date_and_time.dart';
import 'package:time_log/utils/constants/k_storage_key.dart';
import 'package:time_log/utils/reusable_widgit/k_elevated_button.dart';
import '../../models/chech_in_out_details_res.dart';
import '../../models/profile_details_res.dart';
import '../../models/upcoming_leaves_res.dart';
import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_drawer_menu.dart';
import '../../utils/constants/k_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/constants/k_fonts.dart';
import '../../utils/constants/k_loader.dart';
import '../../utils/constants/k_nav_header.dart';
import '../../utils/popups/k_material_dialog.dart';

class CheckInCheckOut extends StatefulWidget {
  const CheckInCheckOut({super.key});

  @override
  State<CheckInCheckOut> createState() => _CheckInCheckOutState();
}

class _CheckInCheckOutState extends State<CheckInCheckOut> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();
  final CheckInCheckOutController _controller = CheckInCheckOutController();
  final storage = GetStorage();
  List<CheckInOutList> allCheckInOut = []; // original list (from API)
  List<UpcomingLeave> leaveList = [];
  List<Event> eventsList = [];
  List<Holiday> upcomingHolidays = [];
  List<Dashboard> dashboardData = [];
  LstemployeeDetail? employeeData;

  double lat = 0.000;
  double long = 0.000;
  bool _isLoading = false;
  String pendingCount = '';
  String leaveTaken = '';
  String totalWorkingHrs = '';



  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _checkInternetConnection();


  }
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
    _fetchProfileDetailsData();
    _fetchCheckInOutDetails();
    _fetchLeaveList();
    _fetchDashboardDetails();
  }

  Future<void> _refreshData() async {
    // Your logic to refresh data
    //await Future.delayed(Duration(seconds: 1)); // Simulate API call or database load
    setState(() {
       _fetchProfileDetailsData();
      _fetchCheckInOutDetails();
      _fetchLeaveList();
      _fetchDashboardDetails();
    });
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: KCustomDrawer.customDrawer(
        context: context,
        title: storage.read(KStorageKey.userName ??''),
        hello: true,
        subtitle: "Welcome to TimeSync",
        showBellIcon: true,
        // Show Bell Icon
        showProfileIcon: true, // Hide Profile Icon
      ),
      drawer: CustomDrawerMenu(context: context),
      body: _isLoading
          ? KLoader()
          : RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
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
                                  /// --- show total working hrs, leave taken this month, pending time log
                                  _showWorkingHrsAnd(),

                                  ///--- Start check in UI
                                  _startCheckIn(),

                                  ///-- Check out UI
                                  _startCheckOut(),

                                  ///--- Your are check out for today UI
                                  _checkOutForToadyCard(),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  ///--- Upcoming Leave UI
                                  _upcomingLeave(),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  /// --- show upcoming events
                                  _showUpcomingEvents(),

                                  /// --- upcoming holidays Test title.
                                  const SizedBox(
                                    height: 10,
                                  ),

                                  _upcomingHolidays(),

                                  ///--- flow chart
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20, bottom: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Text(
                                          "Annual Leave Details",
                                          style: KFonts.normalBold,
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
                                          style: KFonts.normalBold,
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
                    axisSide: meta.axisSide, //  Required argument
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

  /// --- get current location
  void _getUserLocation() async {
    Location location = Location();
    bool _serviceEnable;
    PermissionStatus _permissionGranted;
    _serviceEnable = await location.serviceEnabled();
    if (!_serviceEnable) {
      _serviceEnable = await location.requestService();
      if (!_serviceEnable) {
        normalConfirmationDialog(
            'Location is Disable App want to access  your location',
            'Please Enable your Location',
            'Enable Location');
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();

      if (_permissionGranted != PermissionStatus.granted) {
        normalConfirmationDialog(
            'Denied the location permission, please go to setting and give access',
            'Location permission denied',
            'Open Setting');
        return;
      }
    }
    location.onLocationChanged.listen((LocationData CurrentLocation) async {
      setState(() {
        lat = CurrentLocation.latitude!;
        long = CurrentLocation.longitude!;
      });
    });
  }

  ///--- Start Check In
  Widget _startCheckIn() {
    return Column(
      children: [
        Visibility(
          visible: allCheckInOut.isNotEmpty &&
              !(allCheckInOut[0].checkInCheckOut ?? true),
          child: Padding(
            padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
            child: SizedBox(
              width: double.infinity,
              child: Card(
                color: KColors.appColorWhite,
                elevation: 0,
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
                      child: SvgPicture.asset('assets/icons/watch_icon.svg'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      KDateAndTime().getCurrentTime(),
                      //allCheckInOut[0].checkInCheckOut == false ? '0:01:00': "00:00:00",
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
                        controller: _controller.descriptionController,
                        maxLines: 2,
                        maxLength: 500,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          labelText: 'Type Check-in Description',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              // Border color
                              width: 1.0, // Stroke width (1dp)
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              // Border color when focused
                              width: 1.0, // Focused stroke width
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
                          : CustomElevatedButtonCheckInOut(
                              text: "START CHECK-IN",
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });

                                await _controller.checkIn(
                                  context,
                                  _controller.descriptionController.text,
                                  lat,
                                  long,
                                );
                                _controller.descriptionController.clear();
                                _fetchCheckInOutDetails();

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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                SvgPicture.asset('assets/icons/timer_icon.svg'),
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
      ],
    );
  }

  ///--- Start Check out
  Widget _startCheckOut() {
    return Column(
      children: [
        Visibility(
          visible: allCheckInOut.isNotEmpty &&
              (allCheckInOut[0].checkInCheckOut ?? false),
          child: Padding(
            padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
            child: SizedBox(
              width: double.infinity,
              child: Card(
                color: KColors.appColorWhite,
                elevation: 0,
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
                      child: SvgPicture.asset('assets/icons/watch_icon.svg'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      allCheckInOut.isEmpty?'':

                      KDateAndTime().getTimeDifferenceFromNow(
                          allCheckInOut[0].checkInTime),
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
                        controller: _controller.descriptionController,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          labelText: 'Type Check-out Description',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              // Border color
                              width: 1.0, // Stroke width (1dp)
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              // Border color when focused
                              width: 1.0, // Focused stroke width
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
                          : CustomElevatedButtonCheckInOut(
                              text: "CHECK OUT",
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });

                                await _controller.checkOut(
                                  context,
                                  _controller.descriptionController.text,
                                  lat,
                                  long,
                                );
                                _controller.descriptionController.clear();

                                /// --- Refresh the checkInOut details, call this method
                                _fetchCheckInOutDetails();

                                setState(() {
                                  _isLoading = false;
                                });
                              }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                SvgPicture.asset('assets/icons/timer_icon.svg'),
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
      ],
    );
  }

  /// --- Check In Description
  Widget _checkInDetailsUI() {
    return Visibility(
      visible: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
            child: Container(
                width: MediaQuery.of(context).size.width * double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  // Background color
                  border: Border.all(
                    color: Colors.grey,
                    // Border color
                    width: 1.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(5), // Rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 20, right: 20, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Check-In",
                        style: TextStyle(
                            color: KColors.appPrimary,
                            fontSize: 16,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        allCheckInOut.isNotEmpty
                            ? allCheckInOut[0].checkIndescription ?? ''
                            : '',
                        style: TextStyle(
                            color: KColors.textColor,
                            fontSize: 12,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          Expanded(
                            child: Text(
                              allCheckInOut.isNotEmpty
                                  ? allCheckInOut[0].checkInLocation ?? ''
                                  : '',
                              style: TextStyle(
                                  color: KColors.textColor,
                                  fontSize: 12,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child:
                                SvgPicture.asset('assets/icons/timer_icon.svg'),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                              child: Text(
                              allCheckInOut.isNotEmpty
                              ? KDateAndTime().formatCustomDateMonthYearWithTime(allCheckInOut[0].checkInTime.toString() ?? '')
                                  : '',
                              style: TextStyle(
                                  color: KColors.textColor,
                                  fontSize: 12,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  /// --- Check Out Description
  Widget _checkOutDetailsUI() {
    return Visibility(
      visible: allCheckInOut.isNotEmpty &&
          !(allCheckInOut[0].checkInCheckOut ?? true),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
            child: Container(
                width: MediaQuery.of(context).size.width * double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  // Background color
                  border: Border.all(
                    color: Colors.grey,
                    // Border color
                    width: 1.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(5), // Rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 20, right: 20, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Check-Out",
                        style: TextStyle(
                            color: KColors.appPrimary,
                            fontSize: 16,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        allCheckInOut.isNotEmpty
                            ? allCheckInOut[0].checkOutdescription ?? ''
                            : '',
                        style: TextStyle(
                            color: KColors.textColor,
                            fontSize: 12,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          Expanded(
                            child: Text(
                              allCheckInOut.isNotEmpty
                                  ? allCheckInOut[0].checkOutLocation ??
                                      'Location Not found'
                                  : '',
                              style: TextStyle(
                                  color: KColors.textColor,
                                  fontSize: 12,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child:
                                SvgPicture.asset('assets/icons/timer_icon.svg'),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Text(
                              allCheckInOut.isNotEmpty
                                  ? KDateAndTime().formatCustomDateMonthYearWithTime(allCheckInOut[0].checkOutTime.toString() ?? '')
                                  : '',
                              style: TextStyle(
                                color: KColors.textColor,
                                fontSize: 12,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  ///-- fetch check in out details
  Future<void> _fetchCheckInOutDetails() async {
    setState(() {
      _isLoading = true;
    });

    final res = await getCheckInOutDetails(context);

    setState(() {
      if (res is CheckInOutResponse) {
        allCheckInOut = res.checkInOutDetails;
      } else {

        allCheckInOut = [];
      }
      _isLoading = false;
    });
  }

  /// --- fetch upcoming leave list from SF.
  Future<void> _fetchLeaveList() async {
    var response = await getUpcomingLeaves(context);


    if (response is UpcomingLeavesResponse) {
      setState(() {
        leaveList = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// --- check internet connection
  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _fetchDashboardDetails() async {
    final response = await getDashboard(context);
    if (response is DashboardResponse) {
      setState(() {
        totalWorkingHrs = response.data.totalWorkingHrs;
        leaveTaken = response.data.totalLeavesTaken;
        pendingCount = response.data.pendingTimeLogEntryCount;
        eventsList = response.data.events;
        upcomingHolidays = response.data.holidays;
        storage.write(KStorageKey.tWorkingHrsInTHisMonth, totalWorkingHrs?? '');
        storage.write(KStorageKey.leaveTakenInThisMonth, leaveTaken?? '');
      });
    }
  }

  /// --- when location permission will Deny, after that open this dialog, user can click open Setting and allow permission manually.
  normalConfirmationDialog(String confirmation, String? title, String? buttonText) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(confirmation),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (buttonText == 'Open Setting') {
                      AppSettings.openAppSettings();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(buttonText!),
                )
              ],
            ),
          );
        });
  }

  /// --- set color according to leave type.
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
        return Colors.grey; // Default color if no match
    }
  }

  /// --- show upcoming events list
  Widget _showUpcomingEvents() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Visibility(
      visible: eventsList.isEmpty ? false : true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Upcoming Events",
                  style: KFonts.normalBold,
                ),
                InkWell(
                  child: const Text(
                    "Read more",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: KColors.appPrimary),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/upcoming_events_screen');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: SizedBox(
              height: 72,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: eventsList.length,
                  itemBuilder: (context, index) {
                    final item = eventsList[index];
                    return Container(
                      width: screenWidth * 0.8,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: KColors.appColorWhite,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SizedBox(
                        height: 80, // <- Set fixed height to avoid overflow
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    item.eventName == "Birthday"
                                        ? KAssets.birthday_image
                                        : KAssets.aniversary_image,
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.personName ?? '',
                                    style: KFonts.normalHeading,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(item.eventName ?? '',
                                      style: KFonts.thin),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Container(
                                    width: 2,
                                    height: 30,
                                    color: KColors.colorGray,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.remainingDays.toString() ?? '',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: KColors.appPrimary,
                                            fontFamily: 'Poppins'),
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
                  }),
            ),
          ),
        ],
      ),
    );
  }

  /// --- show total working hrs,leave taken this month and pending time log
  Widget _showWorkingHrsAnd() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
            height: 112,
            width: screenWidth * 0.3,
            child: Card(
              elevation: 2,
              color: KColors.appSkyGary,
              shadowColor: KColors.cardShadowColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    totalWorkingHrs ?? '0',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Total working hours this months",
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: KColors.textColorGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )),
        SizedBox(
            height: 112,
            width: screenWidth * 0.3,
            child: Card(
              elevation: 2,
              color: KColors.appLightBlue,
              shadowColor: KColors.cardShadowColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    leaveTaken ?? '0',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Leaves Taken in this months",
                      maxLines: 3,
                      style: TextStyle(
                        color: KColors.textColorGray,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            )),
        SizedBox(
            height: 112,
            width: screenWidth * 0.3,
            child: Card(
              elevation: 2,
              color: KColors.appLightYellow,
              shadowColor: KColors.cardShadowColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    pendingCount ?? '0',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Pending Time Logs",
                      maxLines: 3,
                      style: TextStyle(
                        color: KColors.textColorGray,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _upcomingLeave() {
    return Visibility(
      visible: leaveList.isEmpty ? false : true,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Upcoming Leaves",
              style: KFonts.normalBold,
            ),
            SizedBox(
              height: 8,
            ),
            SizedBox(
              height: 115,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: leaveList.length,
                itemBuilder: (context, index) {
                  final leave = leaveList[index];
                  return UpcomingLeavesCard(
                    month: leave.month,
                    date: leave.startDate.day.toString(),
                    // or format it nicely if needed
                    type: leave.type,
                    cardColor: getLeaveColor(leave.type),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _upcomingHolidays() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Visibility(
      visible: upcomingHolidays.isEmpty ? false : true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Upcoming Holidays",
                  style: KFonts.normalBold,
                ),
                InkWell(
                  child: const Text(
                    "Read more",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: KColors.appPrimary),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/holiday_list_screen');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: SizedBox(
                height: 98,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: upcomingHolidays.length,
                    itemBuilder: (context, index) {
                      final item = upcomingHolidays[index];
                      return Container(
                        width: screenWidth * 0.8,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: KColors.appPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.holidayTitle ?? '',
                                    maxLines: 1,
                                    style: KFonts.normalBoldWithWhite,
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    item.holidayDescription ?? '',
                                    style: KFonts.thinWithWhite,
                                    maxLines: 2,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    item.formattedDate ?? '',
                                    style: KFonts.thinWithWhite,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      );
                    })),
          ),
        ],
      ),
    );
  }

  Widget _checkOutForToadyCard() {
    return Visibility(
      visible: allCheckInOut.isNotEmpty && allCheckInOut[0].checkInTime.isNotEmpty,
      child: Padding(
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

                Text(
                  allCheckInOut.isNotEmpty
                      ? KDateAndTime().getDifferenceBetweenCheckInAndCheckOutTime(
                    allCheckInOut[0].checkInTime ?? '',
                    allCheckInOut[0].checkOutTime ?? '',
                  ) : '',
                  style: const TextStyle(
                    fontSize: 36,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,
                  ),
                ),


                const SizedBox(
                  height: 10,
                ),

                ///-- Check-In UI details
                _checkInDetailsUI(),

                ///-- Check-Out UI details
                _checkOutDetailsUI(),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// --  create method for getting the Employee and manager details.
  void _fetchProfileDetailsData() async {
    final response = await getProfileDetails(context);

    if (response is ProfileDetailsResponse) {
      final dataList = response.data.lstemployeeDetails;

      if (dataList.isEmpty) {
        print("No employee details found");
        return;
      }

      employeeData = dataList[0];
      storage.write(KStorageKey.employeeName, (dataList.isNotEmpty ? employeeData!.employeeName : '') ?? '');
      storage.write(KStorageKey.employeeGender, (dataList.isNotEmpty ? employeeData!.employeeGender : '') ?? '');
      storage.write(KStorageKey.employeeMobile, (dataList.isNotEmpty ? employeeData!.employeePhone : '') ?? '');
      storage.write(KStorageKey.employeeEmail, (dataList.isNotEmpty ? employeeData!.employeeEmail : '') ?? '');
      storage.write(KStorageKey.employeeDOB, (dataList.isNotEmpty ? employeeData!.employeeDob : '') ?? '');
      storage.write(KStorageKey.employeeAnniversary, (dataList.isNotEmpty ? employeeData!.employeeAnniversaryDate : '') ?? '');
      storage.write(KStorageKey.employeeAddress, (dataList.isNotEmpty ? employeeData!.employeeAddress : '') ?? '');
      print('EMP_Name1:${storage.read(KStorageKey.employeeName)}');

      setState(() {
        _isLoading = false;
      });
    } else {
      print("Unexpected response type or failed to parse response");
    }
  }
}

/// --- design upcoming leave with card back ground.
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
        elevation: 0,
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
