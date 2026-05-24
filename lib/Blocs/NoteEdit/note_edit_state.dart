part of 'note_edit_bloc.dart';

abstract class NoteEditState extends Equatable {
  const NoteEditState();
}

class NoteEditInitial extends NoteEditState {
  @override
  List<Object> get props => [];
}

class NoteLoading extends NoteEditState {
  @override
  List<Object> get props => [];
}

class NoteSuccess extends NoteEditState {
  final Note note;

  const NoteSuccess({required this.note});

  @override
  List<Object?> get props => [note];
}

class NoteUpdate extends NoteEditState {
  final Note note;

  const NoteUpdate({required this.note});

  @override
  List<Object?> get props => [note];
}

class NoteUpdateSuccess extends NoteEditState {
  NoteUpdateSuccess() : _at = DateTime.now();
  final DateTime _at;

  @override
  List<Object?> get props => [_at];
}

class NoteCreate extends NoteEditState {
  final Note note;

  const NoteCreate({required this.note});

  @override
  List<Object?> get props => [note];
}

class NoteCreateSuccess extends NoteEditState {
  final Note note;

  const NoteCreateSuccess({required this.note});

  @override
  List<Object?> get props => [note];
}

class NoteError extends NoteEditState {
  final String error;

  const NoteError(this.error);

  @override
  List<Object> get props => [error];
}