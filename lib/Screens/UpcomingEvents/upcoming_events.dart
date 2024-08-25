import 'package:flutter/material.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Widgets/ProfileActionButton/profile_action_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Utils/snackbar.dart';
import 'package:lw_app/Blocs/Events/events_bloc.dart';
import 'package:lw_app/Models/Event/event_type.dart';

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
          title: Text('Opkomende Gebeure'),
          actions: <Widget>[ProfileActionButton()],
        ),
        body: SafeArea(
          child: BlocBuilder<EventsBloc, EventsState>(
            builder: (context, state) {
              if (state is EventsLoading) {
                return const Center(
                  child: const CircularProgressIndicator(),
                );
              } else if (state is EventsSuccess) {
                if (state.events.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => eventsBloc.add(LoadEvents(eventType: EventType.ONCE)),
                    child: ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: state.events.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildEventCard(state.events[index], () {
                          // TODO: open event detail here - create event detail screen
                        });
                      },
                    ),
                  );
                } else {
                  return const Center(
                    // TODO: create generic empty list screen
                    child: const Text("Geen Opkomende Gebeure"),
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

  // TODO: update event card to show more info
  Widget _buildEventCard(Event event, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: Icon(Icons.event),
            title: Text(
              event.title,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              event.description,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
          ),
        ),
      ),
    );
  }
}
