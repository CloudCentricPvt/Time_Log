import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

import '../../models/comp_off_history_res.dart';
import '../../models/wfh_history_res.dart';
import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/constants/k_date_and_time.dart';
import '../../utils/constants/k_fonts.dart';
import '../../utils/constants/k_loader.dart';
import '../../utils/constants/show_leave_history_details_dialog.dart';
import '../../utils/popups/k_filter_dialog.dart';
import '../../utils/popups/k_material_dialog.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import '../../utils/reusable_widgit/k_filter_header.dart';
import 'balance_leave_screen.dart';

class CompOffHistoryScreen extends StatefulWidget {
  const CompOffHistoryScreen({super.key});

  @override
  State<CompOffHistoryScreen> createState() => _CompOffHistoryScreenState();
}

class _CompOffHistoryScreenState extends State<CompOffHistoryScreen> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();

  bool _isLoading = true;
  String selectedStatus = 'All';
  List<CompOff> compOffList = [];
  String selectedProject = "Select Project";
  String selectedTask = "Select Task";

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
      fetchCompOffData();
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
    fetchCompOffData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF84DBFF), // Same as app bar
          statusBarIconBrightness: Brightness.dark, // or .light depending on contrast
        ),
        title: KCustomAppBar(
          screenTitle: 'Comp OFF History',
          historyTitle: 'Request New',
          showHistory: true,
          onHistoryTap: () {
            Navigator.pushNamed(context, '/comp_off_screen');
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
                  children: [
                    KFilterHeader(
                        width: 65,
                        textTitle: 'All',
                        strokeColor: KColors.appPrimary,
                        textColor: selectedStatus == 'All' ? KColors.appColorWhite : KColors.appPrimary,
                        backgroundColor: selectedStatus == 'All' ? KColors.appPrimary : Colors.transparent,
                        onHistoryTap: () {
                          setState(() {
                            selectedStatus = 'All';
                          });
                        }),
                    KFilterHeader(
                        textTitle: 'Pending',
                        strokeColor: KColors.orangeColor,
                        //textColor: KColors.orangeColor,
                        textColor: selectedStatus == 'Pending' ? KColors.appColorWhite : KColors.orangeColor,
                        backgroundColor: selectedStatus == 'Pending' ? KColors.orangeColor : Colors.transparent,
                        onHistoryTap: () {
                          setState(() {
                            selectedStatus = 'Pending';
                          });
                        }),
                    KFilterHeader(
                        textTitle: 'Approved',
                        strokeColor: KColors.greenColor,
                        textColor: selectedStatus == 'Approved' ? KColors.appColorWhite : KColors.greenColor,
                        backgroundColor: selectedStatus == 'Approved' ? KColors.greenColor : Colors.transparent,
                        onHistoryTap: () {
                          setState(() {
                            selectedStatus = 'Approved';
                          });
                        }),
                    KFilterHeader(
                        textTitle: 'Rejected',
                        strokeColor: KColors.appPrimaryRed,
                        textColor: selectedStatus == 'Rejected' ? KColors.appColorWhite : KColors.appPrimaryRed,
                        backgroundColor: selectedStatus == 'Rejected' ? KColors.appPrimaryRed : Colors.transparent,
                        onHistoryTap: () {
                          setState(() {
                            selectedStatus = 'Rejected';
                          });
                        }),
                    /// --- filter by multiple option
                    /*GestureDetector(
                      child: SvgPicture.asset(KAssets.filterIcon),
                      onTap: () {
                        FilterDialog.showTimeLogFilterDialog(
                          context,
                          projectItems,
                          selectedProject,
                          selectedTask,
                          taskItems,
                          (String? newProject) {
                            setState(() {
                              selectedProject = newProject!;
                            });
                          },
                          (String? newTask) {
                            setState(() {
                              selectedTask = newTask!; // Update the selected task
                            });
                          },
                        );
                      },
                    ),*/
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? KLoader()
                    : Builder(
                        builder: (context) {
                          final filteredList = _getFilteredList(); // filter once
                          return filteredList.isEmpty
                              ? const Center(child: Text("No data found!"))
                              : ListView.builder(
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) {
                                    final leave = filteredList[index];
                                    return _showCompOffHistoryDataInList(leave);
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

  void fetchCompOffData() async {
    var result = await getCompOffHistory(context);
    print('History of Comp Off: $result');
    if (result is CompOffHistoryResponse) {
      setState(() {
        compOffList = result.data;
        _isLoading = false;
      });
    }
  }

  /// --- Show WFH History data in ListView
  Widget _showCompOffHistoryDataInList(CompOff leave) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        child: BalanceLeave(
          type: leave.requestType.toString() ?? '',
          day: leave.numberOfDays == null
              ? "0.0"
              : leave.numberOfDays.toString(),
          status: leave.status.toString() ?? '',
          startDate: leave.startDate.isEmpty ? '' : leave.startDate,
          endDate: leave.endDate.isEmpty ? '' : leave.endDate,
          iconAsset: getIconForStatus(leave.status),
        ),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => ShowLeaveHistoryDetailsDialog(
                    leaveType: leave.requestType,
                    des: leave.description,
                    status: leave.status,
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

  String getIconForStatus(String? status) {
    switch (status) {
      case 'Pending':
        return KAssets.compOffPending;
      case 'Approved':
        return KAssets.compOffApproved;
      case 'Rejected':
        return KAssets.compOffRejected;
      default:
        return KAssets.compOffPending; // fallback icon
    }
  }

  List<CompOff> _getFilteredList() {
    if (selectedStatus == 'All') {
      return List.from(compOffList);
    } else {
      return compOffList
          .where((item) =>
              item.status.trim().toLowerCase() == selectedStatus.toLowerCase())
          .toList();
    }
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
                      Text(type == 'Comp Off' ? 'Comp Off' : 'Comp Off',
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
