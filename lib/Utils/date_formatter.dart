import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(String? date) {
    if (date == null) return '';
    var convertedDate = DateTime.parse(date);
    return DateFormat.yMMMd('en_ZA').format(convertedDate);
  }

  static String formatTime(String? time) {
    if (time == null) return '';
    var convertedTime = DateTime.parse("1970-01-01T${time}");
    return DateFormat.Hm().format(convertedTime);
  }
}