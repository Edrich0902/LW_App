import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/Note/note.dart';

class NoteService {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  final SupabaseClient supabase = Supabase.instance.client;

  NoteService();

  Future<List<Note>> getUserNotes() async {
    try {
      if (_auth.currentUser == null) return Future.value([]);
      final response = await supabase
          .from('notes')
          .select('*')
          .eq('user_id', _auth.currentUser!.id)
          .order('updated_at', ascending: false);

      // TODO: make response handler for list responses
      List<dynamic> listResponse = response;
      List<Note> data = listResponse
          .map((item) => Note.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      return Future.value(data);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<Note> getNote(String noteId) async {
    try {
      final response = await supabase
          .from('notes')
          .select('*')
          .eq('id', noteId)
          .single();

      Note note = Note.fromJson(Map<String, dynamic>.from(response));
      return Future.value(note);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<Note> createNote({
    required Note note
  }) async {
    try {
      final response = await supabase.from('notes').insert({
        'user_id': _auth.currentUser?.id,
        'title': note.title,
        'content': note.content,
      }).select().single();
      return Note.fromJson(Map<String, dynamic>.from(response));
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> updateNote({
    required String? noteId,
    required Note updatedNote
  }) async {
    try {
      await supabase.from('notes').update({
        'title': updatedNote.title,
        'content': updatedNote.content,
      }).eq('id', noteId!);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> deleteNote({
    required String noteId
  }) async {
    try {
      await supabase.from('notes').delete().match({
        'id': noteId
      });
    } catch (error) {
      throw error.toString();
    }
  }
}
