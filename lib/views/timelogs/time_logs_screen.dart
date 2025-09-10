import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_loader.dart';
import 'package:time_log/views/timelogs/create_time_log.dart';
import 'package:time_log/views/timelogs/edit_time_log.dart';
import '../../controllers/time_log_controller.dart';
import '../../models/all_time_log_res.dart';
import '../../models/assign_project_res.dart';
import '../../models/assign_task_res.dart';
import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_colors.dart';
import '../../utils/constants/k_date_and_time.dart';
import '../../utils/constants/k_drawer_menu.dart';
import '../../utils/constants/k_fonts.dart';
import '../../utils/constants/k_nav_header.dart';
import '../../utils/popups/k_material_dialog.dart';
import '../../utils/reusable_widgit/k_custom_card.dart';
import '../../utils/reusable_widgit/k_dropdown.dart';

class TimeLogsScreen extends StatefulWidget {
  final ValueNotifier<bool>? isBottomNavVisible;

  const TimeLogsScreen({super.key, this.isBottomNavVisible});

  @override
  State<TimeLogsScreen> createState() => TimeLogsScreenState();
}

class TimeLogsScreenState extends State<TimeLogsScreen> {
  final TimeLogController _controller = TimeLogController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();

  List<LstTimeLog> allTimeLogs = []; // original list (from API)
  List<LstTimeLog> timeLogs = []; // filtered list (for display)
  int currentPage = 1;
  int itemsPerPage = 5;
  int pendingCount = 0;
  int rejectedCount = 0;
  dynamic totalWorkingHrs = 0;
  bool isLoading = false;
  String? selectedQuickFilter;
  String? selectedStatusFilter;
  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  String? selectedProjectId;
  bool isProjectValid = true;
  Lstproject? selectedProject;
  String? selectedTask;
  List<Lstproject> assignProject = [];
  List<String> assignTask = [];
  int _selectedIndex = 0;

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

  /// Filter by chip (All, Pending, Approved, Rejected, etc.)
  List<LstTimeLog> getFilteredProjects() {
    List<LstTimeLog> filtered = List.from(allTimeLogs);

    if (selectedFilter.isNotEmpty && selectedFilter != "All") {
      filtered = filtered.where((log) => log.status == selectedFilter).toList();
    }

    return filtered;
  }

