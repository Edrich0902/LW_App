import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Blocs/NoteEdit/note_edit_bloc.dart';
import 'package:lw_app/Blocs/Notes/notes_bloc.dart';
import 'package:lw_app/Models/Note/note.dart';
import 'package:lw_app/Utils/snackbar.dart';

class NotesEditPage extends StatefulWidget {
  final String? noteId;

  const NotesEditPage({super.key, this.noteId});

  @override
  State<NotesEditPage> createState() => _NotesEditPageState();
}

class _NotesEditPageState extends State<NotesEditPage> {
  bool isEdit = false;

  final _noteFormKey = GlobalKey<FormState>();
  late final TextEditingController _titleController = TextEditingController(text: '');
  late final TextEditingController _contentController = TextEditingController(text: '');

  @override
  void initState() {
    if (widget.noteId != null && widget.noteId != "") {
      isEdit = true;
      context.read<NoteEditBloc>().add(LoadNote(widget.noteId ?? ''));
    } else {
      isEdit = false;
      context.read<NoteEditBloc>().add(InitNote());
    }

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void initForm({Note note = const Note()}) {
    _titleController.text = note.title ?? '';
    _contentController.text = note.content ?? '';
  }

  @override
  Widget build(BuildContext context) {
    NoteEditBloc noteEditBloc = BlocProvider.of<NoteEditBloc>(context);
    NotesBloc notesBloc = BlocProvider.of<NotesBloc>(context);

    return BlocListener<NoteEditBloc, NoteEditState>(
      listener: (context, state) {
        if (state is NoteCreateSuccess) {
          SnackBarHelper.showSuccessSnack(context, 'Note Created');
          notesBloc.add(LoadNotes());
          Navigator.of(context).pop(); // go to previous screen
        }

        if (state is NoteUpdateSuccess) {
          SnackBarHelper.showSuccessSnack(context, 'Note Updated');
          notesBloc.add(LoadNotes());
          Navigator.of(context).pop(); // go to previous screen
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Edit Note' : 'Create Note'),
        ),
        body: SafeArea(
          child: BlocBuilder<NoteEditBloc, NoteEditState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              if (state is NoteLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is NoteSuccess) {
                initForm(note: state.note);
                return _noteForm(noteEditBloc: noteEditBloc, note: state.note);
              } else if (state is NoteEditInitial) {
                initForm();
                return _noteForm(noteEditBloc: noteEditBloc);
              } else {
                return Center(
                  child: Text('Something went wrong!'),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _noteForm({required NoteEditBloc noteEditBloc, Note? note}) {
    Note updatedNote;

    return SingleChildScrollView(
      child: Form(
        key: _noteFormKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                validator: (title) {
                  if (title == null || title.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                validator: (content) {
                  if (content == null || content.isEmpty) {
                    return 'Content is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Content',
                ),
                maxLines: 20,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => {
                  if (_noteFormKey.currentState!.validate()) {
                    if (isEdit && note != null) {
                      updatedNote = new Note(
                        id: note.id,
                        user_id: note.user_id,
                        title: _titleController.text,
                        content: _contentController.text,
                        createdAt: note.createdAt,
                      ),

                      noteEditBloc.add(
                          UpdateNote(note: updatedNote)
                      )
                    } else {
                      noteEditBloc.add(
                          CreateNote(
                            _titleController.text,
                            _contentController.text,
                          )
                      )
                    }
                  }
                },
                child: Text(isEdit ? 'Update Note' : 'Save Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
