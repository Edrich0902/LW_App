import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:lw_app/Blocs/Events/events_bloc.dart';
import 'package:lw_app/Blocs/EventRsvp/event_rsvp_bloc.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Screens/UpcomingEvents/upcoming_event_detail.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';

class UpcomingEventsPage extends StatefulWidget {
  const UpcomingEventsPage({super.key});

  @override
  State<UpcomingEventsPage> createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  late DateTime currentDate;

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    context.read<EventsBloc>().add(
          LoadUpcomingEvents(eventType: EventType.ONCE, date: currentDate),
        );
  }

  @override
  Widget build(BuildContext context) {
    final eventsBloc = context.read<EventsBloc>();

    return BlocListener<EventsBloc, EventsState>(
      listener: (context, state) {},
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Opkomende Gebeure'),
          actions: const <Widget>[
            LwpAnnouncementButton(),
            ProfileActionButton()
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<EventsBloc, EventsState>(
            builder: (context, state) {
              if (state is EventsLoading) {
                return const LwpLoader(message: "Laai Opkomende Gebeure");
              } else if (state is EventsSuccess) {
                if (state.events.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => eventsBloc.add(
                      LoadUpcomingEvents(
                          eventType: EventType.ONCE, date: currentDate),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 24.0),
                      itemCount: state.events.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16.0),
                      itemBuilder: (BuildContext context, int index) {
                        final event = state.events[index];
                        return _buildEventCard(event, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) =>
                                    EventRsvpBloc()..add(InitEventRsvp(event)),
                                child: UpcomingEventDetailPage(event: event),
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  );
                } else {
                  return const LwpEmpty(message: "Geen Opkomende Gebeure");
                }
              } else {
                return const LwpError();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event, VoidCallback onTap) {
    final theme = Theme.of(context);
    final hasRsvps = event.attendingCount + event.interestedCount > 0;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: LwpRadii.lgAll,
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Hero(
                tag: 'event_image_${event.id}',
                child: CldImageWidget(
                  publicId: event.bannerPublicId ?? 'samples/cloudinary-icon',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Divider(height: 24.0),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16.0,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          _formatEventDateTime(event),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14.0,
                        color: theme.hintColor.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  if (hasRsvps) ...[
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 14.0, color: theme.hintColor),
                        const SizedBox(width: 4.0),
                        Text(
                          '${event.attendingCount} kom',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        if (event.interestedCount > 0) ...[
                          Text(
                            '  •  ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          Icon(Icons.star_outline_rounded,
                              size: 14.0, color: theme.hintColor),
                          const SizedBox(width: 4.0),
                          Text(
                            '${event.interestedCount} stel belang',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatEventDateTime(Event event) {
    if (event.startDate == null) return 'N/A';
    return "${event.day} ${DateFormatter.formatDate(event.startDate)} ${DateFormatter.formatTime(event.time)}";
  }
}
