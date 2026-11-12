import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Extensions/app_localizations_x.dart';
import 'package:lw_app/Blocs/EventRsvp/event_rsvp_bloc.dart';
import 'package:lw_app/Blocs/Events/events_bloc.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Models/Event/rsvp_status.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Widgets/LwpDateBeaconCard/lwp_date_beacon_card.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';

class UpcomingEventDetailPage extends StatelessWidget {
  final Event event;

  const UpcomingEventDetailPage({super.key, required this.event});

  static const double _heroFraction = 0.32;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final heroHeight = size.height * _heroFraction;
    final locale = Localizations.localeOf(context).toString();
    final date = LwpDateBeaconCard.parseStartDate(event.startDate);
    final timeLabel = DateFormatter.formatTime(event.time);

    return BlocListener<EventRsvpBloc, EventRsvpState>(
      listener: (context, state) {
        if (state is EventRsvpError) {
          LwpSnackbar.showError(context, state.message);
        }
        if (state is EventRsvpReady) {
          context.read<EventsBloc>().add(UpdateEventRsvpCounts(
                eventId: event.id!,
                attendingCount: state.attendingCount,
                interestedCount: state.interestedCount,
                notAttendingCount: state.notAttendingCount,
                userStatus: state.userStatus,
              ));
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              height: heroHeight,
              width: double.infinity,
              child: Hero(
                tag: 'event_image_${event.id}',
                child: CldImageWidget(
                  publicId: event.bannerPublicId ?? 'samples/cloudinary-icon',
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
                              fallbackDayName: event.day,
                            ),
                            const SizedBox(width: LwpSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (event.category.trim().isNotEmpty)
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
                                        event.category,
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: LwpSpacing.xs),
                                  Text(
                                    event.title,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.4,
                                      height: 1.2,
                                    ),
                                  ),
                                  if (timeLabel.isNotEmpty) ...[
                                    const SizedBox(height: LwpSpacing.xxs),
                                    Text(
                                      timeLabel,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (event.description.trim().isNotEmpty) ...[
                          const SizedBox(height: LwpSpacing.lg),
                          Text(
                            event.description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.hintColor,
                              height: 1.55,
                            ),
                          ),
                        ],
                        const SizedBox(height: LwpSpacing.md),
                        _buildAttendanceStats(context),
                        const SizedBox(height: LwpSpacing.lg),
                        _buildRsvpSection(context),
                        const SizedBox(height: LwpSpacing.lg),
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
      ),
    );
  }

  Widget _buildAttendanceStats(BuildContext context) {
    final theme = Theme.of(context);
    const good = Color(0xFF7DCEB0);

    return BlocBuilder<EventRsvpBloc, EventRsvpState>(
      builder: (context, state) {
        final rsvpState = state is EventRsvpReady
            ? state
            : state is EventRsvpUpdating
                ? state.previous
                : state is EventRsvpError
                    ? state.previous
                    : null;
        if (rsvpState == null) return const SizedBox.shrink();

        return Row(
          children: [
            Text(
              context.l10n.upcomingEventsAttendingCount(rsvpState.attendingCount),
              style: theme.textTheme.bodySmall?.copyWith(
                color: good,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (rsvpState.interestedCount > 0) ...[
              Text(
                '  ·  ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor.withValues(alpha: 0.5),
                ),
              ),
              Text(
                context.l10n
                    .upcomingEventsInterestedCount(rsvpState.interestedCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRsvpSection(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<EventRsvpBloc, EventRsvpState>(
      builder: (context, state) {
        final rsvpState = state is EventRsvpReady
            ? state
            : state is EventRsvpUpdating
                ? state.previous
                : state is EventRsvpError
                    ? state.previous
                    : null;

        if (rsvpState == null) return const SizedBox.shrink();

        final isUpdating = state is EventRsvpUpdating;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.upcomingEventAreYouGoing.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: LwpSpacing.sm),
            if (isUpdating)
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Row(
                children: RsvpStatus.values.map((status) {
                  final isSelected = rsvpState.userStatus == status;
                  final isDisabled = status == RsvpStatus.attending &&
                      rsvpState.isFull &&
                      !isSelected;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: status == RsvpStatus.values.last
                            ? 0
                            : LwpSpacing.xs,
                      ),
                      child: Material(
                        color: isSelected
                            ? theme.primaryColor
                            : theme.cardColor,
                        borderRadius: LwpRadii.smAll,
                        child: InkWell(
                          borderRadius: LwpRadii.smAll,
                          onTap: isDisabled
                              ? null
                              : () {
                                  context.read<EventRsvpBloc>().add(
                                        SubmitRsvpEvent(
                                          eventId: event.id!,
                                          newStatus: status,
                                        ),
                                      );
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: LwpSpacing.sm,
                              horizontal: LwpSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: LwpRadii.smAll,
                              border: Border.all(
                                color: isSelected
                                    ? theme.primaryColor
                                    : theme.dividerColor
                                        .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              isDisabled
                                  ? context.l10n.upcomingEventSoldOut
                                  : status.label(context.l10n),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : isDisabled
                                        ? theme.disabledColor
                                        : null,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            if (rsvpState.capacity != null) ...[
              const SizedBox(height: LwpSpacing.xs),
              Text(
                context.l10n.upcomingEventCapacity(
                  rsvpState.attendingCount,
                  rsvpState.capacity!,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _addToCalendar() {
    try {
      if (event.startDate == null) return;

      final baseDate = DateTime.parse(event.startDate!);
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
