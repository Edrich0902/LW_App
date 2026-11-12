import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Utils/event_occurrence.dart';
import 'package:lw_app/Widgets/LwpBottomSheet/lwp_bottom_sheet.dart';
import 'package:lw_app/Widgets/LwpDateBeaconCard/lwp_date_beacon_card.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as calendar;

class LwpEvent extends StatelessWidget {
  const LwpEvent({
    super.key,
    required this.event,
  });

  final Event event;

  @override
  Widget build(BuildContext context) {
    return LwpDateBeaconCard(
      event: event,
      heroTag: 'calendar_event_${event.id ?? event.title}',
      coverHeight: 96,
      displayDate: EventOccurrence.nextFor(event),
      onTap: () => _showEventDetails(context),
    );
  }

  void _showEventDetails(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LwpBottomSheet(
        bannerPublicId: event.bannerPublicId,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: LwpSpacing.md),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(LwpRadii.pill),
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
              ],
            ),
            const SizedBox(height: LwpSpacing.md),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    color: theme.primaryColor, size: 20),
                const SizedBox(width: LwpSpacing.xs),
                Text(
                  DateFormatter.formatTime(event.time),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              context.l10n.groupDescriptionTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: LwpSpacing.xs),
            Text(
              event.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: LwpSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _addToCalendar(context),
                icon: const Icon(Icons.event_available_rounded),
                label: Text(context.l10n.commonAddToCalendar),
              ),
            ),
            const SizedBox(height: LwpSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _addToCalendar(BuildContext context) {
    try {
      final nextDay = EventOccurrence.nextFor(event) ?? DateTime.now();
      final cleanTime = event.time.split('+').first;
      final timeParts = cleanTime.split(':');

      final startDateTime = DateTime(
        nextDay.year,
        nextDay.month,
        nextDay.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
      );
      final endDateTime = startDateTime.add(const Duration(hours: 1));

      calendar.Recurrence? recurrence;
      if (event.type != EventType.ONCE) {
        calendar.Frequency? frequency;
        if (event.type == EventType.DAILY) {
          frequency = calendar.Frequency.daily;
        } else if (event.type == EventType.WEEKLY) {
          frequency = calendar.Frequency.weekly;
        } else if (event.type == EventType.MONTHLY) {
          frequency = calendar.Frequency.monthly;
        } else if (event.type == EventType.YEARLY) {
          frequency = calendar.Frequency.yearly;
        }

        if (frequency != null) {
          recurrence = calendar.Recurrence(
            frequency: frequency,
            endDate:
                event.endDate != null ? DateTime.parse(event.endDate!) : null,
          );
        }
      }

      final calendar.Event calEvent = calendar.Event(
        title: event.title,
        description: event.description,
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
