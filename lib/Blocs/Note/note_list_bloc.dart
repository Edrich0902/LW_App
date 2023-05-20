import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Note/note.dart';
import 'package:lw_app/Services/Note/note_service.dart';

part 'note_list_event.dart';
part 'note_list_state.dart';

class NoteListBloc extends Bloc<NoteListEvent, NoteListState> {
  final NoteService _noteService = NoteService();
  NoteListBloc() : super(NoteListInitial()) {
    on<LoadNotes>((event, emit) async {
      emit(NoteListLoading());
      try {
        List<Note> notes = await _noteService.getUserNotes(userId: event.userId);
        emit(NoteListSuccess(notes: notes));
      } catch (error) {
        emit(NoteListError(error.toString()));
      }
    });
  }
}
