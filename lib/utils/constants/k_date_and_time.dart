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
      DateTime date = DateFormat("d/M/yyyy").parse(dateString);
      return DateFormat("dd").format(date); // 2-digit day
    } catch (e) {
      print("Date parse error in getDay: $e");
      return "--";
    }
  }

  /// Returns month + year like "April, 2025"
  String getMonthYear(String dateString) {
    try {

      DateTime date = DateFormat("d/M/yyyy").parse(dateString);
      return DateFormat("MMM, yyyy").format(date); // Abbreviated month format like Jan, Feb
    } catch (e) {
      print("Date parse error in getMonthYear: $e");
      return "--";
    }
  }
}
