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

class DeleteNote extends NotesEvent {
  final String noteId;

  const DeleteNote({required this.noteId});

  @override
  List<Object> get props => [noteId];
}