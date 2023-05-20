part of 'note_list_bloc.dart';

@immutable
abstract class NoteListState extends Equatable {
  const NoteListState();
}

class NoteListInitial extends NoteListState {
  @override
  List<Object> get props => [];
}

class NoteListLoading extends NoteListState {
  @override
  List<Object> get props => [];
}

class NoteListSuccess extends NoteListState {
  final List<Note> notes;

  const NoteListSuccess({required this.notes});

  @override
  List<Object?> get props => [notes];
}

class NoteListError extends NoteListState {
  final String error;

  const NoteListError(this.error);

  @override
  List<Object> get props => [error];
}
