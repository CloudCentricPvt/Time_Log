import 'package:intl/intl.dart';

class KDateFormatter {
  static String formatDateTime(String rawDateTime) {
    try {
      DateTime dateTime = DateTime.parse(rawDateTime); // handles ISO 8601
      DateFormat outputFormat = DateFormat("MMM, d, yyyy | h:mm a");
      return outputFormat.format(dateTime);
    } catch (e) {
      print("Date parsing error: $e");
      return '';
    }
  }
}
