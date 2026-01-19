import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/utils/constants/k_colors.dart';
import 'package:time_log/views/dashBoard/check_in_check_out.dart';
import 'package:time_log/views/profile/profile_screen.dart';
import 'package:time_log/views/timelogs/time_logs_screen.dart';
import '../../utils/constants/k_asstes.dart';
import '../leaves/leave_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ValueNotifier<bool> isBottomNavVisible;
  int _selectedIndex = 0;
  bool _hasHandledArgs = false;
  bool _isDrawerOpen = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Create GlobalKeys for each screen's state to access refresh methods
  final GlobalKey<CheckInCheckOutState> _checkInKey =
      GlobalKey<CheckInCheckOutState>();
  final GlobalKey<TimeLogsScreenState> _timeLogKey =
      GlobalKey<TimeLogsScreenState>();
  final GlobalKey<LeaveScreenState> _leaveKey = GlobalKey<LeaveScreenState>();
  final GlobalKey<ProfileScreenState> _profileKey =
      GlobalKey<ProfileScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    isBottomNavVisible = ValueNotifier(true); // initially visible
    _pages = [
      CheckInCheckOut(key: _checkInKey, isBottomNavVisible: isBottomNavVisible),
      TimeLogsScreen(key: _timeLogKey, isBottomNavVisible: isBottomNavVisible),
      LeaveScreen(key: _leaveKey, isBottomNavVisible: isBottomNavVisible),
      ProfileScreen(key: _profileKey, isBottomNavVisible: isBottomNavVisible),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasHandledArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is int && args != _selectedIndex) {
        setState(() {
          _selectedIndex = args;
        });
      }
      _hasHandledArgs = true;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Trigger fetch API on screen load
    switch (index) {
      case 0:
        _checkInKey.currentState?.fetchData();
        break;
      case 1:
        _timeLogKey.currentState?.fetchData();
        break;
      case 2:
        _leaveKey.currentState?.fetchData();
        break;
      case 3:
        _profileKey.currentState?.fetchData();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle route arguments once
    if (!_hasHandledArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is int && args != _selectedIndex) {
        _selectedIndex = args;
        _hasHandledArgs = true;
      }
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        } else {
          bool exit = await _showExitDialog(context);
          if (exit) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        /*bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: _buildNavItem(
              SvgPicture.asset(
                KAssets.homeIcon,
                width: 24,
                height: 24,
                color: _selectedIndex == 0 ? KColors.appPrimary : KColors.textColor,
              ),
              "Dashboard",
              0,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(
              SvgPicture.asset(
                KAssets.timeLoge,
                width: 24,
                height: 24,
                color: _selectedIndex == 1 ? KColors.orangeColor : KColors.textColor,
              ),
              "Time Log",
              1,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(
              SvgPicture.asset(
                KAssets.leaveIcon,
                width: 24,
                height: 24,
                color: _selectedIndex == 2 ? KColors.greenColor : KColors.textColor,
              ),
              "Leaves",
              2,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(
              SvgPicture.asset(
                KAssets.profileIcon,
                width: 24,
                height: 24,
                color: _selectedIndex == 3 ? KColors.appPrimaryYellow : KColors.textColor,
              ),
              "Profile",
              3,
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),*/

        bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: isBottomNavVisible,
          builder: (context, isVisible, _) {
            return isVisible
                ? BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: _buildNavItem(
                          SvgPicture.asset(
                            KAssets.homeIcon,
                            width: 24,
                            height: 24,
                            color: _selectedIndex == 0
                                ? KColors.appPrimary
                                : KColors.textColor,
                          ),
                          "Dashboard",
                          0,
                        ),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: _buildNavItem(
                          SvgPicture.asset(
                            KAssets.timeLoge,
                            width: 24,
                            height: 24,
                            color: _selectedIndex == 1
                                ? KColors.orangeColor
                                : KColors.textColor,
                          ),
                          "Time Log",
                          1,
                        ),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: _buildNavItem(
                          SvgPicture.asset(
                            KAssets.leaveIcon,
                            width: 24,
                            height: 24,
                            color: _selectedIndex == 2
                                ? KColors.greenColor
                                : KColors.textColor,
                          ),
                          "Leaves",
                          2,
                        ),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: _buildNavItem(
                          SvgPicture.asset(
                            KAssets.profileIcon,
                            width: 24,
                            height: 24,
                            color: _selectedIndex == 3
                                ? KColors.appPrimaryYellow
                                : KColors.textColor,
                          ),
                          "Profile",
                          3,
                        ),
                        label: '',
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    unselectedItemColor: Colors.grey,
                    onTap: _onItemTapped,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.white,
                  )
                : const SizedBox.shrink(); // hidden
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(Widget icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            alignment: Alignment.center,
            child: Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? KColors.appBlackColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
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

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              "Alert!!",
              style: TextStyle(
                  fontFamily: 'Poppins',
                  color: KColors.appPrimaryRed,
                  fontSize: 18,fontWeight: FontWeight.w600),
            ),
            content: Flexible(
              child: const Text("Are you sure you want to exit?",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: KColors.appBlackColor,
                      fontSize: 16,fontWeight: FontWeight.w500)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No",
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: KColors.appBlackColor,
                        fontSize: 16,fontWeight: FontWeight.w600)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes",
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: KColors.appPrimaryRed,
                        fontSize: 16,fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
