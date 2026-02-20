import 'package:flutter/material.dart';
import 'package:time_log/views/dashBoard/check_in_check_out.dart';
import 'package:time_log/views/holidaysList/holiday_List.dart';
import 'package:time_log/views/home/home_screen.dart';
import 'package:time_log/views/leaves/apply_leave.dart';
import 'package:time_log/views/leaves/leave_history.dart';
import 'package:time_log/views/leaves/request_work_from_home.dart';
import 'package:time_log/views/profile/profile_screen.dart';
import 'package:time_log/views/upcoming/upcoming_events.dart';

import '../timelog_memory/chat_bot_memory.dart';

class PredefinedResponse {
  final String message;
  final WidgetBuilder? navigateTo;
  final String? actionLabel;

  PredefinedResponse({
    required this.message,
    this.navigateTo,
    this.actionLabel,
  });
}

class PredefinedResponder {
  static PredefinedResponse? getResponse(String input) {
    final text = input.toLowerCase().trim();

    final date = extractDateFromInput(input);
    const String info =
        "CloudCentric Infotech Pvt. Ltd. is an IT services and solutions company "
        "specializing in Salesforce consulting, implementation, integration, and "
        "digital transformation services. Founded in 2014, we help businesses "
        "with scalable and secure technology solutions across the globe.\n\n"
        "🌐 For more, visit our website:\n https://cccinfotech.com";

    if (date != null && _contains(input, ['timelog', 'hours', 'worked'])) {
      final totalMinutes = ChatbotMemory.getTotalMinutesByDate(date);
      return PredefinedResponse(
        message: totalMinutes == 0
            ? "No timelog found for $date."
            : "You logged ${(totalMinutes / 60).toStringAsFixed(
            2)},${ChatbotMemory.getRejectedLogs('pending')} hours on $date.",
      );
    } else if (_contains(text,
        ['total hours', 'monthly hours', 'worked hours', 'time log summary'])) {
      if (!ChatbotMemory.hasTimeLog) {
        return PredefinedResponse(
          message:
          "I don’t have your timelog data yet. Please try again later.",
        );
      }

      return PredefinedResponse(
        message:
        "You have logged ${ChatbotMemory.totalMonthlyHours} ,${ChatbotMemory
            .getLogsByDate(date!)} hours this month.",
      );
    } else if (_contains(text, ['pending timelog', 'pending logs'])) {
      return PredefinedResponse(
        message:
        " Pending Time-logs (${ChatbotMemory
            .getRejectedLogs('pending')
            .length}):\n\n"
            "${ChatbotMemory.getRejectedLogsText('pending')}",
      );
    } else if (_contains(
        text, ['approve timelog', 'approved logs', 'approve'])) {
      return PredefinedResponse(
        message:
        "You have ${ChatbotMemory.allTimeLogResponse
            ?.status} approve timelog entries.",
      );
    } else if (_contains(
        input, ['rejected', 'rejected timelog', 'reject', 'reject logs'])) {
      return PredefinedResponse(
        message:
        " Rejected Time-logs (${ChatbotMemory
            .getRejectedLogs('rejected')
            .length}):\n\n"
            "${ChatbotMemory.getRejectedLogsText('rejected')}",
      );
    } else if (_contains(text, ['total timelog', 'how many timelogs'])) {
      return PredefinedResponse(
        message:
        "You have submitted ${ChatbotMemory.totalLogs},${ChatbotMemory
            .getLogsByDate(date!)} timelog entries.",
      );
    } else if (_contains(text, [
      'cloudcentric',
      'ccc infotech',
      'cccinfotech',
      'cccentotech',
      'your company',
      'my company',
      'about your company',
      'about us',
      'cloud centric'
    ])) {
      return PredefinedResponse(
        message: info,
        navigateTo: null,
      );
    } else if (_contains(text, ['check in', 'punch in'])) {
      return PredefinedResponse(
        message: "Opening Check-In screen for you ",
        navigateTo: (context) => const CheckInCheckOut(),

      );
    } else if (_contains(text, ['check out', 'punch out'])) {
      return PredefinedResponse(
        message: "Opening Check-Out screen for you ",
        navigateTo: (context) => const CheckInCheckOut(),

      );
    } else if (_contains(text, ['dashboard', 'home'])) {
      return PredefinedResponse(
        message: "Here is your Dashboard ",
        navigateTo: (context) => const HomeScreen(),

      );
    } else if (_contains(text, [
      'apply leave',
    ])) {
      return PredefinedResponse(
        message: "Let’s apply for leave ",
        navigateTo: (context) => const ApplyLeave(),

      );
    } else if (_contains(text, ['wfh', 'work from home'])) {
      return PredefinedResponse(
        message: "Opening Work From Home screen ",
        navigateTo: (context) => const RequestWorkFromHome(),

      );
    } else if (_contains(text, ['profile', 'my profile'])) {
      return PredefinedResponse(
        message: "Here is your profile ",
        navigateTo: (context) => const ProfileScreen(),


      );
    } else if (_contains(text, ['history', 'leave history'])) {
      return PredefinedResponse(
        message: "Here is your Leave History ",
        navigateTo: (context) => const LeaveHistory(),

      );
    } else if (_contains(text, ['upcoming', 'upcoming leave'])) {
      return PredefinedResponse(
        message: "Here is  upcoming leave",
        navigateTo: (context) => const UpcomingEvents(),

      );
    } else if (_contains(text, ['holiday', 'holiday list'])) {
      return PredefinedResponse(
        message: "Here is  Holiday List",
        navigateTo: (context) => const HolidayList(),

      );
    }
    return null;
  }

  static bool _contains(String input, List<String> keys) {
    for (final k in keys) {
      if (input.contains(k)) return true;
    }
    return false;
  }

  static String? extractDateFromInput(String input) {
    input = input.toLowerCase();

    final relative = extractRelativeDate(input);
    if (relative != null) return relative;

    final iso = RegExp(r'\b\d{4}-\d{2}-\d{2}\b').firstMatch(input)?.group(0);
    if (iso != null) return iso;

    final common =
    RegExp(r'\b\d{1,2}[-/]\d{1,2}[-/]\d{4}\b').firstMatch(input)?.group(0);

    return common;
  }

  static String? extractRelativeDate(String input) {
    final now = DateTime.now();

    if (input.contains('today')) {
      return _formatDate(now);
    }
    if (input.contains('yesterday')) {
      return _formatDate(now.subtract(const Duration(days: 1)));
    }
    return null;
  }

  static String _formatDate(DateTime date) {
    return date
        .toIso8601String()
        .split('T')
        .first;
  }
}
