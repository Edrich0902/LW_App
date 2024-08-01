import 'package:flutter/material.dart';
import 'package:lw_app/Models/LwEvent/lw_event.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  void initState() {
    super.initState();
  }

  final List<LwEvent> upcomingEvents = [
    new LwEvent(
        title: 'Event 1',
        description: 'Event 1 Description Here',
        startDate: '2024-10-10',
        startTime: '19:00'),
    new LwEvent(
        title: 'Event 1',
        description: 'Event 1 Description Here',
        startDate: '2024-10-10',
        startTime: '19:00'),
    new LwEvent(
        title: 'Event 1',
        description: 'Event 1 Description Here',
        startDate: '2024-10-10',
        startTime: '19:00'),
    new LwEvent(
        title: 'Event 1',
        description: 'Event 1 Description Here',
        startDate: '2024-10-10',
        startTime: '19:00'),
    new LwEvent(
        title: 'Event 1',
        description: 'Event 1 Description Here',
        startDate: '2024-10-10',
        startTime: '19:00'),
    new LwEvent(
        title: 'Event 1',
        description: 'Event 1 Description Here',
        startDate: '2024-10-10',
        startTime: '19:00'),
    new LwEvent(
        title: 'Event 1',
        description: 'Event 1 Description Here',
        startDate: '2024-10-10',
        startTime: '19:00'),
    new LwEvent(
        title: 'Event 1',
        description: 'Event 1 Description Here',
        startDate: '2024-10-10',
        startTime: '19:00'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Events'),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: upcomingEvents.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildEventCard(upcomingEvents[index], () { });
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(LwEvent event, VoidCallback onTap) {
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
