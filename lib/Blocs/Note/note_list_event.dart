part of 'note_list_bloc.dart';

@immutable
abstract class NoteListEvent extends Equatable {
  const NoteListEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NoteListEvent {
  const LoadNotes();

  @override
  List<Object?> get props => [];
}
