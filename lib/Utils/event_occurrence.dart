import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Models/Event/event_type.dart';

/// Resolves the next visible occurrence for calendar / beacon dates.
class EventOccurrence {
  EventOccurrence._();

  static const _dayToWeekday = {
    'Monday': DateTime.monday,
    'Tuesday': DateTime.tuesday,
    'Wednesday': DateTime.wednesday,
    'Thursday': DateTime.thursday,
    'Friday': DateTime.friday,
    'Saturday': DateTime.saturday,
    'Sunday': DateTime.sunday,
  };

  /// Next occurrence from [from] (defaults to now).
  ///
  /// Weekly: next matching [Event.day]. If that day is today and the event
  /// time has already passed, rolls to next week.
  /// Once: the stored start date (even if past).
  /// Returns null when a series has ended ([Event.endDate] passed).
  static DateTime? nextFor(Event event, {DateTime? from}) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final seriesStart = _dateOnly(event.startDate);
    final seriesEnd = _dateOnly(event.endDate);

    if (event.type == EventType.ONCE) {
      return seriesStart;
    }

    if (event.type == EventType.DAILY) {
      var candidate = today;
      if (_isTimePassed(now, candidate, event.time)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return _clampToSeries(candidate, seriesStart, seriesEnd);
    }

    if (event.type == EventType.WEEKLY || event.day.isNotEmpty) {
      final targetWeekday = _dayToWeekday[event.day];
      if (targetWeekday == null) return seriesStart;

      var daysToAdd = (targetWeekday - today.weekday + 7) % 7;
      var candidate = today.add(Duration(days: daysToAdd));

      if (daysToAdd == 0 && _isTimePassed(now, candidate, event.time)) {
        candidate = candidate.add(const Duration(days: 7));
      }

      if (seriesStart != null && candidate.isBefore(seriesStart)) {
        final startDays =
            (targetWeekday - seriesStart.weekday + 7) % 7;
        candidate = seriesStart.add(Duration(days: startDays));
      }

      return _clampToSeries(candidate, seriesStart, seriesEnd);
    }

    if (event.type == EventType.MONTHLY && seriesStart != null) {
      var candidate = DateTime(today.year, today.month, seriesStart.day);
      if (candidate.isBefore(today) ||
          (candidate == today && _isTimePassed(now, candidate, event.time))) {
        candidate = DateTime(today.year, today.month + 1, seriesStart.day);
      }
      return _clampToSeries(candidate, seriesStart, seriesEnd);
    }

    if (event.type == EventType.YEARLY && seriesStart != null) {
      var candidate =
          DateTime(today.year, seriesStart.month, seriesStart.day);
      if (candidate.isBefore(today) ||
          (candidate == today && _isTimePassed(now, candidate, event.time))) {
        candidate =
            DateTime(today.year + 1, seriesStart.month, seriesStart.day);
      }
      return _clampToSeries(candidate, seriesStart, seriesEnd);
    }

    return seriesStart;
  }

  static DateTime? _dateOnly(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final parsed = DateTime.parse(raw);
      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (_) {
      return null;
    }
  }

  static bool _isTimePassed(DateTime now, DateTime day, String time) {
    final parts = time.split('+').first.split(':');
    if (parts.length < 2) return false;
    try {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final second = parts.length > 2 ? int.parse(parts[2]) : 0;
      final at = DateTime(day.year, day.month, day.day, hour, minute, second);
      return !now.isBefore(at);
    } catch (_) {
      return false;
    }
  }

  static DateTime? _clampToSeries(
    DateTime candidate,
    DateTime? seriesStart,
    DateTime? seriesEnd,
  ) {
    if (seriesStart != null && candidate.isBefore(seriesStart)) {
      return null;
    }
    if (seriesEnd != null && candidate.isAfter(seriesEnd)) {
      return null;
    }
    return candidate;
  }
}
