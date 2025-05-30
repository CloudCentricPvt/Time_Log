import 'package:intl/intl.dart';

class KDateAndTime {

  String getCurrentDateAndTime() {
    DateTime now = DateTime.now();

    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String dateTime = "$formattedDate $formattedTime";

    return dateTime;
  }

  String getDay(String dateString) {
    try {
      DateTime date = DateFormat("yyyy-MM-dd").parse(dateString); // MM for month
      return DateFormat("dd").format(date); // 2-digit day
    } catch (e) {
      print("Date parse error in getDay: $e");
      return "--";
    }
  }

  String getMonthYear(String dateString) {
    try {
      DateTime date = DateFormat("yyyy-MM-dd").parse(dateString); // MM for month
      return DateFormat("MMM, yyyy").format(date); // Jan, Feb, etc.
    } catch (e) {
      print("Date parse error in getMonthYear: $e");
      return "--";
    }
  }


  String getUpdatedTime() {
    DateTime currentTime = DateTime.now();
    DateTime updatedTime = currentTime.subtract(Duration(hours: 10));
    String formattedTime = DateFormat('HH:mm:ss').format(updatedTime);
    return formattedTime;
  }

  String convertToStandardDateFormatYYYY_MM_DD(String input) {
    try {
      // Remove any extra spaces
      input = input.trim();

      // Remove comma if it exists, since it's not a standard separator
      input = input.replaceAll(',', '');

      // Now format is like: "13 May 2025"
      DateTime parsedDate = DateFormat("dd MMM yyyy").parse(input);

      // Convert to desired format: "yyyy-MM-dd"
      return DateFormat("yyyy-MM-dd").format(parsedDate);
    } catch (e) {
      print("Date parsing error: $e");
      return "";
    }
  }

  /// --- calculate difference between  checkIn time and current time
  String getTimeDifferenceFromNow(String checkIn) {
    if (checkIn.isEmpty) return "00:00:00";

    try {
      final format = DateFormat("yyyy-MM-dd, hh:mm:ss a");

      DateTime checkInTime = format.parse(checkIn.trim());
      DateTime now = DateTime.now();

      Duration difference = now.difference(checkInTime); // now - checkIn

      if (difference.isNegative) {
        // If checkIn is in the future
        return "00:00:00";
      }

      String twoDigits(int n) => n.toString().padLeft(2, '0');
      return "${twoDigits(difference.inHours)}:"
          "${twoDigits(difference.inMinutes.remainder(60))}:"
          "${twoDigits(difference.inSeconds.remainder(60))}";
    } catch (e) {
      print("Parsing error: $e");
      return "00:00:00";
    }
  }

  /// --- calculate difference between  checkIn time and checkOut time
  String getDifferenceBetweenCheckInAndCheckOutTime(String checkIn, String checkOut) {
    // Check if either string is null or empty
    if (checkIn == null || checkIn.isEmpty || checkOut == null || checkOut.isEmpty) {
      return "";
    }

    try {
      // Example input format: "2025-05-13, 01:49:37 PM"
      final format = DateFormat("yyyy-MM-dd, hh:mm:ss a");

      DateTime checkInTime = format.parse(checkIn.trim());
      DateTime checkOutTime = format.parse(checkOut.trim());

      Duration difference = checkOutTime.difference(checkInTime);

      // Format to HH:mm:ss
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String formatted = "${twoDigits(difference.inHours)}:"
          "${twoDigits(difference.inMinutes.remainder(60))}:"
          "${twoDigits(difference.inSeconds.remainder(60))}";
      return formatted;
    } catch (e) {
      print("Date parsing error: $e");
      return "00:00:00";
    }
  }

  String getCurrentTime() {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm:ss');
    return formatter.format(now);
  }

  String getMonthName(String formattedDate) {
    final date = parseFormattedDate(formattedDate);
    return date != null ? DateFormat.MMMM().format(date) : '';
  }

  String getDayName(String formattedDate) {
    final date = parseFormattedDate(formattedDate);
    return date != null ? DateFormat.EEEE().format(date) : '';
  }

  String getDateNumber(String formattedDate) {
    final date = parseFormattedDate(formattedDate);
    return date != null ? DateFormat.d().format(date) : '';
  }

  DateTime? parseFormattedDate(String formattedDate) {
    try {
      return DateFormat('EEEE, dd MMMM yyyy').parse(formattedDate);
    } catch (e) {
      print("Date parsing error: $e");
      return null;
    }
  }

  String formatCustomDateMonthYearWithTime(String input) {
    try {
      input = input.trim();
      DateTime dateTime = DateFormat("yyyy-MM-dd, hh:mm:ss a").parseStrict(input);
      return DateFormat("MMM d. yyyy | hh:mm:ss a").format(dateTime);
    } catch (e) {
      print("Date format error: $e");
      return input; // fallback
    }
  }

  String useFormatDateInMyApp(String inputDate) {
    DateTime parsedDate = DateTime.parse(inputDate);
    return DateFormat('dd MMM, yyyy').format(parsedDate);
  }

}




