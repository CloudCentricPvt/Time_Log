import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_loader.dart';
import 'package:time_log/views/timelogs/create_time_log.dart';
import 'package:time_log/views/timelogs/edit_time_log.dart';
import '../../models/all_time_log_res.dart';
import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/constants/k_date_and_time.dart';
import '../../utils/constants/k_drawer_menu.dart';
import '../../utils/constants/k_fonts.dart';
import '../../utils/constants/k_nav_header.dart';
import '../../utils/popups/k_material_dialog.dart';
import '../../utils/reusable_widgit/k_custom_card.dart';

class TimeLogsScreen extends StatefulWidget {
  final ValueNotifier<bool>? isBottomNavVisible;

  const TimeLogsScreen({super.key, this.isBottomNavVisible});

  @override
  State<TimeLogsScreen> createState() => TimeLogsScreenState();
}

class TimeLogsScreenState extends State<TimeLogsScreen> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();

  List<LstTimeLog> allTimeLogs = []; // original list (from API)
  List<LstTimeLog> timeLogs = []; // filtered list (for display)

  int pendingCount = 0;
  int rejectedCount = 0;
  dynamic totalWorkingHrs = 0;
  bool isLoading = false;
  String? selectedQuickFilter;
  String? selectedStatusFilter;
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  String selectedProject = "Select Project";
  String selectedTask = "Select Task";
  final List<String> projectItems = [
    "Select Project",
    "Leave/Holiday (April 2024 - March 2025)",
    "Self Study (April 2024 - March 2025)",
    "UI/UX Designing FY 24-25"
  ];
  final List<String> taskItems = [
    "Select Task",
    "UI Design",
    "Backend Development",
    "API Integration",
    "Testing",
  ];

  /// time log filter chip functions.....
  int selectedIndex = 0;
  final List<Map<String, dynamic>> filters = [
    {
      "label": "All",
      "status": "All",
      "color": KColors.appPrimary,
      "textColor": KColors.appPrimary,
      "borderColor": KColors.appPrimary,
    },
    {
      "label": "Pending",
      "status": "Pending",
      "color": KColors.orangeColor,
      "textColor": KColors.orangeColor,
      "borderColor": KColors.orangeColor,
    },
    {
      "label": "Approved",
      "status": "Approved",
      "color": KColors.greenColor,
      "textColor": KColors.greenColor,
      "borderColor": KColors.greenColor
    },
    {
      "label": "Rejected",
      "status": "Rejected",
      "color": KColors.appPrimaryRed,
      "textColor": KColors.appPrimaryRed,
      "borderColor": KColors.appPrimaryRed,
    },
  ];

  /// show card on the basis of filters(pending,approved,.........)
  String selectedFilter = "All"; // Initial value set to "All"

  List<LstTimeLog> getFilteredProjects() {
    if (selectedFilter == 'All') {
      return List.from(allTimeLogs);
    } else {
      return allTimeLogs
          .where((item) => item.status == selectedFilter)
          .toList();
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
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
    fetchLogs();
  }

  void fetchData() {
    _checkInternetConnection();
  }

  ///--- go back then Reload Created time log list.
  void _goToCreateTimeLogeScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTimeLog()),
    );
    if (result == true) {
      fetchLogs(); // Reload data when returning from CreateTimeLog screen
    }
  }

  Future<void> _refreshData() async {
    // Your logic to refresh data
    //await Future.delayed(Duration(seconds: 1)); // Simulate API call or database load
    setState(() {
      fetchLogs();
    });
  }

  /// Function to get color based on status
  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return KColors.orangeColor;
      case 1:
        return KColors.greenColor;
      case 2:
        return KColors.appPrimary;
      case 3:
        return KColors.appPrimaryRed;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: KCustomDrawer.customDrawer(
        context: context,
        title: "Time Log",
        titleColor: KColors.appBlackColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        showBellIcon: true,
        // Show Bell Icon
        showProfileIcon: false, // Hide Profile Icon
      ),
      drawer: CustomDrawerMenu(
        context: context,
        isBottomNavVisible: widget.isBottomNavVisible,
      ),

      onDrawerChanged: (isOpened) {
        widget.isBottomNavVisible?.value = !isOpened;
      },
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Padding(
            padding:
            const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 0, bottom: 8),
                    child: Column(
                      children: [
                        // Your content here
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Column(
                            children: [
                              /// alignment of three card of hours and leave and pending leave......
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomCard(
                                    textColor: KColors.appColorWhite,
                                    myColor: KColors.appPrimary,
                                    containerTextDigit:
                                    (totalWorkingHrs is double)
                                        ? totalWorkingHrs.toInt().toString()
                                        : totalWorkingHrs.toString(),
                                    containerTextOne: "Total working",
                                    containerTextTwo: "hours this month",
                                  ),

                                  /// Second card.....
                                  CustomCard(
                                    textColor: KColors.appColorWhite,
                                    myColor: KColors.orangeColor,
                                    containerTextDigit: pendingCount.toString(),
                                    containerTextOne: "Pending Time ",
                                    containerTextTwo: "Logs",
                                  ),

                                  /// third card.....
                                  CustomCard(
                                    textColor: KColors.appColorWhite,
                                    myColor: KColors.appPrimaryRed,
                                    containerTextDigit:
                                    rejectedCount.toString(),
                                    containerTextOne: "Rejected Time",
                                    containerTextTwo: "Logs",
                                  ),
                                ],
                              ),

                              ///  Time Log listview Filter....
                              _listViewFilter(),
                              SizedBox(
                                height: 10,
                              ),

                              /// --- show all the Filled time log.
                              _filledTimeLogAndShowInList(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),

      /// floating action button for Create Time log screen......
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _goToCreateTimeLogeScreen();
          //Navigator.pushNamed(context, '/create_time_logs_screen');
        }, // Edit icon to indicate edit functionality
        backgroundColor: KColors.appPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.add), // Change color if needed
      ),
    );
  }

  Widget _listViewFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...List.generate(filters.length, (index) {
          bool isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(left: 1, right: 1),
            child: Padding(
              padding: const EdgeInsets.all(0.8),
              child: ChoiceChip(
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  label: Padding(
                    padding: const EdgeInsets.only(left: 1, right: 1),
                    child: Text(filters[index]["label"],
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: isSelected
                              ? Colors.white
                              : filters[index]["textColor"],
                        )),
                  ),
                  selected: isSelected,
                  backgroundColor: Colors.transparent,
                  selectedColor: filters[index]["color"],
                  shape: StadiumBorder(
                    side: BorderSide(color: filters[index]["borderColor"]),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedIndex = index;

                      if (selectedIndex == 0) {
                        selectedFilter = "All";
                      } else if (selectedIndex == 1) {
                        selectedFilter = "Pending";
                      } else if (selectedIndex == 2) {
                        selectedFilter = "Approved";
                      } else if (selectedIndex == 3) {
                        selectedFilter = "Rejected";
                      }
                      timeLogs =
                          getFilteredProjects(); // Now filters from original
                    });
                  }),
            ),
          );
        }),
        Container(
          margin: EdgeInsets.only(left: 8),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.tune,
              color: Colors.blue,
              size: 20,
            ),
            onPressed: () async {
              final _prevQuickFilter = selectedQuickFilter;
              final _prevStatusFilter = selectedStatusFilter;
              final _prevFromDate = selectedFromDate;
              final _prevToDate = selectedToDate;
              final _prevProject = selectedProject;
              final _prevTask = selectedTask;

              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => _timeLogFilterPopUp(
                  context,
                  selectedQuickFilter,
                  selectedStatusFilter,
                  selectedFromDate,
                  selectedToDate,
                  selectedProject,
                  selectedTask,
                ),
              );

              if (result != null) {
                setState(() {
                  selectedQuickFilter = result['quickFilter'];
                  selectedStatusFilter = result['statusFilter'];
                  selectedFromDate = result['fromDate'];
                  selectedToDate = result['toDate'];
                  selectedProject = result['project'];
                  selectedTask = result['task'];
                  if (selectedStatusFilter != null) {
                    selectedFilter = selectedStatusFilter!;
                    if (selectedStatusFilter == "Pending") {
                      selectedIndex = 1;
                    } else if (selectedStatusFilter == "Approved") {
                      selectedIndex = 2;
                    } else if (selectedStatusFilter == "Rejected") {
                      selectedIndex = 3;
                    }
                  } else {
                    // No status selected in dialog → keep "All"
                    selectedFilter = "All";
                    selectedIndex = 0;
                  }
                  timeLogs = getFilteredProjectsDialog();
                });
              } else {

                setState(() {
                  selectedQuickFilter = _prevQuickFilter;
                  selectedStatusFilter = _prevStatusFilter;
                  selectedFromDate = _prevFromDate;
                  selectedToDate = _prevToDate;
                  selectedProject = _prevProject;
                  selectedTask = _prevTask;
                  timeLogs = getFilteredProjectsDialog();
                });
              }
  },
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: isSelected ? Colors.white : borderColor,
          ),
        ),
      ),
    );
  }

  Widget _timeLogFilterPopUp(
      BuildContext context,
      String? selectedQuickFilter,
      String? selectedStatusFilter,
      DateTime? fromDate,
      DateTime? toDate,
      String? selectedProject,
      String? selectedTask,
      ) {
    String? _quick = selectedQuickFilter;
    String? _status = selectedStatusFilter;
    DateTime? _from = fromDate;
    DateTime? _to = toDate;
    String? _project = selectedProject;
    String? _task = selectedTask;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: KColors.appColorWhite,
        insetPadding: EdgeInsets.zero,
        child: StatefulBuilder(
          builder: (context, dialogSetState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.02,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Text(
                            'Time Log Filters',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context, {
                              "quickFilter": _quick,
                              "statusFilter": _status,
                              "fromDate": _from,
                              "toDate": _to,
                              "project": _project,
                              "task": _task,
                            }),
                            child: const CircleAvatar(
                              backgroundColor: Color(0xFFF6F4FC),
                              radius: 20,
                              child: Icon(Icons.close,
                                  size: 20, color: Colors.black),
                            ),
                          ),
                        ],
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),

                      // Quick Filters
                      _filterSection(
                        title: "Quick Filters",
                        children: [
                          "This Week",
                          "Last Week",
                          "This Month",
                          "Last Month",
                          "This Year"
                        ].map((label) {
                          final isSelected = _quick == label;
                          return customSelectableBox(
                            label: label,
                            isSelected: isSelected,
                            borderColor: Colors.blue,
                            selectedColor: Colors.blue,
                            onTap: () => dialogSetState(() => _quick = label),
                          );
                        }).toList(),
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),

                      // Status Filters
                      _filterSection(
                        title: "Status Filters",
                        children: {
                          "Pending": KColors.orangeColor,
                          "Approved": KColors.greenColor,
                          "Rejected": KColors.appPrimaryRed,
                        }.entries.map((entry) {
                          final isSelected = _status == entry.key;
                          return customSelectableBox(
                            label: entry.key,
                            isSelected: isSelected,
                            borderColor: entry.value,
                            selectedColor: entry.value,
                            onTap: () =>
                                dialogSetState(() => _status = entry.key),
                          );
                        }).toList(),
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),

                      // Date Range Filter
                      _timeLogDateRange(
                        context,
                        dialogSetState,
                        _from,
                        _to,
                            (date) => dialogSetState(() => _from = date),
                            (date) => dialogSetState(() => _to = date),
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),

                      // Project Filter
                      _dropdownFilter(
                        title: "Project",
                        value: _project,
                        items: projectItems,
                        // your project list
                        onChanged: (value) =>
                            dialogSetState(() => _project = value),
                        isRequired: true,
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),

                      // Task Filter
                      _dropdownFilter(
                        title: "Task",
                        value: _task,
                        items: taskItems,
                        // your task list
                        onChanged: (value) =>
                            dialogSetState(() => _task = value),
                        isRequired: false,
                      ),

                      const SizedBox(height: 12),

                      // Buttons
                      Row(
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: KColors.appPrimary),
                              foregroundColor: KColors.appPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 19, vertical: 2),
                            ),
                            onPressed: () {
                              dialogSetState(() {
                                _quick = null;
                                _status = null;
                                _from = null;
                                _to = null;
                                _project = null;
                                _task = null;
                              });
                            },
                            child: const Text("Clear Filter"),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, {
                              "quickFilter": _quick,
                              "statusFilter": _status,
                              "fromDate": _from,
                              "toDate": _to,
                              "project": _project,
                              "task": _task,
                            }),
                            child: const Text("Apply All Filters",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _filterSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }


  Widget _timeLogDateRange(
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
            color:Color(0xFFF6F4FC),
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
                          lastDate: DateTime.now(),
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

  Widget _dropdownFilter({
    required String title,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: TextStyle(
              color: Colors.black.withOpacity(0.8),
            ),
            label: RichText(
              text: TextSpan(
                text: title,
                style: const TextStyle(color: Colors.black, fontSize: 15),
                children: isRequired
                    ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontSize: 17),
                  )
                ]
                    : [],
              ),
            ),
            hintText: hintText ?? "Select $title",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(width: 1, color: Colors.black54),
            ),
          ),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            value ?? "N/A",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> fetchLogs() async {
    setState(() {
      isLoading = true;
    });

    final response = await getAllTimeLog(context);

    if (response is AllTimeLogResponse) {
      setState(() {
        allTimeLogs = response.data?.lstTimeLogs ?? [];
        timeLogs = List.from(allTimeLogs); // initially show all
        pendingCount = response.data?.pendingCount ?? 0;
        rejectedCount = response.data?.rejectedCount ?? 0;
        totalWorkingHrs = response.data?.totalMonthlyHours ?? 0;

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Widget _filledTimeLogAndShowInList() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final filteredProjects = getFilteredProjectsDialog();
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: isLoading
          ? SizedBox(
          height: isTablet
              ? MediaQuery.of(context).size.height * 0.6 // for tablet
              : MediaQuery.of(context).size.height * 0.5, // for mobile
          child: Center(child: KLoader()))
          : filteredProjects.isEmpty
          ? SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Center(child: Text("No Data Found!")),
      )
          : ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: filteredProjects.length,
        itemBuilder: (BuildContext context, int index) {
          final project = filteredProjects[index];

          Color statusColor = project.status == "Pending"
              ? KColors.orangeColor
              : project.status == "Approved"
              ? KColors.greenColor
              : KColors.appPrimaryRed;


          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => DetailDialog(
                  onUpdate: fetchLogs,
                  timeLogId: project.timelogId,
                  projectId: project.projectId,
                  project: project.projectName,
                  task: project.taskName,
                  date: KDateAndTime()
                      .getDay(project.formattedDate ?? ""),
                  des: project.description,
                  remarks: project.remarks,
                  monthYear: KDateAndTime()
                      .getMonthYear(project.formattedDate ?? ""),
                  hrs: project.hours.toString(),
                  min: project.minutes.toString(),
                  status: project.status ?? "",
                ),
              );
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.width > 600
                  ? MediaQuery.of(context).size.height *
                  0.11 // Tablet height
                  : null, // Let it wrap content on phones
              width: 374,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                shadowColor: KColors.cardShadowColor,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      left: BorderSide(
                        color: statusColor,
                        width: 2,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.all(10),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.projectName ?? "No Project",
                                  maxLines: 1,
                                  style: KFonts.normalBold,
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius:
                                      BorderRadius.circular(2),
                                    ),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 1),
                                      child: Text(
                                        project.taskName ?? "Null",
                                        maxLines: 1,
                                        style:
                                        KFonts.normalWithWithText,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Container(
                                    height: 35,
                                    width: 1,
                                    color: Color(0xFFEDEDED),
                                  ),
                                ],
                              )),
                          Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                    KDateAndTime().getDay(
                                        project.formattedDate ?? ""),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    KDateAndTime().getMonthYear(
                                        project.formattedDate ?? ""),
                                    style: KFonts.normalBoldWithGray,
                                  ),
                  ],
                              )),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child:Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.description ??
                                      "No Description",
                                  style: KFonts.thin,
                                  maxLines: 2,
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Container(
                                    height: 35,
                                    width: 1,
                                    color: Color(0xFFEDEDED),
                                  ),
                                ],
                              )),
                          Expanded(
                              flex: 3,
                              child:Column(
                                children: [
                                  Text(
                                    project.minutes == 0
                                        ? "${project.hours}"
                                        : "${project.hours}:${project.minutes}",
                                    style: TextStyle(
                                      color: statusColor,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Hours',
                                    style: KFonts.normalBoldWithGray,
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<LstTimeLog> getFilteredProjectsDialog() {
    print("Applying filters");
    print("selectedFilter: $selectedFilter");
    print("selectedStatusFilter: $selectedStatusFilter");
    print("selectedQuickFilter: $selectedQuickFilter");
    print("selectedFromDate: $selectedFromDate");
    print("selectedToDate: $selectedToDate");
    print("selectedProject: $selectedProject");
    print("selectedTask: $selectedTask");

    final projectFilter = (selectedProject == null || selectedProject == "Select Project")
        ? null
        : selectedProject;
    final taskFilter = (selectedTask == null || selectedTask == "Select Task")
        ? null
        : selectedTask;

    // If no filters are selected, return everything
    if ((selectedFilter == null || selectedFilter == "All") &&
        selectedStatusFilter == null &&
        selectedQuickFilter == null &&
        selectedFromDate == null &&
        selectedToDate == null &&
        projectFilter == null &&
        taskFilter == null) {
      print(" No filters applied, returning all ${timeLogs.length} logs");
      return timeLogs;
    }

    // Start with all logs
    List<LstTimeLog> filtered = List.from(timeLogs);

    // Apply Status Filter (selectedFilter takes priority)
    if (selectedFilter != null && selectedFilter != "All") {
      filtered = filtered.where((log) => log.status == selectedFilter).toList();
    } else if (selectedStatusFilter != null) {
      filtered = filtered.where((log) => log.status == selectedStatusFilter).toList();
    }


    // Apply Status Filter
    if (selectedFilter != null && selectedFilter != "All") {
      filtered = filtered.where((log) => log.status == selectedFilter).toList();
    } else if (selectedStatusFilter != null) {
      filtered = filtered.where((log) => log.status == selectedStatusFilter).toList();
    }

    // Quick Filter
    if (selectedQuickFilter != null) {
      DateTime now = DateTime.now();
      DateTime start;
      DateTime end;

      switch (selectedQuickFilter) {
        case "This Week":
          start = now.subtract(Duration(days: now.weekday - 1));
          end = start.add(const Duration(days: 6));
          break;
        case "Last Week":
          end = now.subtract(Duration(days: now.weekday));
          start = end.subtract(const Duration(days: 6));
          break;
        case "This Month":
          start = DateTime(now.year, now.month, 1);
          end = DateTime(now.year, now.month + 1, 0);
          break;
        case "Last Month":
          start = DateTime(now.year, now.month - 1, 1);
          end = DateTime(now.year, now.month, 0);
          break;
        case "This Year":
          start = DateTime(now.year, 1, 1);
          end = DateTime(now.year, 12, 31);
          break;
        default:
          start = now;
          end = now;
      }

      filtered = filtered.where((log) {
        final logDate = DateTime.tryParse(log.formattedDate ?? "");
        return logDate != null &&
            logDate.isAfter(start.subtract(const Duration(days: 1))) &&
            logDate.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    }

    // Date Range Filter
    if (selectedFromDate != null && selectedToDate != null) {
      filtered = filtered.where((log) {
        final logDate = DateTime.tryParse(log.formattedDate ?? "");
        return logDate != null &&
            logDate.isAfter(selectedFromDate!.subtract(const Duration(days: 1))) &&
            logDate.isBefore(selectedToDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Project Filter
    if (projectFilter  != null) {
      filtered = filtered.where((log) => log.projectName == selectedProject).toList();
    }

    // Task Filter
    if (taskFilter != null) {
      filtered = filtered.where((log) => log.taskName == selectedTask).toList();
    }

    print("Returning ${filtered.length} filtered logs");
    return filtered;
  }



}

class DetailDialog extends StatelessWidget {
  final VoidCallback onUpdate;
  final String? timeLogId;
  final String? project;
  final String? projectId;
  final String? task;
  final String? des;
  final String? remarks;
  final String? date;
  final String? monthYear;
  final String? hrs;
  final String? min;
  final String? status;

  const DetailDialog(
      {super.key,
        required this.onUpdate, // <- ADD THIS
        this.timeLogId,
        this.project,
        this.projectId,
        this.task,
        this.remarks,
        this.date,
        this.des,
        this.monthYear,
        this.hrs,
        this.min,
        this.status});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: double.infinity, // Match parent
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content vertically
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Status :",
                      style: KFonts.normalHeading,
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2)),
                      shadowColor: KColors.cardShadowColor,
                      color: getStatusColor1(status),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6, right: 6),
                        child: Text(
                          status ?? "",
                          style: KFonts.normalBoldWithWhite,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2)),
                          color: KColors.colorGray,
                          shadowColor: KColors.cardShadowColor,
                          child: Visibility(
                            visible: status == 'Pending',
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6, right: 6),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 25,
                                    width: 18,
                                    child: SvgPicture.asset(
                                      'assets/icons/edit_profile.svg',
                                      color: getStatusColor1(status),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Edit",
                                    style: KFonts.normal,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        onTap: () async {
                          Navigator.pop(context); // Close dialog first

                          await Future.delayed(Duration
                              .zero); // Wait for the next frame to push new screen

                          final result = await Navigator.pushNamed(
                            context,
                            '/edit_time_log_screen',
                            arguments: {
                              'timeLodId': timeLogId,
                              'projectId': projectId,
                              'projectName': project,
                              'taskName': task,
                              'des': des,
                              'hrs': hrs,
                              'min': min,
                              'date': date,
                              'monthsYear': monthYear,
                            },
                          );

                          if (result == true) {
                            onUpdate(); // This will refresh the list
                          }
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        color: KColors.colorGray,
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(KAssets.crossIcon),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Project: ",
                  style: KFonts.normalBold,
                ),
                Text(
                  project ?? "",
                  style: KFonts.normal,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Task: ",
                  style: KFonts.normalBold,
                ),
                Text(
                  task ?? "",
                  style: KFonts.normal,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Description: ",
                            style: KFonts.normalBold,
                          ),
                          Text(
                            des ?? "",
                            style: KFonts.thin,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Remarks: ",
                            style: KFonts.normalBold,
                          ),
                          Text(
                            remarks ?? "",
                            style: KFonts.thin,
                          )
                        ],
                      )),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 2, // Line thickness
                            height: 40, // Adjust height as needed
                            color: KColors.colorGray, // Line color
                          ),
                          Spacer(),
                          Column(
                            children: [
                              Text(date ?? "",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: getStatusColor1(status))),
                              Text(
                                monthYear ?? "",
                                style: KFonts.normal,
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 2, // Line thickness
                            height: 40, // Adjust height as needed
                            color: KColors.colorGray, // Line color
                          ),
                          Spacer(),
                          Column(
                            children: [
                              Text(min == '0' ? "$hrs" : "$hrs:$min",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: getStatusColor1(status))),
                              Text(
                                'Hours',
                                style: KFonts.normal,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 12,
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color getStatusColor1(String? status) {
    return status == "Pending"
        ? KColors.orangeColor
        : status == "Approved"
        ? KColors.greenColor
        : KColors.appPrimaryRed;
  }
}
