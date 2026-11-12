import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Events/events_bloc.dart';
import 'package:lw_app/Widgets/Glass/lwp_chrome_scaffold.dart';
import 'package:lw_app/Blocs/EventRsvp/event_rsvp_bloc.dart';
import 'package:lw_app/Extensions/context_l10n.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Screens/UpcomingEvents/upcoming_event_detail.dart';
import 'package:lw_app/Themes/lwp_tokens.dart';
import 'package:lw_app/Widgets/LwpDateBeaconCard/lwp_date_beacon_card.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpSkeleton/lwp_skeleton.dart';
import 'package:lw_app/Widgets/LwpListEntrance/lwp_list_entrance.dart';

class UpcomingEventsPage extends StatefulWidget {
  const UpcomingEventsPage({super.key});

  @override
  State<UpcomingEventsPage> createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  final _listEntrance = LwpListEntranceController();
  late DateTime currentDate;

  @override
  void dispose() {
    _listEntrance.dispose();
    super.dispose();
  }

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
      child: LwpChromeScaffold(
        title: context.l10n.dashboardUpcomingEvents,
        showDefaultActions: true,
        body: BlocBuilder<EventsBloc, EventsState>(
            builder: (context, state) {
              if (state is EventsLoading) {
                return LwpSkeletonList.thumb();
              } else if (state is EventsSuccess) {
                if (state.events.isNotEmpty) {
                  return LwpListEntranceScope(
                    controller: _listEntrance,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _listEntrance.bump();
                        eventsBloc.add(
                          LoadUpcomingEvents(
                            eventType: EventType.ONCE,
                            date: currentDate,
                          ),
                        );
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 24.0),
                        itemCount: state.events.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: LwpSpacing.sm),
                        itemBuilder: (BuildContext context, int index) {
                          final event = state.events[index];
                          return LwpListEntrance(
                            id: event.id ?? 'event-$index',
                            child: LwpDateBeaconCard(
                              event: event,
                              heroTag: 'event_image_${event.id}',
                              showAttendance: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) => EventRsvpBloc()
                                        ..add(InitEventRsvp(event)),
                                      child: UpcomingEventDetailPage(
                                        event: event,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  return LwpEmpty(message: context.l10n.upcomingEventsEmpty);
                }
              } else {
                return const LwpError();
              }
            },
          ),
      ),
    );
  }

}
