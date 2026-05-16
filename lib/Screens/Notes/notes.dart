import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lw_app/Blocs/Notes/notes_bloc.dart';
import 'package:lw_app/Widgets/LwpSnackbar/lwp_snackbar.dart';
import 'package:lw_app/Models/Note/note.dart';
import 'package:lw_app/Screens/NotesEdit/notes_edit.dart';
import 'package:lw_app/Widgets/LwpError/lwp_error.dart';
import 'package:lw_app/Widgets/LwpLoader/lwp_loader.dart';
import 'package:lw_app/Widgets/LwpEmpty/lwp_empty.dart';

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
          LwpSnackbar.showSuccess(context, "Nota verwyder");
        }

        if (state is NotesError) {
          LwpSnackbar.showError(context, "Iets het fout gegaan");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notas'),
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
                if (state.data.isEmpty) {
                  return const LwpEmpty(message: 'Geen notas gevind nie');
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: state.data.length,
                  itemBuilder: (context, index) {
                    final note = state.data.elementAt(index);
                    return _createNoteCard(
                      note,
                      () {
                        notesBloc.add(
                          DeleteNote(noteId: note.id ?? ''),
                        );
                      },
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotesEditPage(
                              noteId: note.id ?? '',
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
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: edit,
        borderRadius: BorderRadius.circular(24.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.note_alt_outlined, color: theme.primaryColor),
                ),
                title: Text(
                  note.title ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  note.content ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: IconButton(
                  onPressed: () {
                    confirmationDialog(
                      context,
                      'Is jy seker jy wil hierdie nota verwyder?',
                      delete,
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmationDialog(
      BuildContext context, String message, VoidCallback confirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verwyder Nota'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('Kanselleer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                confirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Bevestig'),
            ),
          ],
        );
      },
    );
  }
}
