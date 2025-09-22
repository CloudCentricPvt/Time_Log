import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/utils/constants/k_colors.dart';
import 'package:time_log/utils/constants/k_drawer_menu.dart';
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
    _selectedIndex = widget.initialIndex;
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
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawerMenu(
          context: context,
        isBottomNavVisible: isBottomNavVisible,
        selectedIndex : _selectedIndex,
        onMenuTap: (index) {
          Navigator.of(context).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onItemTapped(index);
          });

        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: isBottomNavVisible,
          builder: (context, isVisible, _) {
            return isVisible
                ? BottomAppBar(
                    color: KColors.dayWiseCardBGColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(
                            SvgPicture.asset(
                              KAssets.homeIcon,
                              width: 24,
                              height: 24,
                              color: _selectedIndex == 0
                                  ? KColors.appPrimary
                                  : KColors.textColor ,
                            ),
                            "Dashboard",
                            0,
                          ),
                          _buildNavItem(
                            SvgPicture.asset(
                              KAssets.timeLoge,
                              width: 28,
                              height: 28,
                              color: _selectedIndex == 1
                                  ? KColors.orangeColor
                                  : KColors.textColor,
                            ),
                            "Time Logs",
                            1,
                          ),
                          _buildNavItem(
                            SvgPicture.asset(
                              KAssets.leaveIcon,
                              width: 28,
                              height: 28,
                              color: _selectedIndex == 2
                                  ? KColors.greenColor
                                  :KColors.textColor,
                            ),
                            "Leaves",
                            2,
                          ),
                          _buildNavItem(
                            SvgPicture.asset(
                              KAssets.profileIcon,
                              width: 28,
                              height: 28,
                              color: _selectedIndex == 3
                                  ? KColors.appPrimaryYellow
                                  : KColors.textColor,
                            ),
                            "Profile",
                            3,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
    );
  }

  Widget _buildNavItem(Widget icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? KColors.appBlackColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: KColors.appColorWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
