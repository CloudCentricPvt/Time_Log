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
      firstDate: firstDate ?? DateTime(1950),
      lastDate: lastDate ?? DateTime(2100),
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

  ///--- Current date and Future date(open date picker)
  static Future<String?> selectFutureOrCurrentDate({required BuildContext context, DateTime? initialDate, DateTime? lastDate,}) async {
    DateTime today = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? today,
      firstDate: today, // Restricts selection to today and future dates
      lastDate: lastDate ?? DateTime(2100), // Allows future dates
    );

    if (pickedDate != null) {
      return DateFormat('dd, MMM yyyy').format(pickedDate); // Format changed here
    }
    return null;
  }

  static Future<String?> selectFutureOrCurrentDateYYYY_DD_MM({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? lastDate,
  }) async {
    DateTime today = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? today,
      firstDate: today, // Only future dates
      lastDate: lastDate ?? DateTime(2100),
    );

    if (pickedDate != null) {
      return DateFormat('yyyy-MM-dd').format(pickedDate); // ← your desired format
    }
    return null;
  }
}

