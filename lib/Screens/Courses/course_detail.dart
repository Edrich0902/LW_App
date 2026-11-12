import 'package:flutter/material.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:lw_app/Widgets/LwpDateBeaconCard/lwp_date_beacon_card.dart';

class CourseDetailPage extends StatelessWidget {
  final Event course;

  const CourseDetailPage({super.key, required this.course});

  static const double _heroFraction = 0.32;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final heroHeight = size.height * _heroFraction;
    final locale = Localizations.localeOf(context).toString();
    final date = LwpDateBeaconCard.parseStartDate(course.startDate);
    final timeLabel = DateFormatter.formatTime(course.time);
    final endLabel = course.endDate != null
        ? DateFormatter.formatDate(course.endDate)
        : null;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: heroHeight,
            width: double.infinity,
            child: Hero(
              tag: 'course_image_${course.id}',
              child: CldImageWidget(
                publicId: course.bannerPublicId ?? 'samples/cloudinary-icon',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: heroHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  theme.scaffoldBackgroundColor.withValues(alpha: 0.2),
                  theme.scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: heroHeight - 28),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: LwpRadii.lgTop,
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    LwpSpacing.lg,
                    LwpSpacing.lg,
                    LwpSpacing.lg,
                    LwpSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LwpDateTile(
                            date: date,
                            locale: locale,
                            fallbackDayName: course.day,
                          ),
                          const SizedBox(width: LwpSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (course.category.trim().isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(
                                        LwpRadii.pill,
                                      ),
                                    ),
                                    child: Text(
                                      course.category,
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: LwpSpacing.xs),
                                Text(
                                  course.title,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.4,
                                    height: 1.2,
                                  ),
                                ),
                                if (timeLabel.isNotEmpty) ...[
                                  const SizedBox(height: LwpSpacing.xxs),
                                  Text(
                                    timeLabel,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (course.description.trim().isNotEmpty) ...[
                        const SizedBox(height: LwpSpacing.lg),
                        Text(
                          course.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.hintColor,
                            height: 1.55,
                          ),
                        ),
                      ],
                      if (endLabel != null && endLabel.isNotEmpty) ...[
                        const SizedBox(height: LwpSpacing.lg),
                        Text(
                          context.l10n.courseEndDate.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.hintColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: LwpSpacing.xs),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.12),
                                borderRadius: LwpRadii.smAll,
                              ),
                              child: Icon(
                                Icons.event_note_rounded,
                                color: theme.primaryColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: LwpSpacing.sm),
                            Text(
                              endLabel,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: LwpSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _addToCalendar(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(context.l10n.commonAddToCalendar),
                        ),
                      ),
                      const SizedBox(height: LwpSpacing.lg),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCalendar() {
    try {
      if (course.startDate == null) return;

      final baseDate = DateTime.parse(course.startDate!);
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
        calendar.Frequency? frequency;
        if (course.type == EventType.DAILY) {
          frequency = calendar.Frequency.daily;
        } else if (course.type == EventType.WEEKLY) {
          frequency = calendar.Frequency.weekly;
        } else if (course.type == EventType.MONTHLY) {
          frequency = calendar.Frequency.monthly;
        } else if (course.type == EventType.YEARLY) {
          frequency = calendar.Frequency.yearly;
        }

        if (frequency != null) {
          recurrence = calendar.Recurrence(
            frequency: frequency,
            endDate:
                course.endDate != null ? DateTime.parse(course.endDate!) : null,
          );
        }
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
