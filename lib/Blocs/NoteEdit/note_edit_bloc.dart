import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lw_app/Models/Note/note.dart';
import 'package:lw_app/Services/Note/note_service.dart';

part 'note_edit_event.dart';
part 'note_edit_state.dart';

class NoteEditBloc extends Bloc<NoteEditEvent, NoteEditState> {

  final NoteService _noteService = NoteService();

  NoteEditBloc() : super(NoteEditInitial()) {

    on<InitNote>((event, emit) async {
      emit(NoteLoading());
      try {
        emit(NoteEditInitial());
      } catch (error) {
        emit(NoteError(error.toString()));
      }
    });

    on<LoadNote>((event, emit) async {
      emit(NoteLoading());
      try {
        Note note = await _noteService.getNote(event.noteId);
        emit(NoteSuccess(note: note));
      } catch (error) {
        emit(NoteError(error.toString()));
      }
    });
    
    on<CreateNote>((event, emit) async {
      emit(NoteLoading());
      try {
        Note note = Note(title: event.title, content: event.content);
        Note createdNote = await _noteService.createNote(note: note);
        emit(NoteCreateSuccess(note: createdNote));
      } catch (error) {
        emit(NoteError(error.toString()));
      }
    });

    on<UpdateNote>((event, emit) async {
      try {
        await _noteService.updateNote(noteId: event.note.id, updatedNote: event.note);

        emit(NoteUpdateSuccess());
      } catch (error) {
        emit(NoteError(error.toString()));
      }
    });
  }
}
