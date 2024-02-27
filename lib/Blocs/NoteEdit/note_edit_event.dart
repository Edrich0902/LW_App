part of 'note_edit_bloc.dart';

abstract class NoteEditEvent extends Equatable {
  const NoteEditEvent();

  @override
  List<Object> get props => [];
}

class InitNote extends NoteEditEvent {
  const InitNote();

  @override
  List<Object> get props => [];
}

class LoadNote extends NoteEditEvent {
  final String noteId;

  const LoadNote(this.noteId);

  @override
  List<Object> get props => [noteId];
}

class UpdateNote extends NoteEditEvent {
  final Note note;

  const UpdateNote({required this.note});

  @override
  List<Object> get props => [note];
}

class CreateNote extends NoteEditEvent {
  final String title;
  final String content;

  const CreateNote(this.title, this.content);

  @override
  List<Object> get props => [title, content];
}
