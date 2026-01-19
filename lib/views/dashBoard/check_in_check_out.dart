import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/controllers/check_in_check_out_controller.dart';
import 'package:time_log/models/upcoming_holidays_res.dart';
import 'package:time_log/utils/constants/k_date_and_time.dart';
import 'package:time_log/utils/constants/k_storage_key.dart';
import 'package:time_log/utils/reusable_widgit/k_elevated_button.dart';
import '../../models/chech_in_out_details_res.dart';
import '../../models/dashboard_res.dart';
import '../../models/profile_details_res.dart';
import '../../models/upcoming_leaves_res.dart';
import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_annual_leave_graph.dart';
import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_drawer_menu.dart';
import '../../utils/constants/k_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/constants/k_fonts.dart';
import 'package:intl/intl.dart';
import '../../utils/constants/k_loader.dart';
import '../../utils/constants/k_nav_header.dart';
import '../../utils/constants/k_working_hrs_graph.dart';
import '../../utils/popups/k_material_dialog.dart';

class CheckInCheckOut extends StatefulWidget {
  final ValueNotifier<bool>? isBottomNavVisible;

  const CheckInCheckOut({super.key, this.isBottomNavVisible});

  @override
  State<CheckInCheckOut> createState() => CheckInCheckOutState();
}

