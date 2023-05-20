import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Blocs/Note/note_list_bloc.dart';
import 'package:lw_app/Models/Note/note.dart';
import 'package:lw_app/Screens/AddNote/add_note.dart';

class NotesList extends StatefulWidget {
  const NotesList({super.key});

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  User? user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    context.read<NoteListBloc>().add(LoadNotes(userId: user?.id ?? ''));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    NoteListBloc noteListBloc =
        BlocProvider.of<NoteListBloc>(context);

    return BlocListener<NoteListBloc, NoteListState>(
      listener: (context, state) {
        //TODO: handle state here
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Notes')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return AddNote(
                    userId: user?.id,
                  );
                },
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: Center(
            child: BlocBuilder<NoteListBloc, NoteListState>(
              builder: (context, state) {
                if (state is NoteListError) {
                  return Text('Could not load Notes');
                }

                if (state is NoteListLoading) {
                  return const CircularProgressIndicator();
                }

                if (state is NoteListSuccess) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: state.notes.length,
                      prototypeItem: _noteItem(
                          theme: theme,
                          note: state.notes.first
                      ),
                      itemBuilder: (context, index) {
                        return _noteItem(
                          theme: theme,
                          note: state.notes[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return AddNote(
                                    noteId: state.notes[index].id,
                                    userId: user?.id,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return Text('Something went wrong.');
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _noteItem({
    required ThemeData theme,
    required Note note,
    GestureTapCallback? onTap,
    GestureTapCallback? onPressed,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          child: Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text(note?.title ?? 'No Title'),
                  subtitle: Text(note?.note ?? 'No Content'),
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
      ),
    );
  }
}