import 'package:flutter/material.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Widgets/LwpBottomSheet/lwp_bottom_sheet.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:add_2_calendar_new/add_2_calendar_new.dart' as calendar;

class LwpEvent extends StatelessWidget {
  const LwpEvent({
    super.key,
    required this.event,
  });

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: () => _showEventDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(LwpSpacing.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: LwpRadii.smAll,
                child: CldImageWidget(
                  publicId: event.bannerPublicId ?? 'samples/cloudinary-icon',
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          DateFormatter.formatTime(event.time),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.hintColor,
              ),
            ],
          ),
        ),
      ),
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
              "Beskrywing",
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
                label: const Text("Voeg by Kalender"),
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
      // Use startDate if available, otherwise assume current week's day
      DateTime baseDate;
      if (event.startDate != null) {
        baseDate = DateTime.parse(event.startDate!);
      } else {
        // Fallback for weekly rhythm items that might not have a hard startDate
        baseDate = DateTime.now();
      }

      // Remove timezone from time (e.g. "18:00:00+00" -> "18:00:00")
      final cleanTime = event.time.split('+').first;
      final timeParts = cleanTime.split(':');

      DateTime startDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );

      // For weekly events the stored start_date may not fall on the correct
      // day of week. Adjust forward to the nearest matching weekday so the
      // calendar repeats on the right day (e.g. Monday, not the creation day).
      if (event.type == EventType.WEEKLY && event.day.isNotEmpty) {
        const dayToWeekday = {
          'Monday': DateTime.monday,
          'Tuesday': DateTime.tuesday,
          'Wednesday': DateTime.wednesday,
          'Thursday': DateTime.thursday,
          'Friday': DateTime.friday,
          'Saturday': DateTime.saturday,
          'Sunday': DateTime.sunday,
        };
        final targetWeekday = dayToWeekday[event.day];
        if (targetWeekday != null && startDateTime.weekday != targetWeekday) {
          final daysToAdd = (targetWeekday - startDateTime.weekday + 7) % 7;
          startDateTime = startDateTime.add(Duration(days: daysToAdd));
        }
      }

      final endDateTime = event.endDate != null
          ? DateTime(
              DateTime.parse(event.endDate!).year,
              DateTime.parse(event.endDate!).month,
              DateTime.parse(event.endDate!).day,
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
              int.parse(timeParts[2]),
            )
          : startDateTime.add(const Duration(hours: 1));

      // Determine recurrence based on event type
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
