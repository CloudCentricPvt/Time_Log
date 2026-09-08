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
        /*bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: isBottomNavVisible,
          builder: (context, isVisible, _) {
            return isVisible
                ? BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: _buildNavItem(
                    SvgPicture.asset(
                      KAssets.homeIcon,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 0
                            ? KColors.appPrimary
                            : KColors.textColor,
                        BlendMode.srcIn,
                      ),
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
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 1
                            ? KColors.orangeColor
                            : KColors.textColor,
                        BlendMode.srcIn,
                      ),
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
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 2
                            ? KColors.greenColor
                            : KColors.textColor,
                        BlendMode.srcIn,
                      ),
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
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 3
                            ? KColors.appPrimaryYellow
                            : KColors.textColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    "Profile",
                    3,
                  ),
                  label: '',
                ),
              ],
              currentIndex: _selectedIndex,
              unselectedItemColor: KColors.textColor,
              selectedItemColor: KColors.appPrimary,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 8,
              showSelectedLabels: false,  // ✅ Hide default labels
              showUnselectedLabels: false, // ✅ Hide default labels
              selectedLabelStyle: const TextStyle(fontSize: 0),
              unselectedLabelStyle: const TextStyle(fontSize: 0),
            )
                : const SizedBox.shrink();
          },
        ),*/
        bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: isBottomNavVisible,
          builder: (context, isVisible, _) {
            return isVisible
                ? Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildNavItem(
                        KAssets.homeIcon,
                        "Dashboard",
                        0,
                        KColors.appPrimary,
                        20,
                        20,
                      ),
                      _buildNavItem(
                        KAssets.timeLoge,
                        "Time Log",
                        1,
                        KColors.orangeColor,
                        22,
                        22,
                      ),
                      _buildNavItem(
                        KAssets.leaveIcon,
                        "Leaves",
                        2,
                        KColors.greenColor,
                        22,
                        22,
                      ),
                      _buildNavItem(
                        KAssets.profileIcon,
                        "Profile",
                        3,
                        KColors.appPrimaryYellow,
                        20,
                        20,
                      ),
                    ],
                  ),
                ),
              ),
            )
                : const SizedBox.shrink();
          },
        )
      ),
    );
  }

  Widget _buildNavItemOld(Widget icon, String label, int index) {
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
                color: isSelected ? KColors.textGrey : Colors.transparent,
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

  Widget _buildNavItemNew(Widget icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // ✅ Increased padding
        decoration: BoxDecoration(
          color: isSelected ? KColors.textGrey : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      String assetPath,
      String label,
      int index,
      Color activeColor,
      double width,
      double height,
      ) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? KColors.textGrey : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: KColors.textGrey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              width: width,
              height: height,
              colorFilter: ColorFilter.mode(
                !isSelected ? Colors.black : activeColor,
                BlendMode.srcIn,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ],
        ),
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
            content: const Text("Are you sure you want to exit?",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: KColors.textGrey,
                    fontSize: 16,fontWeight: FontWeight.w500)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No",
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: KColors.textGrey,
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