  // Filter by dialog popup (status, quick filter, date range, project, task)
  List<LstTimeLog> getFilteredProjectsDialog() {
    List<LstTimeLog> filtered = List.from(allTimeLogs);

    //  Chip filter
    if (selectedFilter.isNotEmpty && selectedFilter != "All") {
      filtered = filtered
          .where((log) =>
              (log.status ?? "").trim().toLowerCase() ==
              selectedFilter.trim().toLowerCase())
          .toList();
    }

    //  Status filter
    if (selectedStatusFilter != null &&
        selectedStatusFilter!.isNotEmpty &&
        selectedStatusFilter != "All") {
      filtered = filtered
          .where((log) =>
              (log.status ?? "").trim().toLowerCase() ==
              selectedStatusFilter!.trim().toLowerCase())
          .toList();
    }

    //  Date range filter
    if (selectedFromDate != null && selectedToDate != null) {
      filtered = filtered.where((log) {
        if (log.formattedDate == null) return false;
        try {
          final logDate = DateTime.parse(log.formattedDate!);
          return logDate.isAfter(
                  selectedFromDate!.subtract(const Duration(days: 1))) &&
              logDate.isBefore(selectedToDate!.add(const Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Project filter (by name)
    if (selectedProject != null) {
      filtered = filtered
          .where((log) =>
              (log.projectName ?? "").trim().toLowerCase() ==
              (selectedProject!.projectName ?? "").trim().toLowerCase())
          .toList();
    }

    //  Task filter (by name)
    if (selectedTask != null && selectedTask!.isNotEmpty) {
      filtered = filtered
          .where((log) =>
              (log.taskName ?? "").trim().toLowerCase() ==
              selectedTask!.trim().toLowerCase())
          .toList();
    }

    //  Quick filters (keep your existing working logic)
    if (selectedQuickFilter != null && selectedQuickFilter!.isNotEmpty) {
      final now = DateTime.now();
      DateTime? _getLogDate(LstTimeLog log) => log.formattedDate != null
          ? DateTime.tryParse(log.formattedDate!)
          : null;

      DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

      if (selectedQuickFilter == "This Week") {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));

        filtered = filtered.where((log) {
          final date = _getLogDate(log);
          return date != null &&
              date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              date.isBefore(endOfWeek.add(const Duration(days: 1)));
        }).toList();
      } else if (selectedQuickFilter == "Last Week") {
        final endOfLastWeek = now.subtract(Duration(days: now.weekday));
        final startOfLastWeek = endOfLastWeek.subtract(const Duration(days: 6));

        filtered = filtered.where((log) {
          final date = _getLogDate(log);
          if (date == null) return false;

          final day = _dateOnly(date);
          final startDay = _dateOnly(startOfLastWeek);
          final endDay = _dateOnly(endOfLastWeek);

          return !day.isBefore(startDay) && !day.isAfter(endDay);
        }).toList();
      } else if (selectedQuickFilter == "This Month") {
        final startOfMonth = DateTime(now.year, now.month, 1);
        final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

        filtered = filtered.where((log) {
          final date = _getLogDate(log);
          return date != null &&
              date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              date.isBefore(startOfNextMonth);
        }).toList();
      } else if (selectedQuickFilter == "Last Month") {
        final startOfThisMonth = DateTime(now.year, now.month, 1);
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth =
            startOfThisMonth.subtract(const Duration(days: 1));

        filtered = filtered.where((log) {
          final date = _getLogDate(log);
          return date != null &&
              date.isAfter(
                  startOfLastMonth.subtract(const Duration(days: 1))) &&
              date.isBefore(endOfLastMonth.add(const Duration(days: 1)));
        }).toList();
      } else if (selectedQuickFilter == "This Year") {
        final startOfYear = DateTime(now.year, 1, 1);
        final startOfNextYear = DateTime(now.year + 1, 1, 1);

        filtered = filtered.where((log) {
          final date = _getLogDate(log);
          return date != null &&
              date.isAfter(startOfYear.subtract(const Duration(days: 1))) &&
              date.isBefore(startOfNextYear);
        }).toList();
      }
    }

    return filtered;
  }

  @override
  void initState() {
    fetchData();
    fetchProjectsAndTasks();
    super.initState();
  }

  Future<void> fetchProjectsAndTasks() async {
    setState(() {
      isLoading = true;
    });

    try {
      //  Fetch Projects
      final projectResponse = await assignProjectFormSF(context);
      if (projectResponse is AssignProjectResponse) {
        setState(() {
          assignProject = projectResponse.lstprojects;
        });
      }

      //  Fetch Tasks
      final taskResponse = await assignTaskFormSF(context);
      if (taskResponse is AssignTaskResponse) {
        setState(() {
          // Convert list of objects into List<String> for dropdown
          assignTask = taskResponse.taskTypes;
        });
      }
    } catch (e) {
      print("Error loading projects/tasks: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // --- check internet connection
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
          color: KColors.appPrimaryRed,
          textStyle: const TextStyle(color: KColors.appColorWhite),
          iconColor: KColors.appColorWhite,
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
        return KColors.grayLight;
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
        showProfileIcon: false,
        topPaddingFactor: 0.04,
      ),
      drawer: CustomDrawerMenu(
        context: context,
        isBottomNavVisible: widget.isBottomNavVisible,
        selectedIndex: _selectedIndex,   // now available
        onMenuTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

      onDrawerChanged: (isOpened) {
        widget.isBottomNavVisible?.value = !isOpened;
      },
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02,
                vertical: MediaQuery.of(context).size.height * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 9, right: 9, top: 0, bottom: 8),
                    child: Column(
                      children: [
                        // Your content here
                        Column(
                          children: [
                            /// alignment of three card of hours and leave and pending leave......
                            Row(
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
                                  containerTextDigit: rejectedCount.toString(),
                                  containerTextOne: "Rejected Time",
                                  containerTextTwo: "Logs",
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.018),

                            ///  Time Log listview Filter....
                            _listViewFilter(),
                            SizedBox(
                              height: 10,
                            ),

                            /// --- show all the Filled time log.
                            _filledTimeLogAndShowInList(),
                          ],
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
        child: const Icon(Icons.add,color: KColors.appColorWhite,), // Change color if needed
      ),
    );
  }

  Widget _listViewFilter() {
    return Row(
      children: [
        Wrap(
          spacing: 2,
          runSpacing: 2,
          children: [
            ...List.generate(filters.length, (index) {
              bool isSelected = selectedIndex == index;
              return ChoiceChip(
                  checkmarkColor: KColors.appColorWhite,
                  showCheckmark: false,
                  label: Center(
                    child: Padding(
                      padding:  EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.001,),
                      child: Text(filters[index]["label"],
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                color: isSelected
                                    ? KColors.appColorWhite
                                    : filters[index]["textColor"],
                              )),
                    ),
                  ),
                  selected: isSelected,
                  backgroundColor: Colors.transparent,
                  selectedColor: filters[index]["color"],
                  shape: StadiumBorder(
                    side: BorderSide(color: filters[index]["borderColor"]),
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                      selectedStatusFilter = selectedFilter;
                      timeLogs = getFilteredProjectsDialog();
                    });
                  });
            }),
            Container(
              margin: EdgeInsets.only(left: 2),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: KColors.appColorWhite,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.tune,
                  color: KColors.appPrimary,
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
                        selectedFilter = selectedStatusFilter ?? "All";
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
        ),
      ],
    );
  }

  Widget customSelectableBox({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color selectedColor = KColors.appPrimary,
    Color unselectedColor = KColors.appColorWhite,
    Color borderColor = KColors.appPrimary,
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
            color: isSelected ? KColors.appColorWhite : borderColor,
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
    Lstproject? selectedProject,
    String? selectedTask,
  ) {
    String? _quick = selectedQuickFilter;
    String? _status = selectedStatusFilter;
    DateTime? _from = fromDate;
    DateTime? _to = toDate;
    Lstproject? _project = selectedProject; // local dialog copy
    String? _task = selectedTask; // local dialog copy

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
                      // Header + close button
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
                                  size: 20, color: KColors.appBlackColor),
                            ),
                          ),
                        ],
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),

                      // Quick filters (same as before)
                      _filterSection(
                        title: "Quick Filters",
                        children: [
                          "This Week",
                          "Last Week",
                          "This Month",
                          "Last Month",
                          "this year"
                        ].map((label) {
                          final isSelected = _quick == label;
                          return customSelectableBox(
                            label: label,
                            isSelected: isSelected,
                            borderColor: KColors.appPrimary,
                            selectedColor: KColors.appPrimary,
                            onTap: () => dialogSetState((){
                              _quick = (_quick == label) ? null : label;
                            }),
                          );
                        }).toList(),
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),

                      // Status filters (same)
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
                                dialogSetState((){
                                  _status = (_status == entry.key) ? null : entry.key;
                                }),
                          );
                        }).toList(),
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),

                      // Date range (same - keep your existing function)
                      _timeLogDateRange(
                        context,
                        dialogSetState,
                        _from,
                        _to,
                        (date) => dialogSetState(() => _from = date),
                        (date) => dialogSetState(() => _to = date),
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),
                      _selectProject(
                        dialogSetState,
                        _project,
                        (Lstproject? v) => dialogSetState((){
                          _project = (_project == v) ? null : v;
                        }),
                      ),

                      const Divider(color: Color(0x1A5C5C5C)),
                      _selectTask(
                        dialogSetState,
                        _task,
                        (String? v) => dialogSetState((){
                          _task = (_task == v) ? null : v;
                        }),
                      ),

                      const SizedBox(height: 12),
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
                                selectedQuickFilter = null;
                                selectedStatusFilter = null;
                                selectedFromDate = null;
                                selectedToDate = null;
                                selectedProject = null;
                                selectedTask = null;
                              });
                            },
                            child: const Text("Clear Filter"),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KColors.appPrimary,
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
                                style: TextStyle(color: KColors.appColorWhite)),
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
    int dayDiff =
        (from != null && to != null) ? to.difference(from).inDays.abs() + 1 : 0;

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
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
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
                          color: KColors.appPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Day Counter
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: KColors.appColorWhite,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${dayDiff.toString().padLeft(2, "0")} Day",
                  style: const TextStyle(
                      color: KColors.appPrimaryRed, fontWeight: FontWeight.w600),
                ),
              ),

              /// To Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("To Date",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
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
                          color: KColors.appPrimary,
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

  Widget _selectProject(
    Function(void Function()) dialogSetState,
    Lstproject? project,
    ValueChanged<Lstproject?> onChanged,
  ) {
    return Column(
      children: [
        KDropdownField<Lstproject>(
          value: project,
          onChanged: (value) {
            // call the passed setter; the setter will call dialogSetState
            onChanged(value);
          },
          title: 'Project',
          hint: 'Select Project',
          leaveTypes: isLoading ? [] : assignProject,
          getLabel: (p) => p.projectName,
          isRequired: true,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          dropdownIconType: DropdownIconType.chevronDown,
        ),
      ],
    );
  }

  Widget _selectTask(
    Function(void Function()) dialogSetState,
    String? task,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      children: [
        KDropdownField<String>(
          value: task,
          onChanged: (value) {
            onChanged(value);
          },
          title: 'Task Type',
          hint: 'Select Task',
          leaveTypes: isLoading ? [] : assignTask,
          getLabel: (t) => t,
          isRequired: true,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          dropdownIconType: DropdownIconType.chevronDown,
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
    final totalPages = (filteredProjects.isEmpty)
        ? 0
        : (filteredProjects.length / itemsPerPage).ceil();
    if (currentPage > totalPages && totalPages > 0) {
      currentPage = totalPages;
    } else if (totalPages == 0) {
      currentPage = 1;
    }
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage) > filteredProjects.length
        ? filteredProjects.length
        : (startIndex + itemsPerPage);
    final currentPageItems =
    (filteredProjects.isNotEmpty && startIndex < filteredProjects.length)
        ? filteredProjects.sublist(startIndex, endIndex)
        : [];
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
              : Column(
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: currentPageItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        final project = currentPageItems[index];

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
                                :  MediaQuery.of(context).size.height *
                                0.14 , // Let it wrap content on phones
                            width: 374,
                            child: Card(
                              color: KColors.appColorWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                              shadowColor: KColors.cardShadowColor,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
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
                                          flex: 7,
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
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 7,
                                          child: Column(
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
                                            child: Column(
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
                   SizedBox(height: MediaQuery.of(context).size.height * 0.001,),
                  if (totalPages > 1)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 16),
                          onPressed: currentPage > 1
                              ? () => setState(() => currentPage--)
                              : null,
                        ),

                        // Page numbers with ellipsis
                        ..._buildPageNumbers(totalPages),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed: currentPage < totalPages
                              ? () => setState(() => currentPage++)
                              : null,
                        ),
                      ],
                    ),
                ],
              ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    List<Widget> pages = [];

    for (int i = 1; i <= totalPages; i++) {
      if (i == 1 ||
          i == totalPages ||
          (i >= currentPage - 1 && i <= currentPage + 1)) {
        pages.add(
          GestureDetector(
            onTap: () => setState(() => currentPage = i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: currentPage == i ? KColors.appPrimary : KColors.appColorWhite,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: KColors.appPrimary),
              ),
              child: Text(
                "$i",
                style: TextStyle(
                  color: currentPage == i ? KColors.appColorWhite : KColors.appPrimary,
                ),
              ),
            ),
          ),
        );
      } else if (i == 2 && currentPage > 3) {
        pages.add(const Text("..."));
      } else if (i == totalPages - 1 && currentPage < totalPages - 2) {
        pages.add(const Text("..."));
      }
    }

    return pages;
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
