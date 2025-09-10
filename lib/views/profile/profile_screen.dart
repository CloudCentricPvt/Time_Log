import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:time_log/models/profile_details_res.dart';
import 'package:time_log/utils/constants/k_colors.dart';
import 'package:time_log/utils/constants/k_date_and_time.dart';
import 'package:time_log/utils/constants/k_loader.dart';
import '../../utils/constants/check_internet.dart';
import '../../utils/constants/k_drawer_menu.dart';
import '../../utils/constants/k_fonts.dart';
import '../../utils/constants/k_nav_header.dart';
import '../../utils/constants/k_storage_key.dart';
import '../../utils/popups/k_material_dialog.dart';
import '../../utils/reusable_widgit/k_info_card.dart';

class ProfileScreen extends StatefulWidget {
  final ValueNotifier<bool>? isBottomNavVisible;

  const ProfileScreen({super.key, this.isBottomNavVisible});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final CheckInternetAvailable _checkInternet = CheckInternetAvailable();
  final storage = GetStorage();
  LstemployeeDetail? employeeData;
  bool _isLoading = true;
  int _selectedIndex = 0;

  void refreshProfileData() {
    print("Refreshing profile data...");
    _checkInternetConnection(); // your actual data reload logic
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void _checkInternetConnection() async {
    setState(() {
      _isLoading = true;
    });

    bool connected = await _checkInternet.isConnected();
    if (!connected) {
      setState(() {
        _isLoading = false;
      });

      KMaterialDialogs.noInternetFound(
        context,
        IconsButton(
          onPressed: () {
            Navigator.pop(context);
          },
          text: 'Okay',
          color: KColors.appPrimaryRed,
          textStyle: const TextStyle(color: KColors.appColorWhite),
          iconColor: KColors.appColorWhite,
        ),
        "No Internet Connection",
        "Please check your internet connection and try again.",
      );
      return;
    }

    fetchProfileDetailsData();
  }

  void fetchData() {
    _checkInternetConnection();
  }

  // refresh data when swap down screen
  Future<void> _refreshData() async {
    // Your logic to refresh data
    await Future.delayed(
        Duration(seconds: 1)); // Simulate API call or database load
    setState(() {
      _isLoading = true;
      fetchProfileDetailsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KCustomDrawer.customDrawer(
          context: context,
          title: "Profile",
          titleColor: KColors.appBlackColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          showBellIcon: true,
          showProfileIcon: false,
          topPaddingFactor: 0.04),
      drawer: CustomDrawerMenu(
        context: context,
        isBottomNavVisible: widget.isBottomNavVisible,
        selectedIndex: _selectedIndex,
        onMenuTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      onDrawerChanged: (isOpened) {
        widget.isBottomNavVisible?.value = !isOpened;
      },
      body: _isLoading
          ? KLoader()
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(), // <- Required!
                child: Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.height * 0.03,
                      right: MediaQuery.of(context).size.height * 0.03),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.001,
                      ),
                      const Center(
                          child: CircleAvatar(
                        radius: 38,
                        backgroundColor: KColors.grayLight,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: KColors.appColorWhite,
                        ),
                      )),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Text(employeeData?.employeeName ?? '',
                          style: KFonts.heading),
                      Text(
                        '${employeeData?.employeeDesignation ?? ''} | ${employeeData?.employeeCode ?? ''}',
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: KColors.appPrimary),
                      ),

                      ///--- Personal details
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Personal Details",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: KColors.appBlackColor,
                                fontFamily: 'Poppins'),
                          ),
                          Spacer(),
                          InkWell(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              height: 32,
                              decoration: BoxDecoration(
                                  color: KColors.appColorWhite,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: SvgPicture.asset(
                                        'assets/icons/edit_profile.svg'),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  const Text("Edit",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          color: KColors.appBlackColor))
                                ],
                              ),
                            ),
                            onTap: () async {
                              var result = await Navigator.pushNamed(
                                  context, '/edit_profile_screen',
                                  arguments: {
                                    'fullName': employeeData?.employeeName,
                                    'gender': employeeData?.employeeGender,
                                    'phone': employeeData?.employeePhone,
                                    'email': employeeData?.employeeEmail,
                                    'dob': employeeData?.employeeDob,
                                    'anniversaryDate':
                                        employeeData?.employeeAnniversaryDate,
                                    'address': employeeData?.employeeAddress,
                                  });
                              if (result == true) {
                                fetchProfileDetailsData(); // refresh
                              }
                            },
                          ),
                          Visibility(
                            visible: false,
                            child: InkWell(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                height: 32,
                                decoration: BoxDecoration(
                                    color: KColors.appColorWhite,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: SvgPicture.asset(
                                          'assets/icons/change_pass.svg'),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    const Text("Change Pass",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: KColors.textColorGray))
                                  ],
                                ),
                              ),
                              onTap: () {
                                KMaterialDialogs.noInternetFound(
                                  context,
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "OK",
                                      style:
                                          TextStyle(color: KColors.appPrimary),
                                    ),
                                  ),
                                  "Alert!",
                                  "Please contact your reporting manager.",
                                );
                                return;
                              },
                            ),
                          ),
                        ],
                      ),

                      ///--- Design Profile Details
                      const SizedBox(
                        height: 12,
                      ),
                      KInfoCard(
                        children: [
                          buildRowForProfile("Name:",
                              employeeData?.employeeName ?? '', context,
                              color: KColors.appBlackColor,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins'),
                          buildRowForProfile(
                            "Gender:",
                            employeeData?.employeeGender ?? '',
                            context,
                            color: KColors.appBlackColor,
                            fontFamily: 'Poppins',
                          ),
                          buildRowForProfile("Phone:",
                              employeeData?.employeePhone ?? '', context,
                              color: KColors.appPrimary, fontFamily: 'Poppins'),
                          buildRowForProfile("Email:",
                              employeeData?.employeeEmail ?? '', context,
                              color: KColors.appPrimary, fontFamily: 'Poppins'),
                          buildRowForProfile(
                              "DOB:",
                              KDateAndTime().useFormatDateInMyApp(
                                  employeeData?.employeeDob ?? ''),
                              context,
                              color: KColors.appBlackColor,
                              fontFamily: 'Poppins'),
                          buildRowForProfile(
                              "Anniversary date:",
                              KDateAndTime().useFormatDateInMyApp(
                                  employeeData?.employeeAnniversaryDate ?? ''),
                              context,
                              color: KColors.appBlackColor,
                              fontFamily: 'Poppins'),
                          buildRowForProfile("Address:",
                              employeeData?.employeeAddress ?? '', context,
                              color: KColors.appBlackColor,
                              fontFamily: 'Poppins'),
                        ],
                      ),

                      ///--- Company Details
                      const SizedBox(
                        height: 10,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Company Details",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: KColors.appBlackColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      KInfoCard(
                        children: [
                          buildRowForCompany("Department:",
                              employeeData?.employeeDepartment ?? '', context,
                              color: KColors.appBlackColor,
                              fontFamily: 'Poppins'),
                          buildRowForCompany("Employee Id:",
                              employeeData?.employeeCode ?? '', context,
                              color: KColors.appPrimary, fontFamily: 'Poppins'),
                          buildRowForCompany("Designation:",
                              employeeData?.employeeDesignation ?? '', context,
                              color: KColors.appBlackColor,
                              fontFamily: 'Poppins'),
                          buildRowForCompany(
                              "Joining date:",
                              KDateAndTime().useFormatDateInMyApp(
                                  employeeData?.employeeJoiningDate ?? ''),
                              context,
                              color: KColors.appBlackColor,
                              fontFamily: 'Poppins'),
                        ],
                      ),

                      ///--- Manager Details
                      const SizedBox(
                        height: 10,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        // Aligns text to the start (left)
                        child: Text(
                          "Manager Details",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: KColors.appBlackColor,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      KInfoCard(
                        children: [
                          buildRowForManager("Manager Name:",
                              employeeData?.employeeManagerName ?? '', context,
                              color: KColors.appBlackColor,
                              fontFamily: 'Poppins'),
                          buildRowForManager("Manager Email:",
                              employeeData?.employeeManagerEmail ?? '', context,
                              color: KColors.appPrimary),
                          buildRowForManager("Manager Phone:",
                              employeeData?.employeeManagerPhone ?? '', context,
                              color: KColors.appPrimary),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildRowForProfile(
    String label,
    String value,
    BuildContext context, {
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    double labelWidth = MediaQuery.of(context).size.width * 0.3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: KColors.appBlackColor,
                fontFamily: 'Poppins',
                letterSpacing: 0.12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontFamily: fontFamily ?? 'Poppins',
                fontWeight: fontWeight ?? FontWeight.w500,
                color: color ?? KColors.appBlackColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRowForCompany(String label, String value, BuildContext context,
      {Color? color, required String fontFamily}) {
    double labelWidth =
        MediaQuery.of(context).size.width * 0.3; // 30% of screen width

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth, // Dynamic width based on screen size
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KColors.appBlackColor,
                fontFamily: 'Poppins',
                letterSpacing: 0.12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: color ?? KColors.appBlackColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRowForManager(String label, String value, BuildContext context,
      {Color? color, String? fontFamily}) {
    double labelWidth =
        MediaQuery.of(context).size.width * 0.3; // 30% of screen width

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth, // Dynamic width based on screen size
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: KColors.appBlackColor,
                  fontFamily: 'Poppins'),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: color ?? KColors.appBlackColor,
                  letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// --  create method for getting the Employee and manager details.
  void fetchProfileDetailsData() async {
    final response = await getProfileDetails(context);

    if (response is ProfileDetailsResponse) {
      final dataList = response.data.lstemployeeDetails;

      if (dataList.isEmpty) {
        print("No employee details found");
        return;
      }

      employeeData = dataList[0];
      storage.write(KStorageKey.employeeName,
          (dataList.isNotEmpty ? employeeData!.employeeName : '') ?? '');
      storage.write(KStorageKey.employeeGender,
          (dataList.isNotEmpty ? employeeData!.employeeGender : '') ?? '');
      storage.write(KStorageKey.employeeMobile,
          (dataList.isNotEmpty ? employeeData!.employeePhone : '') ?? '');
      storage.write(KStorageKey.employeeEmail,
          (dataList.isNotEmpty ? employeeData!.employeeEmail : '') ?? '');
      storage.write(KStorageKey.employeeDOB,
          (dataList.isNotEmpty ? employeeData!.employeeDob : '') ?? '');
      storage.write(
          KStorageKey.employeeAnniversary,
          (dataList.isNotEmpty ? employeeData!.employeeAnniversaryDate : '') ??
              '');
      storage.write(KStorageKey.employeeAddress,
          (dataList.isNotEmpty ? employeeData!.employeeAddress : '') ?? '');

      setState(() {
        _isLoading = false;
      });
    } else {
      print("Unexpected response type or failed to parse response");
    }
  }
}
