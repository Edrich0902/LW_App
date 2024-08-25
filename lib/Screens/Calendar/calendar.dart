import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Utils/snackbar.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:lw_app/Blocs/Calendar/calendar_bloc.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Models/Event/event.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    context.read<CalendarBloc>().add(LoadCalendar(eventType: EventType.WEEKLY));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CalendarBloc calendarBloc = BlocProvider.of<CalendarBloc>(context);

    return BlocListener<CalendarBloc, CalendarState>(
      listener: (context, state) {
        // Listen to state updates and execute logic here
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kalender'),
          actions: <Widget>[ProfileActionButton()],
        ),
        body: SafeArea(
          child: BlocBuilder<CalendarBloc, CalendarState>(
            builder: (context, state) {
              if (state is CalendarLoading) {
                return const Center(
                  child: const CircularProgressIndicator(),
                );
              } else if (state is CalendarSuccess) {
                if (state.eventsMap.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => calendarBloc.add(LoadCalendar(eventType: EventType.WEEKLY)),
                    child: ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: state.eventsMap.length,
                      itemBuilder: (BuildContext context, int index) {
                        String weekday = state.eventsMap.keys.elementAt(index);
                        List<Event> weekdayEvents = state.eventsMap[weekday]!;

                        return Column(
                          children: <Widget>[
                            const SizedBox(height: 8.0),
                            Text(
                              weekday,
                              style: TextStyle(
                                fontSize: 18.0,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: weekdayEvents.length,
                              itemBuilder: (BuildContext context, int index) {
                                Event event = weekdayEvents[index];

                                return Card(
                                  child: ListTile(
                                    title: Text(event.title),
                                  ),
                                );
                              },
                            )
                          ],
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(
                    // TODO: create generic empty list screen
                    child: const Text("Geen Kalender Items"),
                  );
                }
              } else {
                return const Center(
                  // TODO: create generic fallback error screen
                  child: const Text("Something went wrong!"),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}