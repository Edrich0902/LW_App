import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Blocs/Calendar/calendar_bloc.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Widgets/LwpEvent/lwp_event.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Models/Event/event_category.dart';
import 'package:lw_app/Widgets/LwpAnnouncement/lwp_announcement.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    context.read<CalendarBloc>().add(LoadCalendar(eventType: EventType.WEEKLY, eventCategory: EventCategory.GENERAL));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    CalendarBloc calendarBloc = BlocProvider.of<CalendarBloc>(context);

    return BlocListener<CalendarBloc, CalendarState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kalender'),
          actions: const <Widget>[LwpAnnouncementButton(), ProfileActionButton()],
        ),
        body: SafeArea(
          child: BlocBuilder<CalendarBloc, CalendarState>(
            builder: (context, state) {
              if (state is CalendarLoading) {
                return const LwpLoader(message: "Loading Kalender");
              } else if (state is CalendarSuccess) {
                if (state.eventsMap.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => calendarBloc.add(LoadCalendar(eventType: EventType.WEEKLY, eventCategory: EventCategory.GENERAL)),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.eventsMap.length,
                      itemBuilder: (BuildContext context, int index) {
                        String weekday = state.eventsMap.keys.elementAt(index);
                        List<Event> weekdayEvents = state.eventsMap[weekday]!;

                        return Column(
                          children: <Widget>[
                            const SizedBox(height: 8.0),
                            Text(
                              weekday,
                              style: theme.textTheme.titleLarge
                            ),
                            const SizedBox(height: 8.0),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: weekdayEvents.length,
                              itemBuilder: (BuildContext context, int index) {
                                Event event = weekdayEvents[index];

                                return LwpEvent(event: event);
                              },
                            )
                          ],
                        );
                      },
                    ),
                  );
                } else {
                  return const LwpEmpty(message: "Geen Kalender Items");
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
}