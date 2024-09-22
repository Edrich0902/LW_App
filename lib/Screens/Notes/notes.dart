import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Notes/notes_bloc.dart';
import 'package:lw_app/Utils/snackbar.dart';
import 'package:lw_app/Models/Note/note.dart';
import 'package:lw_app/Screens/NotesEdit/notes_edit.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  void initState() {
    context.read<NotesBloc>().add(const LoadNotes());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NotesBloc notesBloc = BlocProvider.of<NotesBloc>(context);

    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NotesDeleteSuccess) {
          SnackBarHelper.showSuccessSnack(context, 'Note Deleted');
        }

        if (state is NotesError) {
          SnackBarHelper.showErrorSnack(context, 'Something went wrong.');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notes'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotesEditPage(),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
        body: SafeArea(
          child: BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NotesLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is NotesSuccess) {
                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: state.data.length,
                  itemBuilder: (context, index) {
                    return _createNoteCard(
                      state.data.elementAt(index),
                      () {
                        notesBloc.add(
                          DeleteNote(
                              noteId: state.data.elementAt(index).id ?? ''),
                        );
                      },
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotesEditPage(
                              noteId: state.data.elementAt(index).id ?? '',
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('Something went wrong.'),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _createNoteCard(Note note, VoidCallback delete, VoidCallback edit) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: edit,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.note),
                title: Text(
                  note.title ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
                subtitle: Text(
                  note.content ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      confirmationDialog(
                        context,
                        'Are you sure you want to delete this note?',
                        delete,
                      );
                    },
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TODO: extract and make generic and reusable
  void confirmationDialog(
      BuildContext context, String message, VoidCallback confirm) {
    Widget cancelButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      child: Text('Cancel'),
    );

    Widget confirmButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        confirm();
      },
      child: Text('Confirm'),
    );

    AlertDialog dialog = AlertDialog(
      title: Text('Delete Note'),
      content: Text(message),
      actions: [cancelButton, confirmButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }
}
