import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/utils/constants/k_fonts.dart';
import 'package:time_log/utils/constants/k_loader.dart';
import 'package:time_log/utils/reusable_widgit/k_filter_header.dart';

import '../../models/applied_leave_history_res.dart';
import '../../models/comp_off_history_res.dart';
import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/constants/k_date_and_time.dart';
import '../../utils/constants/show_leave_history_details_dialog.dart';
import '../../utils/popups/k_filter_dialog.dart';
import '../../utils/popups/k_material_dialog.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import 'common_dialog_filter_screen.dart';

class LeaveHistory extends StatefulWidget {
  const LeaveHistory({super.key});

  @override
  State<LeaveHistory> createState() => _LeaveHistoryState();
}

class _LeaveHistoryState extends State<LeaveHistory> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();

  /// --- variables for Pagination
  int _page = 1;
  final int _pageSize = 10;
  bool _isFetchingMore = false;
  bool _hasMoreData = true;
  ScrollController _scrollController = ScrollController();


  String selectedStatus = 'All';
  bool _isLoading = true;
  List<AppliedLeaveHistory> appliedLeaveList = [];
  String selectedProject = "Select Project";
  String selectedTask = "Select Task";

  CommonDialogFilter _filters = CommonDialogFilter(
    quickFilter: null,
    statusFilter: null,
    fromDate: null,
    toDate: null,
    project: "Select Project",
    task: "Select Task",
  );

  @override
  void initState() {
    _checkInternetConnection();
    super.initState();
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
    fetchAppliedLeaveData();
  }

  Future<void> _refreshData() async {
    // Your logic to refresh data
    //await Future.delayed(Duration(seconds: 1)); // Simulate API call or database load
    setState(() {
      _isLoading = true;
      fetchAppliedLeaveData();
    });
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF84DBFF), // Same as app bar
          statusBarIconBrightness: Brightness
              .dark, // or .light depending on contrast
        ),
        title: KCustomAppBar(
          screenTitle: 'Leave History',
          historyTitle: 'Apply New',
          showHistory: true,
          onHistoryTap: () {
            Navigator.pushNamed(context, '/apply_leave_screen');
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
                            _filters = CommonDialogFilter(
                              quickFilter: _filters.quickFilter,
                              statusFilter: null,
                              // reset to show all
                              fromDate: _filters.fromDate,
                              toDate: _filters.toDate,
                              project: _filters.project,
                              task: _filters.task,
                            );
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
                            _filters = CommonDialogFilter(
                              quickFilter: _filters.quickFilter,
                              statusFilter: 'Pending',
                              fromDate: _filters.fromDate,
                              toDate: _filters.toDate,
                              project: _filters.project,
                              task: _filters.task,
                            );

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
                            _filters = CommonDialogFilter(
                              quickFilter: _filters.quickFilter,
                              statusFilter: 'Approved',
                              fromDate: _filters.fromDate,
                              toDate: _filters.toDate,
                              project: _filters.project,
                              task: _filters.task,
                            );
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
                            _filters = CommonDialogFilter(
                              quickFilter: _filters.quickFilter,
                              statusFilter: 'Rejected',
                              fromDate: _filters.fromDate,
                              toDate: _filters.toDate,
                              project: _filters.project,
                              task: _filters.task,
                            );
                          });
                        }),
                    GestureDetector(
                      child: SvgPicture.asset(KAssets.filterIcon),
                      onTap: () async {
                        final result = await ReusableFilterDialog
                            .showFilterDialog(
                          context: context,
                          title: "Leaves  filters",
                          quickFilters: [
                            "This Week",
                            "Last Week",
                            "This Month",
                            "Last Month",
                            "This Year",
                          ],
                          statusFilters: {
                            "Pending": KColors.orangeColor,
                            "Approved": KColors.greenColor,
                            "Rejected": KColors.appPrimaryRed,
                          },
                          selectedQuickFilter: _filters.quickFilter,
                          selectedStatusFilter: _filters.statusFilter,
                          fromDate: _filters.fromDate,
                          toDate: _filters.toDate,
                          selectedProject: selectedProject,
                          selectedTask: selectedTask,
                          showProject: false,
                          showTask: false,
                        );
                        if (result != null) {
                          setState(() {
                            _filters = result;
                            if (_filters.statusFilter != null) {
                              selectedStatus = _filters.statusFilter!;
                            } else {
                              selectedStatus = 'All';
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? KLoader()
                    : Builder(
                  builder: (context) {
                    final filteredList = _getFilteredListDialog(_filters); // filter once
                    return filteredList.isEmpty
                        ? const Center(child: Text("No data found!"))
                        : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final leave = filteredList[index];
                        return _showLeaveHistoryDataInList(leave,context);
                      },
                    );
                    /*ListView.builder(
                            controller: _scrollController,
                            itemCount: filteredList.length + (_isFetchingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == filteredList.length) {
                                return Center(child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ));
                              }
                              final leave = filteredList[index];
                              return _showLeaveHistoryDataInList(leave);
                            },
                          );*/

                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetchAppliedLeaveData() async {
    var result = await getAllAppliedLeave(context);
    print('History of Comp Off: $result');
    if (result is AppliedLeaveHistoryResponse) {
      setState(() {
        appliedLeaveList = result.data;
        _isLoading = false;
      });
    }
  }

  List<AppliedLeaveHistory> _getFilteredListDialog(CommonDialogFilter filters) {
    List<AppliedLeaveHistory> filtered = List.from(appliedLeaveList);

    // 🔹 Status filter
    if (filters.statusFilter != null && filters.statusFilter != "All") {
      filtered = filtered
          .where((item) =>
      (item.status ?? "").trim().toLowerCase() ==
          filters.statusFilter!.toLowerCase())
          .toList();
    }

    // 🔹 Date range filter
    if (filters.fromDate != null && filters.toDate != null) {
      filtered = filtered.where((item) {
        try {
          final date = _parseAppliedLeaveDate(item.startDate) ??
              _parseAppliedLeaveDate(item.endDate);
          if (date == null) return false;

          return date.isAfter(filters.fromDate!.subtract(const Duration(days: 1))) &&
              date.isBefore(filters.toDate!.add(const Duration(days: 1)));
        } catch (_) {
          return false;
        }
      }).toList();
    }

    // 🔹 Quick filters
    if (filters.quickFilter != null && filters.quickFilter!.isNotEmpty) {
      final now = DateTime.now();

      DateTime? _getItemDate(AppliedLeaveHistory item) =>
          _parseAppliedLeaveDate(item.startDate) ??
              _parseAppliedLeaveDate(item.endDate);

      DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

      if (filters.quickFilter == "This Week") {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));

        filtered = filtered.where((item) {
          final date = _getItemDate(item);
          return date != null &&
              date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              date.isBefore(endOfWeek.add(const Duration(days: 1)));
        }).toList();
      }

      else if (filters.quickFilter == "Last Week") {
        final endOfLastWeek = now.subtract(Duration(days: now.weekday));
        final startOfLastWeek = endOfLastWeek.subtract(const Duration(days: 6));

        filtered = filtered.where((item) {
          final date = _getItemDate(item);
          if (date == null) return false;

          final day = _dateOnly(date);
          final startDay = _dateOnly(startOfLastWeek);
          final endDay = _dateOnly(endOfLastWeek);

          return !day.isBefore(startDay) && !day.isAfter(endDay);
        }).toList();
      }

      else if (filters.quickFilter == "This Month") {
        final startOfMonth = DateTime(now.year, now.month, 1);
        final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

        filtered = filtered.where((item) {
          final date = _getItemDate(item);
          return date != null &&
              date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              date.isBefore(startOfNextMonth);
        }).toList();
      }

      else if (filters.quickFilter == "Last Month") {
        final startOfThisMonth = DateTime(now.year, now.month, 1);
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = startOfThisMonth.subtract(const Duration(days: 1));

        filtered = filtered.where((item) {
          final date = _getItemDate(item);
          return date != null &&
              date.isAfter(startOfLastMonth.subtract(const Duration(days: 1))) &&
              date.isBefore(endOfLastMonth.add(const Duration(days: 1)));
        }).toList();
      }

      else if (filters.quickFilter == "This Year") {
        final startOfYear = DateTime(now.year, 1, 1);
        final startOfNextYear = DateTime(now.year + 1, 1, 1);

        filtered = filtered.where((item) {
          final date = _getItemDate(item);
          return date != null &&
              date.isAfter(startOfYear.subtract(const Duration(days: 1))) &&
              date.isBefore(startOfNextYear);
        }).toList();
      }
    }

    return filtered;
  }


  DateTime? _parseAppliedLeaveDate(String? s) {
    if (s == null || s
        .trim()
        .isEmpty) return null;
    s = s.trim();
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    final formats = <String>[
      'dd MMM, yyyy', // 01 Aug, 2025
      'dd MMM yyyy', // 01 Aug 2025
      'dd-MM-yyyy', // 01-08-2025
      'dd/MM/yyyy', // 01/08/2025
      'MM/dd/yyyy', // 08/01/2025
      'yyyy-MM-dd', // 2025-08-01
    ];

    for (final f in formats) {
      try {
        final dt = DateFormat(f).parse(s);
        return dt;
      } catch (_) {
        // ignore and try next
      }
    }

    // replacing slashes/dots/dashes to a parseable form
    try {
      var normalized = s.replaceAll('/', '-').replaceAll('.', '-');
      final dt2 = DateTime.tryParse(normalized);
      return dt2;
    } catch (_) {}

    return null;
  }



  /*void fetchAppliedLeaveData({int page = 1}) async {
    var result = await getAllAppliedLeave(context, page, _pageSize); // Make sure your API supports pagination

    if (result is AppliedLeaveHistoryResponse) {
      setState(() {
        if (page == 1) {
          appliedLeaveList = result.data;
        } else {
          appliedLeaveList.addAll(result.data);
        }
        _hasMoreData = result.data.length == _pageSize;
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }*/

  void _fetchMoreData() {
    setState(() {
      _isFetchingMore = true;
      _page++;
    });
    //fetchAppliedLeaveData(page: _page);
  }

  List<AppliedLeaveHistory> _getFilteredList() {
    if (selectedStatus == 'All') {
      return List.from(appliedLeaveList);
    } else {
      return appliedLeaveList
          .where((item) =>
      item.status.trim().toLowerCase() == selectedStatus.trim().toLowerCase())
          .toList();
    }
  }
}



  // --- Show Leave History data in ListView
  Widget _showLeaveHistoryDataInList(AppliedLeaveHistory leave ,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        child: BalanceLeave(
          type: leave.type.isEmpty ? '' : leave.type,
          day: leave.numberOfDays == null
              ? "0.0"
              : leave.numberOfDays.toString(),
          status: leave.status.isEmpty ? '' : leave.status,
          startDate: leave.startDate.isEmpty ? '' : leave.startDate,
          endDate: leave.endDate.isEmpty ? '' : leave.endDate,
          iconAsset: getIconForType(leave.type),
        ),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => ShowLeaveHistoryDetailsDialog(
                    leaveType: leave.type.isEmpty ? '' : leave.type,
                    des: leave.description ?? '',
                    status: leave.status.isEmpty ? '' : leave.status,
                    startDate: leave.startDate.isEmpty ? '' : leave.startDate,
                    endDate: leave.endDate.isEmpty ? '' : leave.endDate,
                    dayCount: leave.numberOfDays == null
                        ? "0.0"
                        : leave.numberOfDays.toString(),
                  ));
        },
      ),
    );
  }

  String getIconForType(String? type) {
    switch (type) {
      case 'SL':
        return KAssets.sickLeave;
      case 'CL':
        return KAssets.casualLeave;
      case 'EL':
        return KAssets.earnLeave;
      case 'Comp off':
        return KAssets.compOffLeave;
      case 'LWP':
        return KAssets.lwpLeave;
      default:
        return KAssets.casualLeave; // fallback icon
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 3,
      shadowColor: KColors.cardShadowColor,
      color: KColors.appColorWhite,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                      Text(type.isEmpty ? '' : type,
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
              elevation: 1,
              color: statusColor, // Set background color dynamically
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(status, style: KFonts.normalWithWhiteColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