class CheckInCheckOutState extends State<CheckInCheckOut> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();
  final CheckInCheckOutController _controller = CheckInCheckOutController();
  final storage = GetStorage();
  List<CheckInOutList> allCheckInOut = []; // original list (from API)
  List<UpcomingLeave> leaveList = [];
  List<Event> eventsList = [];
  List<Holiday> upcomingHolidays = [];
  LstemployeeDetail? employeeData;

  double lat = 0.000;
  double long = 0.000;
  bool _isLoading = false;
  String pendingCount = '';
  String leaveTaken = '';
  String totalWorkingHrs = '';
  final formatter = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserLocation();
      fetchData();
    });
  }

  void _checkInternetConnection() async {
    bool connected = await _checkInternet.isConnected();

    if (!connected) {
      KMaterialDialogs.noInternetFound(
        context,
        IconsButton(
          onPressed: () => Navigator.pop(context),
          text: 'Okay',
          color: Colors.red,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        "No Internet Connection",
        "Please check your internet connection and try again.",
      );
      return;
    }

    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    await Future.wait([
      _fetchProfileDetailsData(),
      _fetchCheckInOutDetails(),
      _fetchLeaveList(),
      _fetchDashboardDetails(),
    ]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void fetchData() {
    _checkInternetConnection();
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: KCustomDrawer.customDrawer(
        context: context,
        title:
            (storage.read(KStorageKey.userName ?? '') ?? '').split(' ').first,
        hello: true,
        subtitle: "Welcome to Ressourcia",
        showBellIcon: true,
        // Show Bell Icon
        showProfileIcon: true, // Hide Profile Icon
      ),
      drawer: CustomDrawerMenu(
        context: context,
        isBottomNavVisible: widget.isBottomNavVisible,
      ),
      onDrawerChanged: (isOpened) {
        // 👇 hide when drawer opens, show when closes
        widget.isBottomNavVisible?.value = !isOpened;
      },
      body: _isLoading
          ? KLoader()
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
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

                            ///--- Check out UI
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  /*SizedBox(
                                            height: 160,
                                            child: _buildAnnualLeaveChart()),*/
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.25, // 35% of screen height
                                    child: _buildAnnualLeaveChart(),
                                  ),
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
                                      "color": Colors.yellow,
                                      "text": "Self Study Hours"
                                    },
                                  ]),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                      child: _buildWorkingHoursChart()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )),
    );
  }

  ///--- Annual Leave Chart
  Widget _buildAnnualLeaveChart() {
    return KAnnualLeaveGraph();
  }

  ///--- Working Hours Chart
  Widget _buildWorkingHoursChart() {
    return KWorkingHrsGraph();
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
    print("CHECK");

    bool shouldShowCard = true;

    // Check if there’s an existing check-in record
    if (allCheckInOut != null && allCheckInOut.isNotEmpty) {
      var latestCheck = allCheckInOut[0];

      // Assuming latestCheck.checkInTime holds your check-in datetime string
      String checkIn = latestCheck.checkInTime ?? "";

      if (checkIn.isNotEmpty) {
        try {
          final format = new DateFormat("yyyy-MM-dd, hh:mm:ss a");
          DateTime checkInTime = format.parse(checkIn.trim());
          DateTime now = DateTime.now();

          bool isSameDate = checkInTime.year == now.year &&
              checkInTime.month == now.month &&
              checkInTime.day == now.day;

          // Hide the card if already checked in today
          shouldShowCard =
              !(latestCheck.checkInCheckOut ?? true) || !isSameDate;
        } catch (e) {
          print("Date parsing error in _startCheckIn: $e");
        }
      }
    }

    return Column(
      children: [
        Visibility(
          visible: shouldShowCard,
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
                    const SizedBox(height: 20),
                    const Text(
                      "Your Shift is open",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: SvgPicture.asset('assets/icons/watch_icon.svg'),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<String>(
                      stream: KDateAndTime().getCurrentTime(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? '',
                          style: const TextStyle(
                            fontSize: 36,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        controller: _controller.descriptionController,
                        maxLines: 10,
                        minLines: 1,
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
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                          color: KColors.textColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: _isLoading
                          ? const KLoader()
                          : CustomElevatedButtonCheckInOut(
                              text: "START CHECK-IN",
                              onPressed: () async {
                                setState(() {
                                  // _isLoading = true;
                                });

                                await _controller.checkIn(
                                  context,
                                  _controller.descriptionController.text,
                                  lat,
                                  long,
                                );
                                final now = DateTime.now();
                                storage.write(
                                    'lastCheckInDate', now.toIso8601String());
                                _controller.descriptionController.clear();
                                _fetchCheckInOutDetails();

                                setState(() {
                                  //_isLoading = false;
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
                          const SizedBox(width: 10),
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
    bool shouldShowCheckOut = false;
    if (allCheckInOut.isNotEmpty) {
      var latestCheck = allCheckInOut[0];

      bool isCheckedIn = latestCheck.checkInCheckOut ?? false;
      String checkIn = latestCheck.checkInTime ?? "";

      if (checkIn.isNotEmpty && isCheckedIn) {
        try {
          final format =
              DateFormat("yyyy-MM-dd, hh:mm:ss a"); // match your actual format
          DateTime checkInTime = format.parse(checkIn.trim());
          DateTime now = DateTime.now();

          bool isSameDate = checkInTime.year == now.year &&
              checkInTime.month == now.month &&
              checkInTime.day == now.day;

          // ✅ Show Check-Out only if user is checked in AND it's the same date
          shouldShowCheckOut = isCheckedIn && isSameDate;
        } catch (e) {
          print("Date parsing error in _startCheckOut: $e");
        }
      }
    }

    return Column(
      children: [
        Visibility(
          visible: shouldShowCheckOut,
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
                    const SizedBox(height: 20),
                    const Text(
                      "Your Work for",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: SvgPicture.asset('assets/icons/watch_icon.svg'),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<int>(
                      stream: Stream.periodic(
                          const Duration(seconds: 1), (count) => count),
                      builder: (context, snapshot) {
                        return Text(
                          allCheckInOut.isEmpty
                              ? ''
                              : KDateAndTime().getTimeDifferenceFromNow(
                                  allCheckInOut[0].checkInTime),
                          style: const TextStyle(
                            fontSize: 36,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        maxLines: 10,
                        minLines: 1,
                        maxLength: 250,
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
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                          color: KColors.textColor,
                        ),
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
                                  //_isLoading = true;
                                });

                                await _controller.checkOut(
                                  context,
                                  _controller.descriptionController.text,
                                  lat,
                                  long,
                                );
                                _controller.descriptionController.clear();
                                _fetchCheckInOutDetails();
                                _fetchDashboardDetails();

                                setState(() {
                                  //_isLoading = false;
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
                          const SizedBox(width: 10),
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
                  child: InkWell(
                    onTap: () {
                      final description = allCheckInOut.isNotEmpty
                          ? allCheckInOut[0].checkIndescription ?? ''
                          : '';

                      if (description.length > 400) {
                        showDialog(
                          context: context,
                          builder: (context) => CheckInOutDetailsInDialog(
                            des: allCheckInOut[0].checkIndescription,
                            location: allCheckInOut[0].checkInLocation,
                            date: allCheckInOut[0].checkInTime,
                            type: "Check-In",
                          ),
                        );
                      }
                    },
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
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
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
                              child: SvgPicture.asset(
                                  'assets/icons/timer_icon.svg'),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Text(
                                allCheckInOut.isNotEmpty
                                    ? KDateAndTime()
                                        .formatCustomDateMonthYearWithTime(
                                            allCheckInOut[0]
                                                    .checkInTime
                                                    .toString() ??
                                                '')
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
                  child: InkWell(
                    onTap: () {
                      final description = allCheckInOut.isNotEmpty
                          ? allCheckInOut[0].checkOutdescription ?? ''
                          : '';
                      if (description.length > 400) {
                        showDialog(
                          context: context,
                          builder: (context) => CheckInOutDetailsInDialog(
                            des: allCheckInOut[0].checkOutdescription,
                            location: allCheckInOut[0].checkOutLocation,
                            date:
                                allCheckInOut[0].checkOutTime.toString() ?? '',
                            type: "Check-Out",
                          ),
                        );
                      }
                    },
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
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
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
                              child: SvgPicture.asset(
                                  'assets/icons/timer_icon.svg'),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Text(
                                allCheckInOut.isNotEmpty
                                    ? KDateAndTime()
                                        .formatCustomDateMonthYearWithTime(
                                            allCheckInOut[0]
                                                    .checkOutTime
                                                    .toString() ??
                                                '')
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
                  ),
                )),
          ),
        ],
      ),
    );
  }

  //check for today check in
  bool isTodayCheckIn(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return false;

    try {
      final format = DateFormat("yyyy-MM-dd, hh:mm:ss a");
      final dateTime = format.parse(dateTimeStr.trim());
      final now = DateTime.now();

      return dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day;
    } catch (e) {
      debugPrint("Date parse error: $e");
      return false;
    }
  }

  ///-- fetch check in out details
  Future<void> _fetchCheckInOutDetails() async {
    final res = await getCheckInOutDetails(context);
    if (!mounted) return;

    setState(() {
      if (res is CheckInOutResponse) {
        allCheckInOut = res.checkInOutDetails;
        storage.write(
            KStorageKey.attendeeId, allCheckInOut[0].checkInCheckOutId);
        print('##CHECK_OUT:${allCheckInOut[0].checkInCheckOut}');
        print('##AttendeeID:${storage.read(KStorageKey.attendeeId)}');
      } else {
        allCheckInOut = [];
      }
      //_isLoading = false;
    });
  }

  /// --- fetch upcoming leave list from SF.
  Future<void> _fetchLeaveList() async {
    var response = await getUpcomingLeaves(context);

    if (response is UpcomingLeavesResponse) {
      setState(() {
        leaveList = response.data;
        //_isLoading = false;
      });
    } else {
      setState(() {
        //_isLoading = false;
      });
    }
  }

  /// --- check internet connection
  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// --- fetch dashboard details list from SF.
  Future<void> _fetchDashboardDetails() async {
    final response = await getDashboard(context);
    if (response is DashboardResponse) {
      setState(() {
        totalWorkingHrs = response.data.totalWorkingHrs;
        leaveTaken = response.data.totalLeavesTaken;
        pendingCount = response.data.pendingTimeLogEntryCount;
        eventsList = response.data.events ?? [];
        upcomingHolidays = response.data.holidays??[];
        //storage.write(KStorageKey.tWorkingHrsInTHisMonth, totalWorkingHrs ?? '');
        storage.write(KStorageKey.tWorkingHrsInTHisMonth,
            totalWorkingHrs.toString() ?? '');
        storage.write(KStorageKey.leaveTakenInThisMonth, leaveTaken ?? '');
        if (eventsList.isNotEmpty) {
          eventsList.sort((a, b) {
            try {
              return formatter
                  .parse(a.eventDate)
                  .compareTo(formatter.parse(b.eventDate));
            } catch (_) {
              return 0;
            }
          });
        }
        print("#Whrs:$totalWorkingHrs");
      });
    }
  }

  /// --- When location permission will Deny, after that open this dialog, user can click open Setting and allow permission manually.
  normalConfirmationDialog(
      String confirmation, String? title, String? buttonText) {
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
        return KColors.purpleColor;
      case "SL":
        return KColors.greenColor;
      case "LWP":
        return KColors.appPrimary;
      case "Comp off":
        return KColors.pinkColor;
      case "Maternity Leave":
        return KColors.appPrimaryRed;
      case "Paternity Leave":
        return KColors.appPrimaryYellow;
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
                                        : KAssets.anniversary,
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
                                  Text(
                                      formatEventDate(item.eventDate) +
                                              " , " +
                                              item.eventName ??
                                          '',
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

  String formatEventDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('d MMMM yyyy').format(parsedDate);
  }

  /// --- show total working hrs,leave taken this month and pending time log
  Widget _showWorkingHrsAnd() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  Flexible(
                    child: Text(
                      _formatWorkingHours(
                              totalWorkingHrs + " hrs".toString()) ??
                          '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  /*Text(
                    totalWorkingHrs+" hrs" ?? '0',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),*/
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Total working hours this month",
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
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/leave_history_screen');
          },
          child: SizedBox(
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
                        "Leaves Taken in this month",
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
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/time_logs_screen');
          },
          child: SizedBox(
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
        ),
      ],
    );
  }

  /// --- show upcoming leaves
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

  /// --- show upcoming holidays
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

  //Check-out And Check- In Time
  Widget _checkOutForToadyCard() {
    return Visibility(
      visible: allCheckInOut.isNotEmpty &&
          isTodayCheckIn(allCheckInOut[0].checkInTime),
      child: Padding(
        padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
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
                  "Total Hours Logged For Today",
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
                  allCheckInOut.isNotEmpty
                      ? KDateAndTime()
                          .getDifferenceBetweenCheckInAndCheckOutTime(
                          allCheckInOut[0].checkInTime ?? '',
                          allCheckInOut[0].checkOutTime ?? '',
                        )
                      : '',
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
  Future<void> _fetchProfileDetailsData() async {
    final response = await getProfileDetails(context);

    if (response is ProfileDetailsResponse) {
      final dataList = response.data.lstemployeeDetails;

      if (dataList.isEmpty) return;

      employeeData = dataList[0];

      storage.write(KStorageKey.employeeName, employeeData?.employeeName ?? '');
      storage.write(
          KStorageKey.employeeGender, employeeData?.employeeGender ?? '');
      storage.write(
          KStorageKey.employeeMobile, employeeData?.employeePhone ?? '');
      storage.write(
          KStorageKey.employeeEmail, employeeData?.employeeEmail ?? '');
      storage.write(KStorageKey.employeeDOB, employeeData?.employeeDob ?? '');
      storage.write(
        KStorageKey.employeeAnniversary,
        employeeData?.employeeAnniversaryDate ?? '',
      );
      storage.write(
          KStorageKey.employeeAddress, employeeData?.employeeAddress ?? '');
    } else {
      debugPrint("Unexpected response type");
    }
  }

  String _formatWorkingHours(String value) {
    if (value.contains(".")) {
      var parts = value.split(".");
      if (parts[1] == "0" || parts[1] == "00") {
        return parts[0]; // Just hours
      } else {
        return "${parts[0]}:${parts[1].padRight(2, '0')}"; // Hours:Minutes
      }
    }
    return value; // No decimal, show as is
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

/// ---- Open dialog for show details
class CheckInOutDetailsInDialog extends StatelessWidget {
  final String? location;
  final String? des;
  final String? date;
  final String? type;

  const CheckInOutDetailsInDialog(
      {super.key, this.location, this.des, this.date, this.type});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        //width: double.infinity, // Match parent
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 👈 Wrap content height
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
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10, left: 20, right: 20, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type ?? '',
                            style: const TextStyle(
                                color: KColors.appPrimary,
                                fontSize: 16,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            des ?? '',
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
                                  location ?? '',
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
                                child: SvgPicture.asset(
                                    'assets/icons/timer_icon.svg'),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Text(
                                  KDateAndTime()
                                      .formatCustomDateMonthYearWithTime(
                                          date ?? ''),
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
                    ),
                  )),
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, right: 16, left: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop(); // This will close the dialog
                    },
                    child: Text(
                      "Close",
                      style: TextStyle(
                        color: KColors.appPrimaryRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
