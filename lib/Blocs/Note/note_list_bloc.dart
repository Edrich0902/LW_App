import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Note/note.dart';

part 'note_list_event.dart';
part 'note_list_state.dart';

class NoteListBloc extends Bloc<NoteListEvent, NoteListState> {
  //TODO: add note service
  NoteListBloc() : super(NoteListInitial()) {
    on<LoadNotes>((event, emit) {
      emit(NoteListLoading());
      try {
        //TODO: implement service call
        // emit(NoteListSuccess(notes: notes));
      } catch (error) {
        emit(NoteListError(error.toString()));
      }
    });
  }
}
