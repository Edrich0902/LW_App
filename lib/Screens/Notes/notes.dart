import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  void initState() {
    //TODO: add block init here
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: add bloc def here

    //TODO: add block listener
    List<Map<String, dynamic>> list = [
      {'title': 'Test Note 1', 'content': 'Testing a note content'},
      {'title': 'Test Note 2', 'content': 'Testing a note content'},
      {'title': 'Test Note 3', 'content': 'Testing a note content'},
      {'title': 'Test Note 4', 'content': 'Testing a note content'},
      {'title': 'Test Note 1', 'content': 'Testing a note content'},
      {'title': 'Test Note 2', 'content': 'Testing a note content'},
      {'title': 'Test Note 3', 'content': 'Testing a note content'},
      {'title': 'Test Note 4', 'content': 'Testing a note content'},
      {'title': 'Test Note 1', 'content': 'Testing a note content'},
      {'title': 'Test Note 2', 'content': 'Testing a note content'},
      {'title': 'Test Note 3', 'content': 'Testing a note content'},
      {'title': 'Test Note 4', 'content': 'Testing a note content'},
      {'title': 'Test Note 1', 'content': 'Testing a note content'},
      {'title': 'Test Note 2', 'content': 'Testing a note content'},
      {'title': 'Test Note 3', 'content': 'Testing a note content'},
      {'title': 'Test Note 4', 'content': 'Testing a note content'},
      {'title': 'Test Note 1', 'content': 'Testing a note content'},
      {'title': 'Test Note 2', 'content': 'Testing a note content'},
      {'title': 'Test Note 3', 'content': 'Testing a note content'},
      {'title': 'Test Note 4', 'content': 'Testing a note content'},
      {'title': 'Test Note 1', 'content': 'Testing a note content'},
      {'title': 'Test Note 2', 'content': 'Testing a note content'},
      {'title': 'Test Note 3', 'content': 'Testing a note content'},
      {'title': 'Test Note 4', 'content': 'Testing a note content'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {/* TODO: implement onPressed to add note */},
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _createNoteCard(list[index]);
          },
        ),
      ),
    );
  }

  Widget _createNoteCard(Map<String, dynamic> note) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.note),
              title: Text(
                note['title'],
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                note['content'],
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  onPressed: () {/* TODO: add onPressed as param */},
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
                IconButton(
                  onPressed: () {/* TODO: add onPressed as param */},
                  icon: Icon(Icons.edit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
