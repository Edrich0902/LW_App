import 'package:flutter/material.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Events/events_bloc.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';

class UpcomingEventsPage extends StatefulWidget {
  const UpcomingEventsPage({super.key});

  @override
  State<UpcomingEventsPage> createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  @override
  void initState() {
    context.read<EventsBloc>().add(LoadEvents(eventType: EventType.ONCE));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EventsBloc eventsBloc = BlocProvider.of<EventsBloc>(context);

    return BlocListener<EventsBloc, EventsState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Opkomende Gebeure'),
          actions: const <Widget>[LwpAnnouncementButton(), ProfileActionButton()],
        ),
        body: SafeArea(
          child: BlocBuilder<EventsBloc, EventsState>(
            builder: (context, state) {
              if (state is EventsLoading) {
                return const LwpLoader(message: "Laai Opkomende Gebeure");
              } else if (state is EventsSuccess) {
                if (state.events.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => eventsBloc.add(LoadEvents(eventType: EventType.ONCE)),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.events.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildEventCard(state.events[index], () {
                          // TODO: open event detail here - create event detail screen
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

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            CldImageWidget(
                publicId: event.bannerPublicId ?? 'samples/cloudinary-icon',
                fit: BoxFit.fill
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.event),
                          const SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  event.title,
                                  style: theme.textTheme.titleMedium
                              ),
                              Text(
                                  event.description,
                                  style: theme.textTheme.bodyMedium
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                  _formatEventDateTime(event),
                                  style: theme.textTheme.bodySmall
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  String _formatEventDateTime(Event event) {
    if (event.startDate == null) return 'N/A';
    return "${event.day} ${DateFormatter.formatDate(event.startDate)} ${DateFormatter.formatTime(event.time)}";
  }
}
