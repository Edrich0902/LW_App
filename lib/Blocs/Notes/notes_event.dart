part of 'notes_bloc.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class LoadNotes extends NotesEvent {
  const LoadNotes();

  @override
  List<Object> get props => [];
}

class CreateNote extends NotesEvent {
  final String title;
  final String content;

  const CreateNote(this.title, this.content);

  @override
  List<Object> get props => [title, content];
}

class UpdateNote extends NotesEvent {
  final Note note;

  const UpdateNote({required this.note});

  @override
  List<Object> get props => [note];
}

class DeleteNote extends NotesEvent {
  final String noteId;

  const DeleteNote({required this.noteId});

  @override
  List<Object> get props => [noteId];
}