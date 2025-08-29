import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_log/controllers/attendance_controller.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceController controller = AttendanceController();
  String? calendarUserSelectedDate;
  String selectedFilter = "";
  bool isDayWiseSelected = true;
  bool isThisWeek = true;
  DateTime? selectedDate;
  String? selectedQuickFilter;
  String? tempSelectedQuickFilter;
  String? selectedStatusFilter;
  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  int dayDifference = 0;
  bool isClearFilterSelected = false;
  bool isApplyFilterSelected = false;
  List<dynamic> attendanceList = [];
  bool isLoading = false;
  bool isCalendarSelected = false;
  bool isListSelected = true;
  bool isSummarySelected = false;
  String selectedIcon = "list";

  Map<DateTime, List> attendanceData = {};
  final Map<DateTime, String> attendanceDataStatusMarkCalendar = {
    DateTime(2025, 8, 5): "Present",
    DateTime(2025, 8, 6): "Absent",
    DateTime(2025, 8, 7): "Leave",
    DateTime(2025, 8, 8): "Holiday",
    DateTime(2025, 8, 9): "Present",
    DateTime(2025, 8, 12): "Absent",
    DateTime(2025, 8, 15): "Leave",
    DateTime(2025, 8, 20): "Holiday",
    DateTime(2025, 8, 22): "Absent",
  };
  final Map<String, Color> dayWiseColorMap = {
    "Present": KColors.greenColor,
    "Absent": KColors.appPrimaryRed,
    "Leave": KColors.orangeColor,
  };

  final Map<String, Color> hourWiseColorMap = {
    "Total Hrs": KColors.greenColor,
    "Present Hrs": KColors.greenColor,
    "Leave Hrs": KColors.orangeColor,
  };
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  late Future<List<List<dynamic>>> _attendanceFutureListData;

  @override
  void initState() {
    super.initState();
    _attendanceFutureListData = _loadData();
    selectedIcon = "list";
    selectedFilter = "This Week";
  }

  Future<List<List<dynamic>>> _loadData() async {
    try {
      final dayData = await controller.getAttendanceDayWiseDetails();
      final hourData = await controller.getAttendanceHourWiseDetails();
      return [dayData ?? [], hourData ?? []];
    } catch (e) {
      print("Error loading data: $e");
      return [[], []];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.lightGreyBGScreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: KCustomAppBar(
          screenTitle: 'Attendance',
          showHistory: false,
          onHistoryTap: () {
            Navigator.pushNamed(context, '/home_screen');
          },
        ),
      ),
      body: Column(
        children: [
          // Fixed header card
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
            width: double.infinity,
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: KColors.appColorWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.height * 0.02),
                child: _thisWeekOrThisMonthCardDesign(),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.02,
                    vertical: MediaQuery.of(context).size.height * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: !isCalendarSelected,
                      child: Card(
                        color: KColors.appColorWhite,
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                              MediaQuery.of(context).size.width * 0.03,
                              vertical:
                              MediaQuery.of(context).size.height * 0.03),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isDayWiseSelected = true;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                          'Days Wise',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if(isDayWiseSelected)
                                          Container(
                                            margin: const EdgeInsets.only(top: 2),
                                            height: 2,
                                            width: _textWidth(context, 'Days Wise'),
                                            color: KColors.appPrimary,
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.06),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isDayWiseSelected = false;
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hours Wise',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if(!isDayWiseSelected)
                                          Container(
                                            margin: const EdgeInsets.only(top: 2),
                                            height: 2,
                                            width: _textWidth(context, 'Hours Wise'),
                                            color: KColors.appPrimary,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.015),
                              FutureBuilder<List<List<dynamic>>>(
                                  future: _attendanceFutureListData,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return SizedBox();
                                    }
                                    if (snapshot.hasError) {
                                      return Center(
                                          child:
                                          Text("Error: ${snapshot.error}"));
                                    }
                                    final List<dynamic> dayData =
                                    (snapshot.data != null &&
                                        snapshot.data!.isNotEmpty)
                                        ? (snapshot.data![0] ?? [])
                                        : [];

                                    final List<dynamic> hourData =
                                    (snapshot.data != null &&
                                        snapshot.data!.length > 1)
                                        ? (snapshot.data![1] ?? [])
                                        : [];
                                    final selectedData =
                                    isDayWiseSelected ? dayData : hourData;
                                    if (selectedData.isEmpty) {
                                      return const SizedBox(); // nothing to show
                                    }
                                    return Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: List.generate(
                                          selectedData.length, (index) {
                                        final value = selectedData[index];
                                        final String status =value["attendanceStatus"] ?? "";
                                        print("status of attendance  is :$status");
                                        final Color statusColor = isDayWiseSelected
                                            ? (dayWiseColorMap[status] ?? KColors.appPrimary)
                                            : (hourWiseColorMap[status] ?? KColors.appPrimary);
                                        return _dayWiseHourWiseDetailCard(
                                          attendanceCount: value["count"],
                                          attendanceCountType:
                                          value["attendanceCountType"],
                                          attendanceStatus:
                                          value["attendanceStatus"],
                                          attendanceStatusColor:statusColor,
                                        );
                                      }),
                                    );
                                  }),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
                              Divider(
                                thickness: 1,
                                height: 1,
                                color: KColors.grayLight,
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              _weekendAndHolidayStatus(
                                isDayWiseSelected
                                    ? "Weekend Days"
                                    : "Weekend Hours",
                                isDayWiseSelected ? "02" : "16",
                              ),
                              SizedBox(height: 10),
                              _weekendAndHolidayStatus(
                                isDayWiseSelected
                                    ? "Holidays"
                                    : "Holiday Hours",
                                isDayWiseSelected ? "01" : "08",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    // Fix height to avoid infinite height issues inside scroll
                    isCalendarSelected
                        ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: _buildCalendarView(),
                    )
                        : _listOfDataOfThisWeekAndThisMonth(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thisWeekOrThisMonthCardDesign() {
    return Row(
      children: [
        customChoiceChipCard(
          context: context,
          labelText: "This Week",
          selectedValue: selectedFilter,
          onTap: () {
            setState(() {
              selectedFilter = "This Week";
              selectedIcon = "list";
              isCalendarSelected = false;
            });
          },
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        customChoiceChipCard(
            context: context,
            labelText: "This Month",
            selectedValue: selectedFilter,
            onTap: () {
              setState(() {
                selectedFilter = "This Month";
                selectedIcon = "list";
                isCalendarSelected = false;
              });
            }),
        Spacer(),
        customIconButton(
          context: context,
          imageType: "filter",
          selectedIcon: selectedIcon,
          assetPath: 'assets/icons/attendance_filter.svg',
          onTap: () {
            setState(() {
              selectedIcon = "filter";
            });

            // Backup
            final _prevQuickFilter = selectedQuickFilter;
            final _prevStatusFilter = selectedStatusFilter;
            final _prevFromDate = selectedFromDate;
            final _prevToDate = selectedToDate;

            showDialog(
              context: context,
              builder: (context) {
                return _filterIconPopUp(
                  context,
                  selectedQuickFilter,
                  selectedStatusFilter,
                  selectedFromDate,
                  selectedToDate,
                );
              },
            ).then((result) {
              if (result != null) {
                setState(() {
                  selectedQuickFilter = result['quickFilter'];
                  selectedStatusFilter = result['statusFilter'];
                  selectedFromDate = result['fromDate'];
                  selectedToDate = result['toDate'];
                });
              } else {
                // Restore backup on close
                setState(() {
                  selectedQuickFilter = _prevQuickFilter;
                  selectedStatusFilter = _prevStatusFilter;
                  selectedFromDate = _prevFromDate;
                  selectedToDate = _prevToDate;
                });
              }

              setState(() {
                isCalendarSelected = false;
                selectedIcon = "list";
                _listOfDataOfThisWeekAndThisMonth();
              });
            });
          },
        ),
        SizedBox(width: 4),
        customIconButton(
            context: context,
            imageType: "list",
            selectedIcon: selectedIcon,
            assetPath: 'assets/icons/attendance_list_icon.svg',
            onTap: () {
              setState(() {
                selectedIcon = "list";
                isCalendarSelected = false;
                selectedFilter = "This Week";
              });
              _listOfDataOfThisWeekAndThisMonth();
            }),
        SizedBox(width: 4),
        customIconButton(
            context: context,
            imageType: "calendar",
            selectedIcon: selectedIcon,
            onTap: () {
              setState(() {
                selectedIcon = "calendar";
                isCalendarSelected = true;
                selectedFilter = "";
                focusedDay = DateTime.now();
                selectedDay = DateTime.now();
              });
            },
            assetPath: 'assets/icons/attendance_calender.svg'),
      ],
    );
  }

  Widget _buildCalendarView() {
    final List<dynamic> allData = selectedFilter == "This Week"
        ? (controller.thisWeekData ?? [])
        : (controller.thisMonthData ?? []);

    final DateTime effectiveSelectedDay = selectedDay ?? focusedDay;
    final String selectedDateStr =
    DateFormat('dd MMM,yyyy').format(effectiveSelectedDay);

    final List<dynamic> selectedData = allData
        .where(
            (item) => (item['date'] ?? '').toString().trim() == selectedDateStr)
        .toList();

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Card(
            elevation: 0,
            color: KColors.appColorWhite,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03,
                    vertical: MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            focusedDay = DateTime(
                                focusedDay.year, focusedDay.month - 1, 1);
                          });
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                              MediaQuery.of(context).size.width * 0.09,
                              vertical:
                              MediaQuery.of(context).size.height * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: KColors.dayWiseCardBGColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              DateFormat.yMMMM().format(focusedDay),
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            focusedDay = DateTime(
                                focusedDay.year, focusedDay.month + 1, 1);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TableCalendar(
                    headerVisible: false,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDay, day);
                    },
                    onDaySelected: (selected, focused) {
                      setState(() {
                        selectedDay = DateTime(
                            selected.year, selected.month, selected.day);
                        focusedDay = selectedDay!;
                        calendarUserSelectedDate =
                            DateFormat("dd MMM,yyyy").format(focusedDay);
                        print("User selected date: $calendarUserSelectedDate");
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      outsideBuilder: (context, day, _) =>
                      const SizedBox.shrink(),
                      selectedBuilder: (context, day, _) {
                        final status = attendanceDataStatusMarkCalendar[
                        DateTime(day.year, day.month, day.day)];
                        return _dayCell(day, status, isSelected: true);
                      },
                      defaultBuilder: (context, day, _) {
                        final status = attendanceDataStatusMarkCalendar[
                        DateTime(day.year, day.month, day.day)];
                        return _dayCell(day, status,
                            isSelected: isSameDay(selectedDay, day));
                      },
                      todayBuilder: (context, day, _) {
                        final status = attendanceDataStatusMarkCalendar[
                        DateTime(day.year, day.month, day.day)];
                        return _dayCell(day, status,
                            isSelected: isSameDay(selectedDay, day));
                      },
                    ),
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.transparent),
                      selectedDecoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.transparent),
                      todayTextStyle: TextStyle(color: Colors.black),
                      selectedTextStyle: TextStyle(color: Colors.black),
                    ),
                    eventLoader: (day) =>
                    attendanceData[
                    DateTime(day.year, day.month, day.day)] ??
                        [],
                  ),
                ),
              ],
            ),
          ),
        ),

        /// --- Day wise Data Cards
        selectedData.isNotEmpty
            ? Builder(
          builder: (context) {
            final item = selectedData.first; // Only one card per day

            final String userStatus = item["userStatus"] ?? "";
            final String dayName = item["dayName"] ?? "";
            final String date = item["date"] ?? "";
            final String firstIn = userStatus == "Present"
                ? (item["dataOfFirstIn"] ?? "-")
                : "-";
            final String lastOut = userStatus == "Present"
                ? (item["dataOfLastOut"] ?? "-")
                : "-";
            final String totalHrs =
            userStatus == "Present" ? (item["totalHrs"] ?? "-") : "-";
            final String shift =
            userStatus == "Present" ? (item["shift"] ?? "-") : "-";

            Color statusColor;
            switch (userStatus) {
              case "Present":
                statusColor = KColors.greenColor;
                break;
              case "Absent":
                statusColor = KColors.appPrimaryRed;
                break;
              case "Leave":
                statusColor = Colors.orange;
                break;
              case "Holiday":
                statusColor = KColors.purpleColor;
                break;
              case "Weekend":
                statusColor = KColors.appPrimary;
                break;
              default:
                statusColor = Colors.grey;
            }

            return Card(
              margin: const EdgeInsets.symmetric(
                  vertical: 18, horizontal: 12),
              elevation: 0,
              color: KColors.appColorWhite,
              child: Padding(
                padding: EdgeInsets.zero,
                child: Stack(
                  children: [
                    Container(
                      constraints: const BoxConstraints(minHeight: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: (userStatus == "Present")
                          ? Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$dayName, $date",
                                style: TextStyle(
                                  color: statusColor,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.02,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius:
                                  BorderRadius.circular(5),
                                ),
                                child: Text(
                                  userStatus,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Divider(
                              thickness: 1,
                              height: 1,
                              color: KColors.grayLight),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text("First In: $firstIn"),
                              Text("Last Out: $lastOut"),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Hrs: $totalHrs"),
                              Text("Shift: $shift"),
                            ],
                          ),
                        ],
                      )
                          : Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$dayName, $date",
                            style: TextStyle(
                              color: statusColor,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context)
                                  .size
                                  .width *
                                  0.02,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius:
                              BorderRadius.circular(5),
                            ),
                            child: Text(
                              userStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        child: Container(
                          width: 6,
                          color: Colors.transparent,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 4,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
            : const Center(
          child: Text("No data available for this day."),
        ),
      ],
    );
  }


  Widget _dayWiseHourWiseDetailCard(
      {required int attendanceCount,
        required String attendanceCountType,
        required String attendanceStatus,
        required Color attendanceStatusColor}) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.09,
      width: MediaQuery.of(context).size.width * 0.29,
      child: Card(
        elevation: 0,
        color: KColors.dayWiseCardBGColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.height * 0.01),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    attendanceCount.toString(),
                    style: TextStyle(
                      color: KColors.appBlackColor,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    attendanceCountType,
                    style: TextStyle(
                      color: KColors.appBlackColor,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                attendanceStatus,
                style: TextStyle(
                  color: attendanceStatusColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weekendAndHolidayStatus(String weekendStatus, String countValue) {
    return Row(
      children: [
        Text(
          weekendStatus,
          style: TextStyle(
            color: KColors.appBlackColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacer(),
        Text(
          countValue,
          style: TextStyle(
            color: KColors.appBlackColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _listOfDataOfThisWeekAndThisMonth() {
    return FutureBuilder(
      future: controller.getThisWeekThisMonthDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  const Center(
              child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return SizedBox();
        }
        final data = selectedFilter == "This Week"
            ? controller.thisWeekData
            : controller.thisMonthData;
        final filteredData = _applyFilters(
          data ?? [],
          selectedQuickFilter: selectedQuickFilter,
          selectedStatusFilter: selectedStatusFilter,
          selectedFromDate: selectedFromDate,
          selectedToDate: selectedToDate,
        );
        final finalData = calendarUserSelectedDate == null
            ? filteredData
            : filteredData.where((item) {
          final String itemDate = item["date"] ?? "";
          print(
              "User selected date at ListOfDataOfThisWeekAndThisMonth : $calendarUserSelectedDate");
          return itemDate == calendarUserSelectedDate;
        }).toList();
        if (finalData.isEmpty) {
          return Center(child: Text("No data available"));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: finalData.length,
          itemBuilder: (context, index) {
            final item = finalData[index];
            final String userStatus = item["userStatus"] ?? "";
            final String dayName = item["dayName"] ?? "";
            final String date = item["date"] ?? "";
            final String firstIn =
            userStatus == "Present" ? (item["dataOfFirstIn"] ?? "-") : "-";
            final String lastOut =
            userStatus == "Present" ? (item["dataOfLastOut"] ?? "-") : "-";
            final String totalHrs =
            userStatus == "Present" ? (item["totalHrs"] ?? "-") : "-";
            final String shift =
            userStatus == "Present" ? (item["shift"] ?? "-") : "-";
            Color statusColor;
            switch (userStatus) {
              case "Present":
                statusColor = KColors.greenColor;
                break;
              case "Absent":
                statusColor = KColors.appPrimaryRed;
                break;
              case "Leave":
                statusColor = Colors.orange;
                break;
              case "Holiday":
                statusColor = KColors.purpleColor;
                break;
              case "Weekend":
                statusColor = KColors.appPrimary;
                break;
              default:
                statusColor = Colors.grey;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                children: [
                  Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: (userStatus == "Present")
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$dayName, $date",
                              style: TextStyle(
                                color: statusColor,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width *
                                    0.02,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                userStatus,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(
                            thickness: 1,
                            height: 1,
                            color: KColors.grayLight),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text("First In: $firstIn"),
                            Text("Last Out: $lastOut"),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Hrs: $totalHrs"),
                            Text("Shift: $shift"),
                          ],
                        ),
                      ],
                    )
                        : Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$dayName, $date",
                            style: TextStyle(
                              color: statusColor,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                              MediaQuery.of(context).size.width *
                                  0.02,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              userStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      child: Container(
                        width: 6,
                        color: Colors.transparent,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 4,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Widget customChoiceChipCard({
  required BuildContext context,
  required String labelText,
  required String selectedValue,
  required VoidCallback onTap,
}) {
  final bool isSelected = selectedValue == labelText;

  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.04,
      width: MediaQuery.of(context).size.width * 0.30,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? KColors.appPrimary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: KColors.appPrimary,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? KColors.appColorWhite : KColors.appPrimary,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _filterIconPopUp(
    BuildContext context,
    String? selectedQuickFilter,
    String? selectedStatusFilter,
    DateTime? selectedFromDate,
    DateTime? selectedToDate,
    ) {
  // Local variables (copied so dialog can update independently)
  String? _quick = selectedQuickFilter;
  String? _status = selectedStatusFilter;
  DateTime? _from = selectedFromDate;
  DateTime? _to = selectedToDate;

  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    backgroundColor: KColors.appColorWhite,
    insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    child: StatefulBuilder(
      builder: (context, dialogSetState) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Attendance Summary",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, {
                        "quickFilter": _quick,
                        "statusFilter": _status,
                        "fromDate": _from,
                        "toDate": _to,
                      });
                    },
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor:Color(0xFFF6F4FC),
                      child: Icon(Icons.close, size: 20, color: Colors.black),
                    ),
                  ),
                ],
              ),

              Divider(height:  MediaQuery.of(context).size.height * 0.03,),
              const Text("Quick Filters",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
              Wrap(
                spacing: 8,
                children: ["This Week", "Last Week", "This Month"].map((label) {
                  final isSelected = _quick == label;
                  return customSelectableBox(
                    label: label,
                    isSelected: isSelected,
                    onTap: () => dialogSetState(() => _quick = label),
                    borderColor: KColors.appPrimary,
                    selectedColor: KColors.appPrimary,
                    unselectedColor: Colors.white,
                  );
                }).toList(),
              ),

              Divider(height: MediaQuery.of(context).size.height * 0.03),
              const Text("Status Filters",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,
                  )),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: {
                  "Present": KColors.greenColor,
                  "Absent": KColors.appPrimaryRed,
                  "Leave": KColors.orangeColor,
                  "Holiday": KColors.purpleColor,
                }.entries.map((entry) {
                  final isSelected = _status == entry.key;
                  return customSelectableBox(
                    label: entry.key,
                    isSelected: isSelected,
                    onTap: () => dialogSetState(() => _status = entry.key),
                    borderColor: entry.value,
                    selectedColor: entry.value,
                    unselectedColor: Colors.white,
                  );
                }).toList(),
              ),

              const Divider(height: 24, ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.01,),

              _buildDateRangeFilters(
                context,
                dialogSetState,
                _from,
                _to,
                    (picked) => _from = picked,
                    (picked) => _to = picked,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      dialogSetState(() {
                        _quick = null;
                        _status = null;
                        _from = null;
                        _to = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: KColors.appPrimary),
                    ),
                    child: const Text("Clear Filter",
                        style: TextStyle(color: KColors.appPrimary)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:KColors.appPrimary,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      Navigator.pop(context, {
                        "quickFilter": _quick,
                        "statusFilter": _status,
                        "fromDate": _from,
                        "toDate": _to,
                      });
                    },
                    child: const Text("Apply All Filters",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _buildDateRangeFilters(
    BuildContext context,
    void Function(void Function()) dialogSetState,
    DateTime? from,
    DateTime? to,
    Function(DateTime picked) onFromPicked,
    Function(DateTime picked) onToPicked,
    ) {
  int dayDiff = (from != null && to != null)
      ? to.difference(from).inDays.abs() + 1
      : 0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Date Range Filter",
        style: TextStyle(
          fontFamily: "Poppins",
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),

      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFF6F4FC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("From Date",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: from ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        dialogSetState(() => onFromPicked(picked));
                      }
                    },
                    child: Text(
                      from != null
                          ? DateFormat("dd MMM, yyyy").format(from)
                          : "Select From Date",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Day Counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: KColors.appColorWhite,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "${dayDiff.toString().padLeft(2, "0")} Day",
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),

            /// To Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("To Date",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: to ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        dialogSetState(() => onToPicked(picked));
                      }
                    },
                    child: Text(
                      to != null
                          ? DateFormat("dd MMM, yyyy").format(to)
                          : "Select To Date",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget customSelectableBox({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
  Color selectedColor = Colors.blue,
  Color unselectedColor = Colors.white,
  Color borderColor = Colors.blue,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? selectedColor : unselectedColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: isSelected ? Colors.white : borderColor,
        ),
      ),
    ),
  );
}



Widget customIconButton({
  required BuildContext context,
  required String imageType,
  required String selectedIcon,
  required final VoidCallback onTap,
  required String assetPath,
}) {
  bool isSelected = selectedIcon == imageType;
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.04,
    width: MediaQuery.of(context).size.width * 0.08,
    child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor:
          isSelected ? KColors.orangeColor : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          side: BorderSide(color: KColors.orangeColor),
          padding: EdgeInsets.zero,
        ),
        onPressed: onTap,
        child: SvgPicture.asset(
          assetPath,
          colorFilter: ColorFilter.mode(
              isSelected ? KColors.appColorWhite : KColors.orangeColor,
              BlendMode.srcIn),
        )),
  );
}

Widget _dayCell(
    DateTime day,
    String? status, {
      bool isSelected = false,
    }) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  Color bgColor = Colors.transparent;
  Color textColor = Colors.black;

  if (isSameDay(day, today) && isSelected) {
    bgColor = Colors.transparent;
    textColor = Colors.black;
  } else {
    switch (status) {
      case "Present":
        bgColor = KColors.greenColor;
        textColor = Colors.white;
        break;
      case "Absent":
        bgColor = KColors.appPrimaryRed;
        textColor = Colors.white;
        break;
      case "Leave":
        bgColor = KColors.orangeColor;
        textColor = Colors.white;
        break;
      case "Holiday":
        bgColor = KColors.purpleColor;
        textColor = Colors.white;
        break;
      case "Weekend":
        bgColor = KColors.appPrimary;
        textColor = Colors.white;
        break;
    }
  }

  return Container(
    margin: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: bgColor,
      border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
    ),
    alignment: Alignment.center,
    child: Text(
      '${day.day}',
      style: TextStyle(color: textColor, fontSize: 14),
    ),
  );
}

List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> data, {
      String? selectedQuickFilter,
      String? selectedStatusFilter,
      DateTime? selectedFromDate,
      DateTime? selectedToDate,
    }) {
  List<Map<String, dynamic>> filteredList = List.from(data);

  if (selectedQuickFilter != null) {
    if (selectedQuickFilter == "This Week") {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      filteredList = filteredList.where((item) {
        final String itemDateStr = item["date"] ?? "";
        print("Raw date string: $itemDateStr");
        if (itemDateStr.isEmpty) return false;

        final DateTime itemDate =
        DateFormat("dd MMM,yyyy").parse(itemDateStr, true);
        return itemDate
            .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            itemDate.isBefore(endOfWeek.add(const Duration(days: 1)));
      }).toList();
    } else if (selectedQuickFilter == "This Month") {
      final now = DateTime.now();
      filteredList = filteredList.where((item) {
        final String itemDateStr = item["date"] ?? "";
        if (itemDateStr.isEmpty) return false;

        final DateTime itemDate =
        DateFormat("dd MMM,yyyy").parse(itemDateStr, true);
        return itemDate.month == now.month && itemDate.year == now.year;
      }).toList();
    }
  }
  if (selectedStatusFilter != null) {
    filteredList = filteredList
        .where((item) => item["userStatus"] == selectedStatusFilter)
        .toList();
  }
  if (selectedFromDate != null && selectedToDate != null) {
    filteredList = filteredList.where((item) {
      final String itemDateStr = item["date"] ?? "";
      if (itemDateStr.isEmpty) return false;

      final DateTime itemDate =
      DateFormat("dd MMM,yyyy").parse(itemDateStr, true);
      return itemDate
          .isAfter(selectedFromDate.subtract(const Duration(days: 1))) &&
          itemDate.isBefore(selectedToDate.add(const Duration(days: 1)));
    }).toList();
  }

  return filteredList;
}

double _textWidth(BuildContext context, String text) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
    maxLines: 1,
    textDirection: Directionality.of(context),
  )..layout();
  return textPainter.width;
}
