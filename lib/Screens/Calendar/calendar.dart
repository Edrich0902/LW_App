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
          centerTitle: false,
        ),
        body: SafeArea(
          child: BlocBuilder<CalendarBloc, CalendarState>(
            builder: (context, state) {
              if (state is CalendarLoading) {
                return const LwpLoader(message: "Laai Kalender");
              } else if (state is CalendarSuccess) {
                if (state.eventsMap.isNotEmpty) {
                  // Flatten the map into a list of items for the timeline
                  final List<dynamic> timelineItems = [];
                  state.eventsMap.forEach((day, events) {
                    timelineItems.add(day);
                    timelineItems.addAll(events);
                  });

                  return RefreshIndicator(
                    onRefresh: () async => calendarBloc.add(LoadCalendar(eventType: EventType.WEEKLY, eventCategory: EventCategory.GENERAL)),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      itemCount: timelineItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = timelineItems[index];
                        final bool isLast = index == timelineItems.length - 1;
                        final bool isDayHeader = item is String;
                        final bool isFirst = index == 0;

                        return Stack(
                          children: [
                            // 1. Vertical Line (drawn first so it's behind the dot)
                            Positioned(
                              left: 5, // Center of the 12px dot area
                              top: isDayHeader && isFirst ? 10 : 0,
                              bottom: 0,
                              child: Visibility(
                                visible: !isLast,
                                child: Container(
                                  width: 2,
                                  color: theme.primaryColor.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                            
                            // 2. Content with padding to make room for the line
                            Padding(
                              padding: const EdgeInsets.only(left: 28.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isDayHeader) ...[
                                    Text(
                                      item.toUpperCase(),
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ] else ...[
                                    LwpEvent(event: item as Event),
                                    const SizedBox(height: 16),
                                  ],
                                ],
                              ),
                            ),

                            // 3. The Day Dot (drawn last so it's on top)
                            if (isDayHeader)
                              Positioned(
                                left: 0,
                                top: 4,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.primaryColor.withValues(alpha: 0.2),
                                      width: 4,
                                    ),
                                  ),
                                ),
                              ),
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