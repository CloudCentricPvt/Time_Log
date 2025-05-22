import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  const TimeLogsScreen({super.key});

  @override
  State<TimeLogsScreen> createState() => _TimeLogsScreen();
}

class _TimeLogsScreen extends State<TimeLogsScreen> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();

  List<LstTimeLog> allTimeLogs = []; // original list (from API)
  List<LstTimeLog> timeLogs = []; // filtered list (for display)

  int pendingCount = 0;
  int rejectedCount = 0;
  dynamic totalWorkingHrs = 0;
  bool isLoading = false;

  String selectedProject = "Select Project";
  String selectedTask = "Select Task";
  final List<String> projectItems = [
    "Select Project",
    "Leave/Holiday (April 2024 - March 2025)",
    "Self Study (April 2024 - March 2025)",
    "UI/UX Designing FY 24-25"
  ];
  final List<String> taskItems = [
    "UI/ux CloudCentric",
    "Uux FieldBan",
    "ui/ux CloudConics",
    "UI/ux SocialPols",
    "ui/ux Desers",
    "Other"
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
    _checkInternetConnection();
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
    await Future.delayed(Duration(seconds: 1)); // Simulate API call or database load
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
        title: "Time Loge",
        titleColor: KColors.appBlackColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        showBellIcon: true,
        // Show Bell Icon
        showProfileIcon: false, // Hide Profile Icon
      ),
      drawer: CustomDrawerMenu(context: context),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Time log cards.....
                Align(
                  alignment: Alignment.topCenter, // Align content to the top
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
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomCard(
                                    textColor: KColors.appColorWhite,
                                    myColor: KColors.appPrimary,
                                    containerTextDigit:
                                    (totalWorkingHrs is double) ? totalWorkingHrs.toInt().toString() : totalWorkingHrs.toString(),
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

  /// Time Log filter-options(all,pending,approved......).......
  Widget _listViewFilter() {
    return Row(
      children: [
        /// --- Time Log Status
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(filters.length, (index) {
                bool isSelected = selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(left: 2, right: 2),

                  /// we are using choice-chip bcz we need to select single option from a set of options.....

                  child: Padding(
                    padding: const EdgeInsets.all(0.8),
                    child: ChoiceChip(
                        checkmarkColor: Colors.white,
                        showCheckmark: false,
                        label: Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: Text(filters[index]["label"],
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
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
                            timeLogs = getFilteredProjects(); // Now filters from original
                          });
                        }),
                  ),
                );
              }),
            ),
          ),
        ),

        /// --- Filter Icon pop-up  UI design......quick filter
        /*Container(
          margin: EdgeInsets.only(left: 8),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
            //shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
          ),

          /// filter icon......
          child: IconButton(
            icon: const Icon(
              Icons.tune,
              color: Colors.blue,
              size: 20,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    // Use Dialog instead of AlertDialog for full control
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Optional: Rounded corners
                    ),
                    insetPadding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      // Add padding for better UI
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Time Log Filters',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600),
                              ),
                              Spacer(),

                              /// close button design of pop-up screen......
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors
                                          .white, // Background color to match design
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      // Adjust padding for better appearance
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(
                                              context); // Close dialog
                                        },
                                        child: Text(
                                          "X", // Close symbol
                                          style: TextStyle(
                                            fontSize: 21,
                                            // Adjust size for visibility
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black, // Black color
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(
                            color: Color(0x1A5C5C5C),
                            thickness: 1,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Filters',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              /// quick filters radio button like(this week,last week and so on)......

                              Column(
                                children: [
                                  Row(
                                    children: [
                                      _roundedRectangularBox(
                                        text: "This Week",
                                        textColor: Colors.blue,
                                        borderColor: Colors.blue,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      _roundedRectangularBox(
                                        text: "Last Week",
                                        textColor: Colors.blue,
                                        borderColor: Colors.blue,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      _roundedRectangularBox(
                                        text: "This Month",
                                        textColor: Colors.blue,
                                        borderColor: Colors.blue,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      _roundedRectangularBox(
                                        text: "Last Month",
                                        textColor: Colors.blue,
                                        borderColor: Colors.blue,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      _roundedRectangularBox(
                                        text: "This Year",
                                        textColor: Colors.blue,
                                        borderColor: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Divider(
                            color: Color(0x1A5C5C5C),
                            thickness: 1,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Filters',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500),
                              ),
                              Row(
                                children: [
                                  _roundedRectangularBox(
                                    text: "Pending",
                                    textColor: Colors.orange,
                                    borderColor: Colors.orange,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  _roundedRectangularBox(
                                    text: "Approved",
                                    textColor: Colors.green,
                                    borderColor: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  _roundedRectangularBox(
                                    text: "Rejected",
                                    textColor: Colors.red,
                                    borderColor: Colors.red,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),

                          /// Date range filters card.......
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                color: Color(0x1A5C5C5C),
                                thickness: 1,
                              ),
                              Text(
                                'Date Range Filters',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500),
                              ),
                              Wrap(
                                /// wrap prevents overflow
                                spacing: 10,
                                children: [
                                  SizedBox(
                                    height: 100,
                                    width: 500, // Card width
                                    child: Card(
                                      color: Color(0xFFd8d8d8),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            15), // Rounded corners
                                        // Border color
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'From Date',
                                                  style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Select From Date',
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    // White background
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8), // Rounded corners
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8,
                                                            horizontal: 16),
                                                    // Inner spacing
                                                    child: Text(
                                                      '00 Day',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'To Date',
                                                  style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  'Select To Date',
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Divider(
                                color: Color(0x1A5C5C5C),
                                thickness: 1,
                              ),
                              Text(
                                'Project Filters',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500),
                              ),
                              _projectSelectCard(),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                color: Color(0x1A5C5C5C),
                                thickness: 1,
                              ),
                              Text(
                                'Task Filters',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                  width: double.infinity,
                                  child: _selectTaskCard()),
                            ],
                          ),
                          Column(
                            children: [
                              Divider(
                                color: Color(0x1A5C5C5C),
                                thickness: 1,
                              ),
                              Row(
                                children: [
                                  _roundedRectangularBox(
                                    text: "Pending",
                                    textColor: Colors.blue,
                                    borderColor: Colors.blue,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child:

                                        /// apply filters button....
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 140,
                                            height: 30,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                *//* Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TimelogScreen()),
                                                );*//*
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                backgroundColor:
                                                    KColors.appPrimary,
                                              ),
                                              child: const Text(
                                                'Apply All Filters',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 11),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                },
              );
            },
          ),
        ),*/
      ],
    );
  }

  /// code for rounded button of  pop-up screen .....
  Widget _roundedRectangularBox({required String text, required Color textColor, required Color borderColor,}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        height: 32, // Adjust height as needed
        width: 84, // Match parent width
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // Rounded corners
            border: Border.all(
                color: borderColor, width: 1), // Dynamic border color
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                text,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: textColor,
                    fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// dropdown design of project filters.....
  Widget _projectSelectCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: selectedProject,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(
                color: Colors.black.withOpacity(0.8),
              ),
              //labelText: "Project",
              label: RichText(
                text: TextSpan(
                    text: 'Project',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                    children: [
                      TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red, fontSize: 17))
                    ]),
              ),
              hintText: "Select Project",
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
            items: projectItems.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              selectedProject = newValue!;
            },
          ),
        ],
      ),
    );
  }

  /// dropdown design of Task filters.....
  Widget _selectTaskCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: selectedProject,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(
                color: Colors.black.withOpacity(0.8),
              ),
              //labelText: "Project",
              label: RichText(
                text: TextSpan(
                    text: 'Project',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                    children: [
                      TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red, fontSize: 17))
                    ]),
              ),
              hintText: "Select Project",
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
            items: projectItems.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              selectedProject = newValue!;
            },
          ),
        ],
      ),
    );
  }

  /// build a row for details
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

  /// --- Call for show total hrs and pending Rejected data show in card.
  Future<void> fetchLogs() async {
    setState(() {
      isLoading = true;
    });

    final response = await getAllTimeLog(context);

    if(response is AllTimeLogResponse){
      setState(() {
        allTimeLogs = response.data?.lstTimeLogs ?? [];
        timeLogs = List.from(allTimeLogs); // initially show all
        pendingCount = response.data?.pendingCount ?? 0;
        rejectedCount = response.data?.rejectedCount ?? 0;
        totalWorkingHrs = response.data?.totalMonthlyHours ?? 0;

        isLoading = false;
      });
    }else{
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


  /// --- show all the filled time history in the list.
  Widget _filledTimeLogAndShowInList() {
    return SizedBox(
      height: 500,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: isLoading
            ? Center(child: KLoader())
            : timeLogs.isEmpty
            ? Center(child: Text("No Data Found!"))
            : ListView.builder(
             padding: EdgeInsets.zero,
             itemCount:
             getFilteredProjects().length,
              itemBuilder: (BuildContext context,
              int index) {
            final filteredProjects =
            getFilteredProjects();
            final project =
            filteredProjects[index];

            Color statusColor = project
                .status ==
                "Pending"
                ? KColors.orangeColor
                : project.status == "Approved"
                ? KColors.greenColor
                : KColors.appPrimaryRed;

             ///--- show time log UI
             return GestureDetector(
              onTap: () {

                showDialog(context: context, builder: (context) =>

                      DetailDialog(
                        onUpdate: fetchLogs,
                        timeLogId: project.timelogId,
                        projectId: project.projectId,
                        project: project.projectName,
                        task: project.taskName,
                        date: KDateAndTime().getDay(project.formattedDate ?? ""),
                        des: project.description,
                        monthYear: KDateAndTime().getMonthYear(project.formattedDate ?? ""),
                        hrs: project.hours.toString(),
                        min: project.minutes.toString(),
                        status: project.status ?? "",
                      ),);

              },

              child: SizedBox(
                height: 120,
                width: 374,
                child: Card(
                  color: Colors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                        10),
                  ),
                  elevation: 0,
                  shadowColor:
                  KColors.cardShadowColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius
                          .circular(10),
                      border: Border(
                        left: BorderSide(
                          color: statusColor,
                          width: 2,
                        ),
                      ),
                    ),
                    padding:
                    EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    project.projectName ??
                                        "No Project",
                                    maxLines:
                                    1,
                                    style: KFonts
                                        .normalBold,
                                  ),
                                  SizedBox(
                                      height:
                                      5),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: DecoratedBox(
                                      decoration:
                                      BoxDecoration(
                                        color:
                                        statusColor,
                                        borderRadius:
                                        BorderRadius.circular(2),
                                      ),
                                      child:
                                      Padding(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal:
                                            10,
                                            vertical:
                                            1),
                                        child:
                                        Text(
                                          project.taskName ??
                                              "No Task",
                                          maxLines:
                                          1,
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
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    height:
                                    35,
                                    width: 1,
                                    color: Color(
                                        0xFFEDEDED),
                                  ),
                                  SizedBox(
                                      width:
                                      10),
                                  Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                    children: [
                                      Text(
                                        KDateAndTime().getDay(project.formattedDate ?? ""),
                                        style:
                                        TextStyle(
                                          color:
                                          statusColor,
                                          fontFamily:
                                          'Poppins',
                                          fontWeight:
                                          FontWeight.w600,
                                          fontSize:
                                          16,
                                        ),
                                      ),
                                      Text(
                                        KDateAndTime().getMonthYear(project.formattedDate ?? ""),
                                        style:
                                        KFonts.normalBoldWithGray,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    project.description ??
                                        "No Description",
                                    style: KFonts
                                        .thin,
                                    maxLines:
                                    2,
                                  ),
                                  SizedBox(
                                      height:
                                      5),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    height:
                                    35,
                                    width: 1,
                                    color: Color(
                                        0xFFEDEDED),
                                  ),
                                  SizedBox(
                                      width:
                                      20),
                                  Column(
                                    children: [
                                      Text(
                                        project
                                            .hours
                                            .toString(),
                                        style:
                                        TextStyle(
                                          color:
                                          statusColor,
                                          fontFamily:
                                          'Poppins',
                                          fontWeight:
                                          FontWeight.w600,
                                          fontSize:
                                          16,
                                        ),
                                      ),
                                      Text(
                                        'Hours',
                                        style:
                                        KFonts.normalBoldWithGray,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
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
      ),
    );
  }

}


/// ---- Open dialog for show details
class DetailDialog extends StatelessWidget {
  final VoidCallback onUpdate;
  final String? timeLogId;
  final String? project;
  final String? projectId;
  final String? task;
  final String? des;
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
                          style: KFonts.normalBold,
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
                          visible: status=='Pending',
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
                          // Wait for the next frame to push new screen
                          await Future.delayed(Duration.zero);

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
                        }

                    ),
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
                    child: Text(
                      des ?? "",
                      style: KFonts.thin,
                    ),
                  ),
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
                              Text(hrs ?? "",
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
