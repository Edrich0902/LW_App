import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Note/note.dart';
import 'package:lw_app/Services/Note/note_service.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteService _noteService = NoteService();
  NotesBloc() : super(NotesInitial()) {
    on<LoadNotes>((event, emit) async {
      emit(NotesLoading());
      try {
        List<Note> notes = await _noteService.getUserNotes();
        emit(NotesSuccess(data: notes));
      } catch (error) {
        emit(NotesError(error.toString()));
      }
    });

    on<CreateNote>((event, emit) async {
      try {
        Note note = new Note(title: event.title, content: event.content);
        await _noteService.createNote(note: note);

        add(const LoadNotes());
        emit(NotesCreateSuccess());
      } catch (error) {
        emit(NotesError(error.toString()));
      }
    });

    on<UpdateNote>((event, emit) async {
      try {
        await _noteService.updateNote(noteId: event.note.id, updatedNote: event.note);

        add(const LoadNotes());
        emit(NotesUpdateSuccess());
      } catch (error) {
        emit(NotesError(error.toString()));
      }
    });

    on<DeleteNote>((event, emit) async {
      try {
        await _noteService.deleteNote(noteId: event.noteId);

        add(const LoadNotes());
        emit(NotesDeleteSuccess());
      } catch (error) {
        emit(NotesError(error.toString()));
      }
    });
  }
}
