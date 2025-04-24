import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';

import 'k_colors.dart';
import 'k_logout_dialog.dart'; // Replace with your actual constants file

class CustomDrawerMenu extends StatelessWidget {
  final BuildContext context;
  CustomDrawerMenu({super.key, required this.context});
  final storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SizedBox(
            width: MediaQuery.of(context).size.width *0.95,  // Set the width to 95%
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 14, right: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures spacing
                    children: [
                      const CircleAvatar(
                        radius: 30, // Adjust size
                        backgroundImage: AssetImage('assets/images/profile_img.jpeg'), // Directly load the image
                      ),
                      const SizedBox(width: 10), // Space between image and text
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cloud Centric",
                            style: TextStyle(color: KColors.appBlackColor, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "cccinfotech@gmail.com",
                            style: TextStyle(color: KColors.appPrimary, fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: SvgPicture.asset(
                              'assets/icons/menu_cross.svg'),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Closes the drawer
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures spacing
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("120 hrs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("Total working hours in month", style: TextStyle(color: KColors.textColorGray, fontSize: 12))
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("04 hrs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("Leave taken in month", style: TextStyle(color: KColors.textColorGray, fontSize: 12))
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
                                      decoration: BoxDecoration(color: KColors.appColorWhite, borderRadius: BorderRadius.circular(4)),
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
                                      Navigator.pushNamed(context, '/profile_screen');
                                    },
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(color: KColors.appColorWhite, borderRadius: BorderRadius.circular(4)),
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

                  // Blue line
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 12,
                    width: double.infinity,
                    child: Card(color: KColors.appPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                  ),
                  const SizedBox(height: 10),

                  // Design Menu
                  Container(
                    decoration: BoxDecoration(color: KColors.appColorWhite, borderRadius: BorderRadius.circular(6)),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 18),
                      child: Column(
                        children: [
                          _buildMenuItem(context, 'assets/icons/dash_board.svg', 'Dashboard', '/dashboard_screen'),
                          _buildMenuItem(context, 'assets/icons/time_logs.svg', 'Time Logs', '/time_logs_screen'),
                          _buildMenuItem(context, 'assets/icons/leaves_etails_apply.svg', 'Leaves Details & Apply', '/leaves_details_screen'),
                          _buildMenuItem(context, 'assets/icons/upcoming_events.svg', 'Upcoming Events', '/upcoming_events_screen'),
                          _buildMenuItem(context, 'assets/icons/help_support.svg', 'Help & Support', '/help_support_screen'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Company Policies
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Company Policies"),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(color: KColors.appColorWhite, borderRadius: BorderRadius.circular(6)),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 18),
                          child: Column(
                            children: [
                              _buildPolicyItem(context, 'assets/icons/privacy_policy.svg', 'Leave Policy', '/leave_policy_screen'),
                              _buildPolicyItem(context, 'assets/icons/privacy_policy.svg', 'Privacy Policies', '/privacy_policy_screen'),
                              _buildPolicyItem(context, 'assets/icons/terms_conditions.svg', 'Terms & Conditions', '/terms_and_condition_screen'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // App Version & Logout
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("App Version - v1.0.0"),
                            GestureDetector(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SvgPicture.asset('assets/icons/logout.svg'),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text("Logout", style: TextStyle(color: KColors.appPrimaryRed, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              onTap: () {
                                LogoutDialog.showAlertDialog(context, onConfirm: () {
                                  storage.remove('Is_Active');
                                  Navigator.pushReplacementNamed(context, '/login_screen');
                                });
                              },
                            ),
                          ],
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

  // Helper function to create policy items
  Widget _buildPolicyItem(BuildContext context, String icon, String title, String route) {
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
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

}
