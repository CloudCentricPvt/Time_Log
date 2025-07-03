import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/models/annual_leave_details_res.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_loader.dart';
import 'package:time_log/utils/reusable_widgit/k_size_box.dart';
import 'package:time_log/views/leaves/request_comp_off_screen.dart';
import 'package:time_log/views/leaves/request_work_from_home.dart';
import '../../models/dashboard_res.dart';
import '../../models/upcoming_holidays_res.dart';
import '../../models/upcoming_leaves_res.dart';
import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/constants/k_drawer_menu.dart';
import '../../utils/constants/k_fonts.dart';
import '../../utils/constants/k_nav_header.dart';
import '../../utils/popups/k_material_dialog.dart';
import '../../utils/reusable_widgit/k_circular_progress.dart';
import 'apply_leave.dart';
class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => LeaveScreenState();
}

class LeaveScreenState extends State<LeaveScreen> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();
  bool _isLoading = false;
  String leaveBal = '';
  String totalLeaveBal = '';
  String casualLeave = '';
  String sickLeave = '';
  String earnLeave = '';
  String compOff = '';
  int usedLeave1 = 0;

  ///--- Total Leave
  String tEL = '';
  String tCL = '';
  String tSL = '';
  String tCompOff = '';

  /// --- calculate Percentage
  double leaveP = 0.0;
  double clP = 0.0;
  double slP = 0.0;
  double elP = 0.0;
  double compOffP = 0.0;
  List<UpcomingLeave> leaveList = [];
  List<Holiday> upcomingHolidays = [];

  @override
  void initState() {
    super.initState();
    fetchData();
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
    fetchAnnualLeaveDetails();
    fetchLeaveList();
    fetUpcomingHolidays();
  }

  void fetchData() {
    _checkInternetConnection();
  }
  /// --- refresh data when swap down screen
  Future<void> _refreshData() async {
    // Your logic to refresh data
    await Future.delayed(Duration(seconds: 1)); // Simulate API call or database load
    setState(() {
      fetchAnnualLeaveDetails();
      fetchLeaveList();
      fetUpcomingHolidays();
    });
  }


  ///--- go back then Reload Leave list.
  Future<void>_goBackToApplyLeaveScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ApplyLeave()),
    );
    print("Result from ApplyLeave: $result");  // Check if the result is true

    if (result == true) {
      fetchAnnualLeaveDetails();
    }
  }

  Future<void> _goBackToWFHLeaveScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestWorkFromHome()),
    );

    if (result == true) {
      fetchAnnualLeaveDetails();
    }
  }

  Future<void> _goBackToCompOffLeaveScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestCompOFF()),
    );

    if (result == true) {
      fetchAnnualLeaveDetails();
    }
  }


  Future<void> fetchAnnualLeaveDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await getAnnualLeaveDetails(context);

      if (response is AnnualLeaveDetailsResponse) {
        final data = response.data;

        // Extract the leave details
        final leaveBalance = data.leaveBalance;
        final totalLeave = data.totalLeave;
        final usedLeave = data.usedLeave;
        final casualLeaveBal = data.casualLeaveBal;
        final sickLeaveBal = data.sickLeaveBal;
        final compOffLeaveBal = data.compOffLeaveBal;
        final elLeaveBal = data.elLeaveBal;
        final calendarYear = data.calendarYear;

        /// --- access total leave
        final totalCL = data.totalCasualLeave;
        final totalSL = data.totalSickLeave;
        final totalCompOff = data.totalCompOffLeave;
        final totalEL = data.totalElLeave;

        setState(() {
          totalLeaveBal = (totalLeave % 1 == 0)
              ? totalLeave.toInt().toString()
              : totalLeave.toString();
          leaveBal = (leaveBalance % 1 == 0)
              ? leaveBalance.toInt().toString()
              : leaveBalance.toString();
          casualLeave = (casualLeaveBal % 1 == 0)
              ? casualLeaveBal.toInt().toString()
              : casualLeaveBal.toString();
          usedLeave1 = usedLeave.toInt();
          sickLeave = (sickLeaveBal % 1 == 0)
              ? sickLeaveBal.toInt().toString()
              : sickLeaveBal.toString();
          earnLeave = (elLeaveBal % 1 == 0)
              ? elLeaveBal.toInt().toString()
              : elLeaveBal.toString();
          compOff = (compOffLeaveBal % 1 == 0)
              ? compOffLeaveBal.toInt().toString()
              : compOffLeaveBal.toString();

          /// ---- find out total assign leave
          tCL = (totalCL % 1 == 0)
              ? totalCL.toInt().toString()
              : totalCL.toString();
          tSL = (totalSL % 1 == 0)
              ? totalSL.toInt().toString()
              : totalSL.toString();
          tEL = (totalEL % 1 == 0)
              ? totalEL.toInt().toString()
              : totalEL.toString();
          tCompOff = (totalCompOff % 1 == 0)
              ? totalCompOff.toInt().toString()
              : totalCompOff.toString();

          _isLoading = false;
        });

        calculatePercentage();

      } else {
        setState(() {
          _isLoading = false;
        });
        print("Error: Response is not of type AnnualLeaveDetailsResponse.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error in fetchAnnualLeaveDetails: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: KCustomDrawer.customDrawer(
        context: context,
        title: "Leaves Details & Apply",
        titleColor: KColors.appBlackColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        showBellIcon: true,
        // Show Bell Icon
        showProfileIcon: false, // Hide Profile Icon
      ),
      drawer: CustomDrawerMenu(context: context),
      body: _isLoading? KLoader() : RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(), // <- Required!
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: KColors.appColorWhite),
                  child: Column(
                    children: [
                      KSizedBox.h15,
                      const Text(
                        "Annual Leave Details",
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      KSizedBox.h10,

                      Center(
                        child: KCircularProgressBar.circularIndicator(
                          percent: leaveP,
                          value: leaveBal ?? '',
                          valueTextSize: 28,
                          label: 'Leave balance',
                          radius: 60.0,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Total Leaves'),
                              Text(
                                totalLeaveBal.toString() ?? '',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Leave Used'),
                              Text(usedLeave1.toString() ?? '',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),

                      /// ---- Design Circular progress bar Horizontally
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: KCircularProgressBar.circularIndicator(
                                    progressColor: KColors.purpleColor,
                                    percent: (clP ?? 0) > 0 ? clP : 0,
                                    value: casualLeave.toString(),
                                    valueTextSize: 18,
                                    radius: 34.0,
                                    bottomLabel: 'Casual Leave',
                                    bottomLabelColor: KColors.textColorGray)),
                            Expanded(
                                child: KCircularProgressBar.circularIndicator(
                                    progressColor: KColors.greenColor,
                                    percent: (slP ?? 0) > 0 ? slP : 0,
                                    value: sickLeave.toString() ?? '',
                                    valueTextSize: 18,
                                    radius: 34.0,
                                    bottomLabel: 'Sick Leave',
                                    bottomLabelColor: KColors.textColorGray)),
                            Expanded(
                                child: KCircularProgressBar.circularIndicator(
                                    progressColor: KColors.orangeColor,
                                    percent: (elP ?? 0) > 0 ? elP : 0,
                                    value: earnLeave.toString() ?? '',
                                    valueTextSize: 18,
                                    radius: 34.0,
                                    bottomLabel: 'Earn Leave',
                                    bottomLabelColor: KColors.textColorGray)),
                            Expanded(
                                child: KCircularProgressBar.circularIndicator(
                                    progressColor: KColors.pinkColor,
                                    percent: (compOffP ?? 0) > 0 ? compOffP : 0.0,
                                    value: compOff.toString() ?? '',
                                    valueTextSize: 18,
                                    radius: 34.0,
                                    bottomLabel: 'Comp Off',
                                    bottomLabelColor: KColors.textColorGray)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          child: const Center(
                            child: Text(
                              "View Balance Leave",
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: KColors.appPrimary),
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/balance_leave_screen');
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                /// ---- Design Apply section
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14, right: 5),
                        child: KFeatureCard(
                          iconAsset: KAssets.applyLeave,
                          title: 'Apply Leaves',
                            onTap: () async {
                              //Navigator.pushReplacementNamed(context, '/apply_leave_screen');
                              await _goBackToApplyLeaveScreen();
                            }
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 14, right: 5, left: 5),
                        child: KFeatureCard(
                          iconAsset: KAssets.requestWFH,
                          title: 'Request WFH',
                          onTap: () async {
                            //Navigator.pushNamed(context, '/request_wfh_screen');
                            await _goBackToWFHLeaveScreen();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 14, right: 5, left: 5),
                        child: KFeatureCard(
                          iconAsset: KAssets.requestCompOFF,
                          title: 'Comp Off',
                          onTap: () async{
                            //Navigator.pushNamed(context, '/comp_off_screen');
                            await _goBackToCompOffLeaveScreen();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14, left: 5),
                        child: KFeatureCard(
                          iconAsset: KAssets.holidaysList,
                          title: 'Holidays List',
                          onTap: () {
                            Navigator.pushNamed(context, '/holiday_list_screen');
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                /// ---- Design Upcoming Your Leaves
                KSizedBox.h14,
                _upcomingYourLeaves(),

                /// --- Upcoming holidays
                KSizedBox.h14,

                _upcomingHolidays(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  void calculatePercentage() {
    calculateLeaveBalPercentage();
    calculateCLPercentage();
    calculateSLPercentage();
    calculateELPercentage();
    calculateCompOffPercentage();
  }

  void calculateLeaveBalPercentage() {
    String leaveBal1 = leaveBal.toString() ?? '0';
    String totalLeaveBal1 = totalLeaveBal.toString() ?? '0';

    print('Leave Balance is invalid or zero:${leaveBal.toString()}');
    print('Total Leave Balance is invalid or zero:${totalLeaveBal.toString()}');

    double leaveBalDouble = double.tryParse(leaveBal1) ?? 0.0;
    double? totalLeaveBalDouble = double.tryParse(totalLeaveBal1);

    if (totalLeaveBalDouble != null && totalLeaveBalDouble != 0) {
      double leavePercentage = (leaveBalDouble * 100) / totalLeaveBalDouble;

      leaveP = leavePercentage / 100;

      print('Leave_Bal_Per: ${leavePercentage.toStringAsFixed(2)}');
      //print('Leave_Bal_Per: ${ddd.toStringAsFixed(2)}');
    } else {
      print('Total Leave Balance is invalid or zero');
    }
  }

  void calculateCLPercentage() {
    String balCL = casualLeave.toString() ?? '0';
    String totalCl = tCL.toString() ?? '0';

    print('Leave Balance is invalid or zero:${balCL.toString()}');
    print('Total Leave Balance is invalid or zero:${totalCl.toString()}');

    double leaveBalCL = double.tryParse(balCL) ?? 0.0;
    double? totalLeaveCL = double.tryParse(totalCl);

    if (totalLeaveCL != null && totalLeaveCL != 0) {
      double leavePercentage = (leaveBalCL * 100) / totalLeaveCL;

      clP = leavePercentage / 100;
      clP = double.parse(clP.toStringAsFixed(2));

      print('CL_Leave_Bal_Per: $clP');
      //print('Leave_Bal_Per: ${ddd.toStringAsFixed(2)}');
    } else {
      print('Total Leave Balance is invalid or zero');
    }
  }

  void calculateSLPercentage() {
    String balSL = sickLeave.toString() ?? '0';
    String totalSL = tSL.toString() ?? '0';

    print('Leave Balance is invalid or zero:${balSL.toString()}');
    print('Total Leave Balance is invalid or zero:${totalSL.toString()}');

    double leaveBalSL = double.tryParse(balSL) ?? 0.0;
    double? totalLeaveSL = double.tryParse(totalSL);

    if (totalLeaveSL != null && totalLeaveSL != 0) {
      double leavePercentage = (leaveBalSL * 100) / totalLeaveSL;

      slP = leavePercentage / 100;
      slP = double.parse(slP.toStringAsFixed(2));

      print('SL_Leave_Bal_Per: $slP');
      //print('Leave_Bal_Per: ${ddd.toStringAsFixed(2)}');
    } else {
      print('Total Leave Balance is invalid or zero');
    }
  }

  void calculateELPercentage() {
    String balEL = earnLeave.toString() ?? '0';
    String totalEL = tEL.toString() ?? '0';

    print('Leave Balance is invalid or zero:${balEL.toString()}');
    print('Total Leave Balance is invalid or zero:${totalEL.toString()}');

    double leaveBalEL = double.tryParse(balEL) ?? 0.0;
    double? totalLeaveEL = double.tryParse(totalEL);

    if (totalLeaveEL != null && totalLeaveEL != 0) {
      double leavePercentage = (leaveBalEL * 100) / totalLeaveEL;

      elP = leavePercentage / 100;
      elP = double.parse(elP.toStringAsFixed(2));

      print('SL_Leave_Bal_Per: $elP');
      //print('Leave_Bal_Per: ${ddd.toStringAsFixed(2)}');
    } else {
      print('Total Leave Balance is invalid or zero');
    }
  }

  void calculateCompOffPercentage() {
    String balCompOff = compOff.toString() ?? '0';
    String totalCompOff = tCompOff.toString() ?? '0';

    print('Leave Balance is invalid or zero:${balCompOff.toString()}');
    print('Total Leave Balance is invalid or zero:${totalCompOff.toString()}');

    double leaveBalCompOff = double.tryParse(balCompOff) ?? 0.0;
    double? totalLeaveCompOff = double.tryParse(totalCompOff);

    if (totalLeaveCompOff != null && totalLeaveCompOff != 0) {
      double leavePercentage = (leaveBalCompOff * 100) / totalLeaveCompOff;

      compOffP = leavePercentage / 100;
      compOffP = double.parse(compOffP.toStringAsFixed(2));

      print('compFF_Per: $compOffP');
      //print('Leave_Bal_Per: ${ddd.toStringAsFixed(2)}');
    } else {
      print('Total Leave Balance is invalid or zero');
    }
  }

  Future<void> fetchLeaveList() async {
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


  /*Widget _upcomingYourLeaves() {
    return Visibility(
      visible: leaveList.isEmpty ? false : true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Your Leaves",
            style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: KColors.textHeadingColor),
          ),
          KSizedBox.h10,
          SizedBox(
            height: 115,
            child: Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: leaveList.length,
                itemBuilder: (context, index) {
                  final leave = leaveList[index];
                  return UpcomingLeavesCard(
                    month: leave.month,
                    date: leave.startDate.day.toString(),
                    type: leave.type,
                    cardColor: getLeaveColor(leave.type),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }*/
  Widget _upcomingYourLeaves() {
    return Visibility(
      visible: leaveList.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Upcoming Leaves",
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: KColors.textHeadingColor,
            ),
          ),
          KSizedBox.h10,
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
                  type: leave.type,
                  cardColor: getLeaveColor(leave.type),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _upcomingHolidays() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Visibility(
      visible: upcomingHolidays.isEmpty ? false : true,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Upcoming Holidays",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          SizedBox(height: 10,),
          SizedBox(
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
        ],
      ),
    );
  }

  Future<void> fetUpcomingHolidays() async {
    final response = await getDashboard(context);
    if (response is DashboardResponse) {
      setState(() {
        //upcomingHolidays = response.data.holidays!;
        upcomingHolidays = response.data.holidays;
        print('Check working hrs');
      });
    }
  }

}

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

class KFeatureCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final VoidCallback? onTap;

  const KFeatureCard({
    super.key,
    required this.iconAsset,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 91,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: KColors.appColorWhite,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconAsset,
              height: 40,
              width: 40,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center, // Center text
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
