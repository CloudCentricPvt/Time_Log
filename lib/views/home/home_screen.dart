import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/utils/constants/k_colors.dart';
import 'package:time_log/utils/constants/k_nav_header.dart';
import 'package:time_log/views/dashBoard/check_in_check_out.dart';
import 'package:time_log/views/profile/profile_screen.dart';
import 'package:time_log/views/timelogs/time_logs_screen.dart';

import '../../utils/constants/k_asstes.dart';
import '../../utils/constants/k_logout_dialog.dart';
import '../leaves/leave_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track the index of the selected item
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static final List<Widget> _widgetOptions = <Widget>[
    const CheckInCheckOut(),
    const TimeLogsScreen(),
    const LeaveScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      /*appBar: KCustomDrawer.customDrawer(
        context: context,
        title: "Hello Sabir",
        subtitle: "Welcome to TimeSync",
        showBellIcon: true,  // Show Bell Icon
        showProfileIcon: true,  // Hide Profile Icon
      ),*/


      body: _widgetOptions[_selectedIndex], // Display the selected screen

     ///--- Drawer menu
      /*drawer: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          child: Drawer(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30),bottomRight:Radius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.only(top:20,left: 14,right: 14),
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
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures spacing
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("120 hrs",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                              Text("Total working hours in month",style: TextStyle(color: KColors.textColorGray,fontSize: 12))
                            ],),
                        ),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("04 hrs",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                              Text("Leave taken in month",style: TextStyle(color: KColors.textColorGray,fontSize: 12))
                            ],),
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
                                      decoration: BoxDecoration(color: KColors.appColorWhite,borderRadius: BorderRadius.circular(4)),
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
                                    onTap: (){
                                      Navigator.pushNamed(context, '/profile_screen');
                                    },
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(color: KColors.appColorWhite,borderRadius: BorderRadius.circular(4)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: SvgPicture.asset(
                                              'assets/icons/edit_profile.svg'),
                                        ),
                                      ),
                                    ),
                                    onTap: (){
                                      Navigator.pushNamed(context, '/edit_profile_screen');
                                    },
                                  ),
                                ],
                              ),
                            ],),
                        ),
                      ),
                    ],
                  ),

                  ///--- Blue Line
                  const SizedBox(height: 10,),
                  SizedBox(height:12,width:double.infinity,child: Card(color: KColors.appPrimary,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),)),
                  const SizedBox(height: 10,),

                  ///-- Design Menu
                  Container(
                    decoration: BoxDecoration(color: KColors.appColorWhite,borderRadius: BorderRadius.circular(6)),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10,bottom: 10,left: 12,right: 18),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: SvgPicture.asset(
                                    'assets/icons/dash_board.svg'),
                              ),
                              const SizedBox(width: 10,),
                              const Text("Dashbord",style: TextStyle(fontSize: 15),),
                              const Spacer(),
                              SizedBox(
                                width: 10,
                                height: 24,
                                child: SvgPicture.asset(
                                    'assets/icons/right_arrow.svg'),
                              ),

                            ],
                          ),
                          const Divider(
                            color: KColors.colorGray, // Line color
                            thickness: .6, // Line thickness
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: SvgPicture.asset(
                                    'assets/icons/time_logs.svg'),
                              ),
                              const SizedBox(width: 10,),
                              const Text("Time Logs",style: TextStyle(fontSize: 15),),
                              const Spacer(),
                              SizedBox(
                                width: 10,
                                height: 24,
                                child: SvgPicture.asset(
                                    'assets/icons/right_arrow.svg'),
                              ),
                            ],
                          ),
                          const Divider(
                            color: KColors.colorGray, // Line color
                            thickness: .6, // Line thickness
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: SvgPicture.asset(
                                    'assets/icons/leaves_etails_apply.svg'),
                              ),
                              const SizedBox(width: 10,),
                              const Text("Leaves Details & Apply",style: TextStyle(fontSize: 15),),
                              const Spacer(),
                              SizedBox(
                                width: 10,
                                height: 24,
                                child: SvgPicture.asset(
                                    'assets/icons/right_arrow.svg'),
                              ),
                            ],
                          ),
                          const Divider(
                            color: KColors.colorGray, // Line color
                            thickness: .6, // Line thickness
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: SvgPicture.asset(
                                    'assets/icons/upcoming_events.svg'),
                              ),
                              const SizedBox(width: 10,),
                              const Text("Upcoming Events",style: TextStyle(fontSize: 15),),
                              const Spacer(),
                              SizedBox(
                                width: 10,
                                height: 24,
                                child: SvgPicture.asset(
                                    'assets/icons/right_arrow.svg'),
                              ),
                            ],
                          ),
                          const Divider(
                            color: KColors.colorGray, // Line color
                            thickness: .6, // Line thickness
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: SvgPicture.asset(
                                    'assets/icons/help_support.svg'),
                              ),
                              const SizedBox(width: 10,),
                              const Text("Help & Support",style: TextStyle(fontSize: 15),),
                              const Spacer(),
                              SizedBox(
                                width: 10,
                                height: 24,
                                child: SvgPicture.asset(
                                    'assets/icons/right_arrow.svg'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),

                  ///--- Company Policies Menu
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Company Policies"),
                      const SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(color: KColors.appColorWhite,borderRadius: BorderRadius.circular(6)),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10,bottom: 10,left: 12,right: 18),
                          child: Column(
                            children: [
                              InkWell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: SvgPicture.asset(
                                          'assets/icons/leavePolicy.svg'),
                                    ),
                                    const SizedBox(width: 10,),
                                    const Text("Leave Policy",style: TextStyle(fontSize: 15),),
                                    const Spacer(),
                                    SizedBox(
                                      width: 10,
                                      height: 24,
                                      child: SvgPicture.asset(
                                          'assets/icons/right_arrow.svg'),
                                    ),

                                  ],
                                ),
                                onTap: (){Navigator.pushNamed(context, '/leave_policy_screen');},
                              ),
                              const Divider(
                                color: KColors.colorGray, // Line color
                                thickness: .6, // Line thickness
                              ),
                              InkWell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: SvgPicture.asset(
                                          'assets/icons/privacy_policy.svg'),
                                    ),
                                    const SizedBox(width: 10,),
                                    const Text("Privacy Policies",style: TextStyle(fontSize: 15),),
                                    const Spacer(),
                                    SizedBox(
                                      width: 10,
                                      height: 24,
                                      child: SvgPicture.asset(
                                          'assets/icons/right_arrow.svg'),
                                    ),
                                  ],
                                ),
                                onTap: (){Navigator.pushNamed(context, '/privacy_policy_screen');},
                              ),
                              const Divider(
                                color: KColors.colorGray, // Line color
                                thickness: .6, // Line thickness
                              ),
                              InkWell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: SvgPicture.asset(
                                          'assets/icons/terms_conditions.svg'),
                                    ),
                                    const SizedBox(width: 10,),
                                    const Text("Terms & Conditions",style: TextStyle(fontSize: 15),),
                                    const Spacer(),
                                    SizedBox(
                                      width: 10,
                                      height: 24,
                                      child: SvgPicture.asset(
                                          'assets/icons/right_arrow.svg'),
                                    ),
                                  ],
                                ),
                                onTap: (){Navigator.pushNamed(context, '/terms_and_condition_screen');},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],),


                  ///--- App version and Log out design
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
                                    child: SvgPicture.asset(
                                        'assets/icons/logout.svg'),
                                  ),
                                  const SizedBox(width: 5,),

                                  const Text("Logout",style: TextStyle(color: KColors.appPrimaryRed, fontWeight: FontWeight.bold),)

                                ],
                              ),
                              onTap: (){
                                LogoutDialog.showAlertDialog(context, onConfirm: () {
                                  Navigator.pushNamed(context, '/');
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
      ),*/

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: _buildNavItem(
              SvgPicture.asset(
                KAssets.homeIcon, // Your SVG asset
                width: 24,
                height: 24,
                color: _selectedIndex == 0 ? KColors.appPrimary : KColors.textColor, // Dynamic color
              ),
              "Dashboard",
              0,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem( SvgPicture.asset(
              KAssets.timeLoge, // Your SVG asset
              width: 24,
              height: 24,
              color: _selectedIndex == 1 ? KColors.orangeColor: KColors.textColor, // Dynamic color
            ), "Time Log", 1),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem( SvgPicture.asset(
              KAssets.leaveIcon, // Your SVG asset
              width: 24,
              height: 24,
              color: _selectedIndex == 2 ? KColors.greenColor :KColors.textColor,
            ), "Leaves", 2),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem( SvgPicture.asset(
              KAssets.profileIcon, // Your SVG asset
              width: 24,
              height: 24,
              color: _selectedIndex == 3 ? KColors.appPrimaryYellow : KColors.textColor,
            ), "Profile", 3),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        //selectedItemColor: _getSelectedColor(), // Dynamic color change
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Fixes shifting effect
        backgroundColor: Colors.white,
      ),
    );
  }

  ///--- Corrected method for building navigation items
  Widget _buildNavItem(Widget icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            child: Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? KColors.appBlackColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon, // Use icon directly, no need to wrap it inside `Icon()`

                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        color: KColors.appColorWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
