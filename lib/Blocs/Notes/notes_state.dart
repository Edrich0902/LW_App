part of 'notes_bloc.dart';

abstract class NotesState extends Equatable {
  const NotesState();
}

class NotesInitial extends NotesState {
  @override
  List<Object> get props => [];
}

class NotesLoading extends NotesState {
  @override
  List<Object> get props => [];
}

class NotesSuccess extends NotesState {
  final List<Note> data;

  const NotesSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class NotesDelete extends NotesState {
  final String noteId;

  const NotesDelete({required this.noteId});

  @override
  List<Object?> get props => [noteId];
}

class NotesDeleteSuccess extends NotesState {
  @override
  List<Object?> get props => [];
}

class NotesError extends NotesState {
  final String error;

  const NotesError(this.error);

  @override
  List<Object> get props => [error];
}