import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/utils/constants/k_storage_key.dart';

import 'k_colors.dart';
import 'k_logout_dialog.dart';

class CustomDrawerMenu extends StatefulWidget {
  final BuildContext context;
  final ValueNotifier<bool>? isBottomNavVisible;
  final int selectedIndex;
  final Function(int) onMenuTap;

  const CustomDrawerMenu({
    super.key,
    required this.context,
    this.isBottomNavVisible,
    required this.selectedIndex,
    required this.onMenuTap,
  });

  @override
  State<CustomDrawerMenu> createState() => _CustomDrawerMenuState();
}

class _CustomDrawerMenuState extends State<CustomDrawerMenu> {
  final storage = GetStorage();

  // String _selectedMenu = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.97,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.width * 0.17,
        ),
        child: Drawer(
          backgroundColor: KColors.lightGreyBGScreen,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.05,
                          left: MediaQuery.of(context).size.width * 0.05,
                          right: MediaQuery.of(context).size.width * 0.05,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: KColors.grayLight,
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: KColors.appColorWhite,
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.02),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      storage.read(KStorageKey.userName ?? ''),
                                      style: TextStyle(
                                          color: KColors.appBlackColor,
                                          fontSize: 18,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1),
                                    ),
                                    Text(
                                      storage.read(
                                              KStorageKey.designation ?? '') +
                                          " | " +
                                          storage.read(
                                              KStorageKey.employeeCode ?? ''),
                                      style: TextStyle(
                                        color: KColors.appPrimary,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                //  const Spacer(),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.33,
                                ),
                                GestureDetector(
                                  child: SizedBox(
                                    width: 35,
                                    height: 35,
                                    child: SvgPicture.asset(
                                        'assets/icons/menu_cross.svg'),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          storage.read(KStorageKey
                                                  .tWorkingHrsInTHisMonth) ??
                                              '',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                      Text("Total working\n hours this month",
                                          style: TextStyle(
                                              color: KColors.appBlackColor,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.01,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          storage.read(KStorageKey
                                                  .leaveTakenInThisMonth) ??
                                              '',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                      Text("Leave taken in\n this  month",
                                          style: TextStyle(
                                              color: KColors.appBlackColor,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                                InkWell(
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                          color: KColors.appColorWhite,
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: SvgPicture.asset(
                                              'assets/icons/open_profile.svg'),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Future.delayed(
                                          const Duration(milliseconds: 100),
                                          () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/home_screen',
                                          arguments: 3,
                                        );
                                      });
                                    }),
                                InkWell(
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        color: KColors.appColorWhite,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: SvgPicture.asset(
                                            'assets/icons/edit_profile.svg'),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                        context, '/edit_profile_screen');
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            SizedBox(
                              height: 12,
                              width: double.infinity,
                              child: Card(
                                color: KColors.appPrimary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: KColors.appColorWhite,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 14),
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Column(
                                    children: [
                                      _buildMenuItem(
                                          context,
                                          'assets/icons/dash_board.svg',
                                          'Dashboard',
                                          0),
                                      _buildMenuItem(
                                          context,
                                          'assets/icons/time_log_icon1.svg',
                                          'Time Logs',
                                          1),
                                      _buildAnotherMenu(
                                          'assets/icons/attendance_icon.svg',
                                          'Attendance',
                                          '/attendance_screen'),
                                      _buildMenuItem(
                                          context,
                                          'assets/icons/leaves_etails_apply.svg',
                                          'Leaves Details & Apply',
                                          2),
                                      _buildAnotherMenu(
                                          'assets/icons/attendance_icon.svg',
                                          'Payroll',
                                          '/payroll_screen'),
                                      _buildAnotherMenu(
                                          'assets/icons/upcoming_events.svg',
                                          'Upcoming Events',
                                          '/upcoming_events_screen'),
                                      _buildAnotherMenu(
                                          'assets/icons/help_support.svg',
                                          'Help & Support',
                                          '/help_and_support_screen'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Company Policies",
                                style: TextStyle(
                                  color: KColors.appBlackColor,
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: KColors.appColorWhite,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.height * 0.01,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.03,
                                ),
                                child: Column(
                                  children: [
                                    _buildPolicyItem(
                                        'assets/icons/privacy_policy.svg',
                                        'Leave Policy',
                                        '/leave_policy_screen'),
                                    _buildPolicyItem(
                                        'assets/icons/privacy_policy.svg',
                                        'Privacy Policy',
                                        '/privacy_policy_screen'),
                                    _buildPolicyItem(
                                        'assets/icons/terms_conditions.svg',
                                        'Terms & Conditions',
                                        '/terms_and_condition_screen'),
                                    _buildPolicyItem(
                                        'assets/icons/terms_conditions.svg',
                                        'Posh Policy',
                                        '/posh_policy_screen'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.017,
                        left: MediaQuery.of(context).size.height * 0.02,
                        right: MediaQuery.of(context).size.height * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "App Version - v1.0.0",
                          style: TextStyle(
                            color: KColors.appBlackColor,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    SvgPicture.asset('assets/icons/logout.svg'),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "Logout",
                                style: TextStyle(
                                  color: KColors.appPrimaryRed,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            LogoutDialog.showAlertDialog(context,
                                onConfirm: () {
                              storage.remove('Is_Active');
                              storage.remove(KStorageKey.attendeeId);
                              Navigator.pushReplacementNamed(
                                  context, '/login_screen');
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String icon,
    String title,
    int index,
  ) {
    final bool isSelected = widget.selectedIndex == index;
    return InkWell(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: SvgPicture.asset(
                  icon,
                  color:
                      isSelected ? KColors.appPrimary : KColors.appBlackColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color:
                      isSelected ? KColors.appPrimary : KColors.appBlackColor,
                ),
              ),
              Spacer(),
              SizedBox(
                width: 10,
                height: 24,
                child: SvgPicture.asset(
                  'assets/icons/right_arrow.svg',
                  color:
                      isSelected ? KColors.appPrimary : KColors.appBlackColor,
                ),
              ),
            ],
          ),
          const Divider(
            color: KColors.colorGray,
            thickness: .6,
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        widget.onMenuTap(index);
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.pushReplacementNamed(
            context,
            '/home_screen',
            arguments: index,
          );
        });

      },
    );
  }

  Widget _buildPolicyItem(String icon, String title, String route) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 20, height: 20, child: SvgPicture.asset(icon)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 15)),
              Spacer(),
              SizedBox(
                width: 10,
                height: 24,
                child: SvgPicture.asset('assets/icons/right_arrow.svg'),
              ),
            ],
          ),
          const Divider(
            color: KColors.colorGray,
            thickness: .6,
          ),
        ],
      ),
    );
  }

  Widget _buildAnotherMenu(String icon, String title, String route) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 20, height: 20, child: SvgPicture.asset(icon)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 15)),
              const Spacer(),
              SizedBox(
                width: 10,
                height: 24,
                child: SvgPicture.asset('assets/icons/right_arrow.svg'),
              ),
            ],
          ),
          const Divider(
            color: KColors.colorGray,
            thickness: .6,
          ),
        ],
      ),
    );
  }
}
