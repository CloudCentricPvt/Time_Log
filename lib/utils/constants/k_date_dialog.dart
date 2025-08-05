import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class KDateDialog {
  static Future<String?> selectDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900), // Far past date
      lastDate: DateTime(2100),  // Far future date
    );
    if (pickedDate != null) {
      return DateFormat('dd, MMM yyyy').format(pickedDate); // Format changed here
    }
    return null;
  }

  ///--- Future date
  static Future<String?> futureDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? lastDate,
  }) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: now, // Restrict selection to future dates only
      lastDate: lastDate ?? DateTime(2100),
    );

    if (pickedDate != null) {
      return DateFormat('dd, MMM yyyy').format(pickedDate); // Format changed here
    }
    return null;
  }

  ///--- Current date to Previous date
  static Future<String?> currentDateToPreviousDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
  }) async {
    DateTime now = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(1990), // Allow past dates from the year 1990 (or any past limit)
      lastDate: now, // Restrict to today (no future dates)
    );

    if (pickedDate != null) {
      return DateFormat('dd, MMM yyyy').format(pickedDate);
    }
    return null;
  }


  /// ---user can select current date and before one month's date
 /* static Future<String?> pastOneMonthDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? lastDate,
  }) async {
    DateTime now = DateTime.now();
    DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: oneMonthAgo,
      lastDate: lastDate ?? now,
    );

    if (pickedDate != null) {
      return DateFormat('dd, MMM yyyy').format(pickedDate);
    }
    return null;
  }*/

  static Future<String?> pastOneMonthDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? lastDate,
  }) async {
    DateTime now = DateTime.now();
    DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    DateTime oneMonthAhead = DateTime(now.year, now.month + 1, now.day);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: oneMonthAgo,
      lastDate: lastDate ?? oneMonthAhead, // allow future dates up to 1 month ahead
    );

    if (pickedDate != null) {
      return DateFormat('dd, MMM yyyy').format(pickedDate);
    }
    return null;
  }


}

