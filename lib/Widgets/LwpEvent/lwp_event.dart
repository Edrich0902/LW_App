import 'package:flutter/material.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Utils/date_formatter.dart';

class LwpEvent extends StatefulWidget {
  const LwpEvent({
    Key? key,
    required this.event,
  }) : super(key: key);

  final Event event;

  @override
  State<LwpEvent> createState() => _LwpEventState();
}

class _LwpEventState extends State<LwpEvent> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.event.title,
                  style: TextStyle(
                    fontSize: 14.0,
                    letterSpacing: 2.0
                  ),
                ),
                Text(
                  DateFormatter.formatTime(widget.event.time),
                  style: TextStyle(
                    fontSize: 14.0,
                    letterSpacing: 2.0
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  'Lees Meer',
                  style: TextStyle(
                    fontSize: 14.0,
                    letterSpacing: 2.0
                  ),
                ),
                childrenPadding: EdgeInsets.all(16.0),
                tilePadding: EdgeInsets.all(0.0),
                expandedAlignment: Alignment.centerLeft,
                children: <Widget>[
                  Text(
                    widget.event.description,
                    style: TextStyle(
                        fontSize: 12.0,
                        letterSpacing: 2.0
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}