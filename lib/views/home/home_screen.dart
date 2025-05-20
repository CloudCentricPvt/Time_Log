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

      body: _widgetOptions[_selectedIndex], // Display the selected screen

     ///--- Bottom Nav menu
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
