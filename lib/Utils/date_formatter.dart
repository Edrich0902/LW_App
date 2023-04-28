import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatTimeString({String? time, String? format = 'HH:mm:ssZ'}) {
    if (time == null) return '';
    DateFormat inputFormat = DateFormat(format);
    DateTime parsedTime = inputFormat.parse(time);
    return DateFormat('hh:mm a').format(parsedTime.toLocal());
  }
}