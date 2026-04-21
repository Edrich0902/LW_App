import 'package:flutter/material.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Widgets/LwpBanner/lwp_banner.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:add_2_calendar_new/add_2_calendar_new.dart' as calendar;

class CourseDetailPage extends StatelessWidget {
  final Event course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kursus Besonderhede'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LwpBanner(
              imageUrl: course.bannerUrl ?? '',
              imagePublicId: course.bannerPublicId,
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course.category,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                  _buildInfoTile(
                    context,
                    Icons.calendar_today,
                    "Begin Datum",
                    "${course.day} ${DateFormatter.formatDate(course.startDate)}",
                  ),
                  if (course.endDate != null)
                    _buildInfoTile(
                      context,
                      Icons.calendar_month,
                      "Eind Datum",
                      DateFormatter.formatDate(course.endDate),
                    ),
                  _buildInfoTile(
                    context,
                    Icons.access_time,
                    "Tyd",
                    DateFormatter.formatTime(course.time),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Beskrywing",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _addToCalendar(),
                      icon: const Icon(Icons.event_note),
                      label: const Text("Voeg by Kalender"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addToCalendar() {
    try {
      if (course.startDate == null) return;

      // Parse base date
      final baseDate = DateTime.parse(course.startDate!);

      // Remove timezone from time
      final cleanTime = course.time.split('+').first;
      final timeParts = cleanTime.split(':');

      final startDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );

      final endDateTime = startDateTime.add(const Duration(hours: 1));

      calendar.Recurrence? recurrence;
      if (course.type != EventType.ONCE) {
        calendar.Frequency frequency;
        if (course.type == EventType.DAILY) {
          frequency = calendar.Frequency.daily;
        } else if (course.type == EventType.WEEKLY) {
          frequency = calendar.Frequency.weekly;
        } else if (course.type == EventType.MONTHLY) {
          frequency = calendar.Frequency.monthly;
        } else if (course.type == EventType.YEARLY) {
          frequency = calendar.Frequency.yearly;
        } else {
          frequency = calendar.Frequency.weekly; // Default to weekly
        }

        recurrence = calendar.Recurrence(
          frequency: frequency,
          interval: 1,
          endDate: course.endDate != null ? DateTime.parse(course.endDate!) : null,
        );
      }

      final calendar.Event calEvent = calendar.Event(
        title: course.title,
        description: course.description,
        location: 'Lewende Woord Paarl',
        startDate: startDateTime,
        endDate: endDateTime,
        allDay: false,
        recurrence: recurrence,
      );

      calendar.Add2Calendar.addEvent2Cal(calEvent);
    } catch (e) {
      debugPrint("Error adding to calendar: $e");
    }
  }
}
