import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Notes/notes_bloc.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:lw_app/Models/Note/note.dart';
import 'package:lw_app/Screens/NotesEdit/notes_edit.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';

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
          AnimatedSnackBar.material(
              "Note Deleted",
              type: AnimatedSnackBarType.success,
              mobileSnackBarPosition: MobileSnackBarPosition.bottom
          ).show(context);
        }

        if (state is NotesError) {
          AnimatedSnackBar.material(
              "Something went wrong",
              type: AnimatedSnackBarType.error,
              mobileSnackBarPosition: MobileSnackBarPosition.bottom
          ).show(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotesEditPage(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NotesLoading) {
                return const LwpLoader();
              } else if (state is NotesSuccess) {
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
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
                return const LwpError();
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
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.note),
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
                    icon: const Icon(Icons.delete, color: Colors.red),
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
      child: const Text('Cancel'),
    );

    Widget confirmButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        confirm();
      },
      child: const Text('Confirm'),
    );

    AlertDialog dialog = AlertDialog(
      title: const Text('Delete Note'),
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
