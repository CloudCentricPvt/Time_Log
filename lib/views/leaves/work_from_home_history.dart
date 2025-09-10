import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/utils/constants/k_loader.dart';

import '../../models/wfh_history_res.dart';
import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/constants/k_date_and_time.dart';
import '../../utils/constants/k_fonts.dart';
import '../../utils/constants/show_leave_history_details_dialog.dart';
import '../../utils/popups/k_filter_dialog.dart';
import '../../utils/popups/k_material_dialog.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import '../../utils/reusable_widgit/k_filter_header.dart';

class WorkFromHomeHistory extends StatefulWidget {
  const WorkFromHomeHistory({super.key});

  @override
  State<WorkFromHomeHistory> createState() => _WorkFromHomeHistoryState();
}

class _WorkFromHomeHistoryState extends State<WorkFromHomeHistory> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();
  WfhFilters _filters = WfhFilters();
  String selectedStatus = 'All';
  bool _isLoading = true;
  List<WFHRequest> wfhList = [];
  String selectedProject = "Select Project";
  String selectedTask = "Select Task";
  List<String> projectItems = [];
  List<String> taskItems = [];

  @override
  void initState() {
    _checkInternetConnection();
    super.initState();
  }

  Future<void> _refreshData() async {
    // Your logic to refresh data
    //await Future.delayed(Duration(seconds: 1)); // Simulate API call or database load
    setState(() {
      _isLoading = true;
      fetchWfhData();
    });
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
    fetchWfhData();
  }

  @override
  Widget build(BuildContext context) {
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
          screenTitle: 'WFH History',
          historyTitle: 'Request New',
          showHistory: true,
          onHistoryTap: () {
            Navigator.pushNamed(context, '/request_wfh_screen');
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    KFilterHeader(
                        width: 65,
                        textTitle: 'All',
                        strokeColor: KColors.appPrimary,
                        textColor: selectedStatus == 'All'
                            ? KColors.appColorWhite
                            : KColors.appPrimary,
                        backgroundColor: selectedStatus == 'All'
                            ? KColors.appPrimary
                            : Colors.transparent,
                        onHistoryTap: () {
                          setState(() {
                            selectedStatus = 'All';
                          });
                        }),
                    KFilterHeader(
                        textTitle: 'Pending',
                        strokeColor: KColors.orangeColor,
                        textColor: selectedStatus == 'Pending'
                            ? KColors.appColorWhite
                            : KColors.orangeColor,
                        backgroundColor: selectedStatus == 'Pending'
                            ? KColors.orangeColor
                            : Colors.transparent,
                        onHistoryTap: () {
                          setState(() {
                            selectedStatus = 'Pending';
                            _filters.statusFilter = 'Pending';
                          });
                        }),
                    KFilterHeader(
                        textTitle: 'Approved',
                        strokeColor: KColors.greenColor,
                        textColor: selectedStatus == 'Approved'
                            ? KColors.appColorWhite
                            : KColors.greenColor,
                        backgroundColor: selectedStatus == 'Approved'
                            ? KColors.greenColor
                            : Colors.transparent,
                        onHistoryTap: () {
                          setState(() {
                            selectedStatus = 'Approved';
                            _filters.statusFilter = 'Approved';
                          });
                        }),
                    KFilterHeader(
                        textTitle: 'Rejected',
                        strokeColor: KColors.appPrimaryRed,
                        textColor: selectedStatus == 'Rejected'
                            ? KColors.appColorWhite
                            : KColors.appPrimaryRed,
                        backgroundColor: selectedStatus == 'Rejected'
                            ? KColors.appPrimaryRed
                            : Colors.transparent,
                        onHistoryTap: () {
                          setState(() {
                            selectedStatus = 'Rejected';
                            _filters.statusFilter = 'Rejected';
                          });
                        }),
                    GestureDetector(
                        child: SvgPicture.asset(KAssets.filterIcon),
                        onTap: () async {
                          final result =
                              await FilterDialog.showTimeLogFilterDialog(
                            context,
                            _filters.quickFilter,
                            _filters.statusFilter,
                            _filters.fromDate,
                            _filters.toDate,
                            selectedProject,
                            selectedTask,
                          );
                          if (result != null) {
                            setState(() {
                              _filters = result;
                              if (_filters.statusFilter != null) {
                                selectedStatus = _filters.statusFilter!;
                              }
                            });
                          }
                        }),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? KLoader()
                    : Builder(
                        builder: (context) {
                          final filteredList = _getFilteredList(_filters);
                          if (filteredList.isEmpty) {
                            return const Center(
                              child: Text(
                                "Data not found",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              return _showWFHHistoryDataInList(
                                  filteredList[index]);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetchWfhData() async {
    var result = await getWFHHistory(context);
    print('History of WFH: $result');
    if (result is WfhHistoryResponse) {
      setState(() {
        wfhList = result.data?.lstWFHRequests ?? [];
        _isLoading = false;
      });
    }
  }

  /// --- Show WFH History data in ListView
  Widget _showWFHHistoryDataInList(WFHRequest leave) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01,),
      child: GestureDetector(
        child: BalanceLeave(
          type: leave.requestType.toString() ?? '',
          day: leave.numberOfDays == null
              ? "0.0"
              : leave.numberOfDays.toString(),
          status: leave.status.toString() ?? '',
          startDate: leave.startDate ?? '',
          endDate: leave.endDate ?? '',
          iconAsset: getIconForStatus(leave.status),
        ),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => ShowLeaveHistoryDetailsDialog(
                    leaveType: leave.requestType,
                    des: leave.description,
                    status: leave.status,
                    startDate: leave.startDate,
                    endDate: leave.endDate,
                    dayCount: leave.numberOfDays == null
                        ? "0.0"
                        : leave.numberOfDays.toString(),
                  ));
        },
      ),
    );
  }

  String getIconForStatus(String? status) {
    switch (status) {
      case 'Pending':
        return KAssets.wfhPendingIcon;
      case 'Approved':
        return KAssets.requestWFH;
      case 'Rejected':
        return KAssets.wfhRejectedIcon;
      default:
        return KAssets.wfhPendingIcon;
    }
  }

  List<WFHRequest> _getFilteredList(WfhFilters filters) {
    List<WFHRequest> filtered = List.from(wfhList);

    // Status filter
    if (filters.statusFilter != null && filters.statusFilter != "All") {
      filtered = filtered
          .where((item) =>
              item.status?.trim().toLowerCase() ==
              filters.statusFilter!.toLowerCase())
          .toList();
    }

    // Date range filter
    if (filters.fromDate != null && filters.toDate != null) {
      filtered = filtered.where((item) {
        try {
          final start = DateTime.parse(item.startDate ?? "");
          return start.isAfter(
                  filters.fromDate!.subtract(const Duration(days: 1))) &&
              start.isBefore(filters.toDate!.add(const Duration(days: 1)));
        } catch (_) {
          return false;
        }
      }).toList();
    }

    if (filters.quickFilter != null) {
      final now = DateTime.now();
      if (filters.quickFilter == "This Week") {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        filtered = filtered.where((item) {
          final date = DateTime.tryParse(item.startDate ?? "");
          return date != null &&
              date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              date.isBefore(endOfWeek.add(const Duration(days: 1)));
        }).toList();
      }
      else if (filters.quickFilter == "Last Week") {
        final endOfLastWeek = now.subtract(Duration(days: now.weekday));
        final startOfLastWeek = endOfLastWeek.subtract(const Duration(days: 6));

        DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

        filtered = filtered.where((item) {
          final parsed = DateTime.tryParse(item.startDate ?? "");
          if (parsed == null) return false;

          final day = _dateOnly(parsed);
          final startDay = _dateOnly(startOfLastWeek);
          final endDay = _dateOnly(endOfLastWeek);

          // inclusive: startDay <= day <= endDay
          return !day.isBefore(startDay) && !day.isAfter(endDay);
        }).toList();
      }
      else if (filters.quickFilter == "This Month") {
        final startOfMonth = DateTime(now.year, now.month, 1);
        final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

        filtered = filtered.where((item) {
          final date = DateTime.tryParse(item.startDate ?? "");
          return date != null &&
              date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              date.isBefore(startOfNextMonth);
        }).toList();
      }
      else if (filters.quickFilter == "Last Month") {
        final startOfThisMonth = DateTime(now.year, now.month, 1);
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth =
            startOfThisMonth.subtract(const Duration(days: 1));

        filtered = filtered.where((item) {
          final date = DateTime.tryParse(item.startDate ?? "");
          return date != null &&
              date.isAfter(
                  startOfLastMonth.subtract(const Duration(days: 1))) &&
              date.isBefore(endOfLastMonth.add(const Duration(days: 1)));
        }).toList();
      }
      else if (filters.quickFilter == "This Year") {
        final startOfYear = DateTime(now.year, 1, 1);
        final startOfNextYear = DateTime(now.year + 1, 1, 1);

        filtered = filtered.where((item) {
          final date = DateTime.tryParse(item.startDate ?? "");
          return date != null &&
              date.isAfter(startOfYear.subtract(const Duration(days: 1))) &&
              date.isBefore(startOfNextYear);
        }).toList();
      }
    }
    return filtered;
  }
}

class BalanceLeave extends StatelessWidget {
  final String type;
  final String status;
  final String day;
  final String startDate;
  final String endDate;
  final String iconAsset;

  const BalanceLeave({
    super.key,
    required this.type,
    required this.status,
    required this.day,
    required this.startDate,
    required this.endDate,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    // Define status colors
    Color statusColor;
    switch (status) {
      case "Pending":
        statusColor = KColors.orangeColor;
        break;
      case "Rejected":
        statusColor = KColors.appPrimaryRed;
        break;
      case "Approved":
        statusColor = KColors.greenColor;
        break;
      default:
        statusColor = Colors.grey; // Default color if status is unknown
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.11,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 3,
        shadowColor: KColors.cardShadowColor,
        color: KColors.appColorWhite,
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 27),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SvgPicture.asset(
                  iconAsset,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(type == 'Work From Home' ? 'WFH' : 'WFH',
                            style: KFonts.normalHeading),
                        const SizedBox(
                          width: 2,
                        ),
                        const Text('|', style: KFonts.normalHeading),
                        const SizedBox(
                          width: 2,
                        ),
                        Text('${double.parse(day).toInt()} Day',
                            style: KFonts.normalHeading),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4, // space between elements horizontally
                      runSpacing: 2, // space between lines if wrapped
                      children: [
                        Text(KDateAndTime().getDay(startDate ?? ""),
                            style: KFonts.normalBold),
                        Text(KDateAndTime().getMonthYear(startDate ?? ""),
                            style: KFonts.normal),
                        Text('to', style: KFonts.normal),
                        Text(KDateAndTime().getDay(endDate ?? ""),
                            style: KFonts.normalBold),
                        Text(KDateAndTime().getMonthYear(endDate ?? ""),
                            style: KFonts.normal),
                      ],
                    ),
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
                color: statusColor, // Set background color dynamically
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(status, style: KFonts.normalWithWhiteColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
