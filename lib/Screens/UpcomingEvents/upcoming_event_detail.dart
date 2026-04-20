import 'package:flutter/material.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Widgets/LwpBanner/lwp_banner.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:add_2_calendar_new/add_2_calendar_new.dart' as calendar;

class UpcomingEventDetailPage extends StatelessWidget {
  final Event event;

  const UpcomingEventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gebeure Besonderhede'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LwpBanner(
              imageUrl: event.bannerUrl ?? '',
              imagePublicId: event.bannerPublicId,
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.category,
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
                    "Datum",
                    "${event.day} ${DateFormatter.formatDate(event.startDate)}",
                  ),
                  _buildInfoTile(
                    context,
                    Icons.access_time,
                    "Tyd",
                    DateFormatter.formatTime(event.time),
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
                    event.description,
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
                  color: Colors.black87,
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
      if (event.startDate == null) return;

      // Parse base date (ignore its time)
      final baseDate = DateTime.parse(event.startDate!);

      // Remove timezone from time (e.g. "18:00:00+00" -> "18:00:00")
      final cleanTime = event.time.split('+').first;
      final timeParts = cleanTime.split(':');

      final startDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );

      final endDateTime = event.endDate != null ? DateTime(
        DateTime.parse(event.endDate!).year,
        DateTime.parse(event.endDate!).month,
        DateTime.parse(event.endDate!).day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      ) : startDateTime.add(const Duration(hours: 1));

      final calendar.Event calEvent = calendar.Event(
        title: event.title,
        description: event.description,
        location: 'Lewende Woord Paarl',
        startDate: startDateTime,
        endDate: endDateTime,
        allDay: false,
      );

      calendar.Add2Calendar.addEvent2Cal(calEvent);
    } catch (e) {
      debugPrint("Error adding to calendar: $e");
    }
  }
}
