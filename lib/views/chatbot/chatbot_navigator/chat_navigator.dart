import 'package:flutter/material.dart';
import 'package:time_log/views/all_privacy/privacy_policies_screen.dart';
import 'package:time_log/views/dashBoard/check_in_check_out.dart';
import 'package:time_log/views/home/home_screen.dart';
import 'package:time_log/views/leaves/apply_leave.dart';
import 'package:time_log/views/leaves/leave_history.dart';
import 'package:time_log/views/profile/profile_screen.dart';
import 'package:time_log/views/timelogs/time_logs_screen.dart';
import '../../leaves/request_work_from_home.dart';

class ChatbotNavigator {
  static bool navigate(BuildContext context, String userInput) {
    final input = userInput.toLowerCase().trim();
    print('User Input $input');

    if (_contains(input, ['check in', 'punch in'])) {
      _go(context, const CheckInCheckOut());
    } else if (_contains(input, ['check out', 'punch out'])) {
      _go(context, const CheckInCheckOut());
    } else if (_contains(input, ['dashboard', 'home'])) {
      _go(context, const HomeScreen());
    } else if (_contains(input, ['timelog', 'timelog'])) {
      _go(context, const TimeLogsScreen());
    } else if (_contains(input, ['apply leave', 'apply leave'])) {
      _go(context, const ApplyLeave());
    } else if (_contains(input, ['leave history','history'])) {
      _go(context, const LeaveHistory());
    } else if (_contains(input, ['wfh', 'work from home'])) {
      _go(context, const RequestWorkFromHome());
    } else if (_contains(input, ['profile', 'profile'])) {
      _go(context, const ProfileScreen());
    } else if (_contains(input, ['privacy policy','policy'])) {
      _go(
        context,
        const PrivacyPoliciesScreen(),
      );
    } else {
      return false;
    }

    return true;
  }

  static bool _contains(String input, List<String> keywords) {
    for (final word in keywords) {
      if (input.contains(word)) return true;
    }
    return false;
  }

  static void _go(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
