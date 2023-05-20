import 'package:flutter/material.dart';

class AddNote extends StatefulWidget {
  final String? noteId;
  final String? userId;

  const AddNote({
    super.key,
    required this.userId,
    this.noteId,
  });

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  //TODO: get user passed from other screen

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
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'Add Note' : 'Edit Note'),
      ),
      body: SafeArea(
        child: Center(
          child: Text("Add note here..."),
        ),
      ),
    );
  }
}