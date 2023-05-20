part of 'note_list_bloc.dart';

@immutable
abstract class NoteListEvent extends Equatable {
  const NoteListEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NoteListEvent {
  final String userId;

  const LoadNotes({required this.userId});

  @override
  List<Object?> get props => [userId];
}
