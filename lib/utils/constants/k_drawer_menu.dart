import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:time_log/utils/constants/k_storage_key.dart';

import 'k_colors.dart';
import 'k_logout_dialog.dart';

class CustomDrawerMenu extends StatefulWidget {
  final BuildContext context;
  const CustomDrawerMenu({super.key, required this.context});

  @override
  State<CustomDrawerMenu> createState() => _CustomDrawerMenuState();
}

class _CustomDrawerMenuState extends State<CustomDrawerMenu> {
  final storage = GetStorage();
  String _selectedMenu = 'Dashboard'; // default selected menu

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 14, right: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /*const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/profile_img.jpeg'),
                      ),*/
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: KColors.grayLight,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: KColors.colorGray,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            storage.read(KStorageKey.userName ?? ''),
                            style: TextStyle(
                                color: KColors.appBlackColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1
                            ),
                          ),
                           Text(
                              storage.read(KStorageKey.designation ?? '')+" | "+storage.read(KStorageKey.employeeCode ?? ''),
                            style: TextStyle(color: KColors.appPrimary, fontSize: 14,),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: SvgPicture.asset('assets/icons/menu_cross.svg'),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(storage.read(KStorageKey.tWorkingHrsInTHisMonth)?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("Total working hours in month", style: TextStyle(color: KColors.textColorGray, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                       Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(storage.read(KStorageKey.leaveTakenInThisMonth)?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("Leave taken in month", style: TextStyle(color: KColors.textColorGray, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Spacer(),
                                  InkWell(
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                          color: KColors.appColorWhite,
                                          borderRadius: BorderRadius.circular(4)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: SvgPicture.asset('assets/icons/open_profile.svg'),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, '/profile_screen');
                                    },
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                          color: KColors.appColorWhite,
                                          borderRadius: BorderRadius.circular(4)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: SvgPicture.asset('assets/icons/edit_profile.svg'),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, '/edit_profile_screen');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 12,
                    width: double.infinity,
                    child: Card(
                      color: KColors.appPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: KColors.appColorWhite,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: Column(
                        children: [
                          _buildMenuItem(context,'assets/icons/dash_board.svg', 'Dashboard', '/dashboard_screen',0),
                          _buildMenuItem(context,'assets/icons/time_log_icon1.svg', 'Time Logs', '/dashboard_screen',1),
                          _buildMenuItem(context,'assets/icons/leaves_etails_apply.svg', 'Leaves Details & Apply', '/dashboard_screen',2),
                          _buildAnotherMenu('assets/icons/upcoming_events.svg', 'Upcoming Events', '/upcoming_events_screen'),
                          _buildAnotherMenu('assets/icons/help_support.svg', 'Help & Support', '/help_and_support_screen')
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Company Policies"),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: KColors.appColorWhite,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: Column(
                        children: [
                          _buildPolicyItem('assets/icons/privacy_policy.svg', 'Leave Policy', '/leave_policy_screen'),
                          _buildPolicyItem('assets/icons/privacy_policy.svg', 'Privacy Policies', '/privacy_policy_screen'),
                          _buildPolicyItem('assets/icons/terms_conditions.svg', 'Terms & Conditions', '/terms_and_condition_screen'),
                          _buildPolicyItem('assets/icons/terms_conditions.svg', 'Posh Policy', '/posh_policy_screen'),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("App Version - v1.0.0"),
                        GestureDetector(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: SvgPicture.asset('assets/icons/logout.svg'),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "Logout",
                                style: TextStyle(color: KColors.appPrimaryRed, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          onTap: () {
                            LogoutDialog.showAlertDialog(context, onConfirm: () {
                              storage.remove('Is_Active');
                              storage.remove(KStorageKey.attendeeId);
                              Navigator.pushReplacementNamed(context, '/login_screen');
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to create menu items
/*
  Widget _buildMenuItem(BuildContext context, String icon, String title, String route) {
    return InkWell(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: SvgPicture.asset(icon),
              ),
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
      onTap: (){
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
*/
  Widget _buildMenuItem(BuildContext context, String icon, String title, String route, int selectedIndex) {
    final bool isDashboard = title == 'Dashboard';  // Check if this is Dashboard item
    return InkWell(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: SvgPicture.asset(icon,color: isDashboard ? Colors.blue : Colors.black,),
              ),
              const SizedBox(width: 10),
              Text(
                  title, style:  TextStyle(fontSize: 15,color: isDashboard ? Colors.blue : Colors.black),),
              const Spacer(),
              SizedBox(
                width: 10,
                height: 24,
                child: SvgPicture.asset('assets/icons/right_arrow.svg',color: isDashboard ? Colors.blue : Colors.black,),
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
        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.pushReplacementNamed(
            context,
            '/home_screen',  // <-- Use the correct route name here
            arguments: selectedIndex,  // Pass the tab index
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
