import 'package:flutter/material.dart';

class NotesList extends StatefulWidget {
  const NotesList({super.key});

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: SafeArea(
        child: Center(
          //TODO: add padding around notes list
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _noteItem(theme: theme),
              _noteItem(theme: theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noteItem({
    required ThemeData theme,
    // required Note note,
    GestureTapCallback? onTap,
    GestureTapCallback? onPressed,
  }) {
    return Card(
      //TODO: handle card tap
      child: SizedBox(
        child: Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('My Note'),
                subtitle: Text('Some long note taken by the user...Some long note taken by the user...Some long note taken by the user...Some long note taken by the user'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    onPressed: onPressed,
                    icon: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}