import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:add_2_calendar_new/add_2_calendar_new.dart' as calendar;
import 'package:lw_app/Blocs/EventRsvp/event_rsvp_bloc.dart';
import 'package:lw_app/Blocs/Events/events_bloc.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Models/Event/rsvp_status.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';

class UpcomingEventDetailPage extends StatelessWidget {
  final Event event;

  const UpcomingEventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

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
            // Hero Background Image
            SizedBox(
              height: size.height * 0.45,
              width: double.infinity,
              child: Hero(
                tag: 'event_image_${event.id}',
                child: CldImageWidget(
                  publicId: event.bannerPublicId ?? 'samples/cloudinary-icon',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Gradient Overlay
            Container(
              height: size.height * 0.45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.2),
                    theme.scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),

            // Content
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.45),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: LwpRadii.lgTop,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(LwpRadii.pill),
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
                            ),
                          ],
                        ),
                        const Divider(height: 48),

                        _buildInfoTile(
                          context,
                          Icons.calendar_today_rounded,
                          "Datum",
                          "${event.day} ${DateFormatter.formatDate(event.startDate)}",
                        ),
                        _buildInfoTile(
                          context,
                          Icons.access_time_rounded,
                          "Tyd",
                          DateFormatter.formatTime(event.time),
                        ),

                        const SizedBox(height: 32),
                        Text(
                          "Beskrywing",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          event.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),

                        const Divider(height: 48),

                        // RSVP section
                        _buildRsvpSection(context),

                        const SizedBox(height: 32),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _addToCalendar(),
                            icon: const Icon(Icons.event_available_rounded),
                            label: const Text("Voeg by Kalender"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Back Button
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
              "Gaan jy?",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (isUpdating)
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: RsvpStatus.values.map((status) {
                  final isSelected = rsvpState.userStatus == status;
                  final isDisabled = status == RsvpStatus.attending &&
                      rsvpState.isFull &&
                      !isSelected;

                  int count;
                  if (status == RsvpStatus.attending) {
                    count = rsvpState.attendingCount;
                  } else if (status == RsvpStatus.interested) {
                    count = rsvpState.interestedCount;
                  } else {
                    count = rsvpState.notAttendingCount;
                  }

                  final label = isDisabled
                      ? 'Vol Bespreek'
                      : '${status.afrikaansLabel} $count';

                  return ActionChip(
                    label: Text(label),
                    backgroundColor: isSelected ? theme.primaryColor : null,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : isDisabled
                              ? theme.disabledColor
                              : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                    side: isSelected
                        ? BorderSide(color: theme.primaryColor)
                        : null,
                    onPressed: isDisabled
                        ? null
                        : () {
                            context.read<EventRsvpBloc>().add(
                                  SubmitRsvpEvent(
                                    eventId: event.id!,
                                    newStatus: status,
                                  ),
                                );
                          },
                  );
                }).toList(),
              ),
            if (rsvpState.capacity != null) ...[
              const SizedBox(height: 8),
              Text(
                '${rsvpState.attendingCount} / ${rsvpState.capacity} plekke bespreek',
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

  Widget _buildInfoTile(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: LwpRadii.smAll,
            ),
            child: Icon(icon, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
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
