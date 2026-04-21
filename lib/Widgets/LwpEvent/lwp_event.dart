import 'package:flutter/material.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';

class LwpEvent extends StatefulWidget {
  const LwpEvent({
    super.key,
    required this.event,
  });

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
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        children: <Widget>[
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200, // Placeholder size
                color: Colors.grey[300], // Placeholder color
              ),
              CldImageWidget(
                publicId: widget.event.bannerPublicId ?? 'samples/cloudinary-icon',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        widget.event.title,
                        style: theme.textTheme.titleLarge
                    ),
                    Text(
                        DateFormatter.formatTime(widget.event.time),
                        style: theme.textTheme.titleLarge
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                        'Lees Meer',
                        style: theme.textTheme.titleMedium
                    ),
                    childrenPadding: const EdgeInsets.all(16.0),
                    tilePadding: const EdgeInsets.all(0.0),
                    expandedAlignment: Alignment.centerLeft,
                    children: <Widget>[
                      Text(
                          widget.event.description,
                          style: theme.textTheme.bodyMedium
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}