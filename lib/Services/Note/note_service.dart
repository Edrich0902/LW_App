import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/Note/note.dart';

class NoteService {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  final SupabaseClient supabase = Supabase.instance.client;

  NoteService();

  Future<List<Note>> getUserNotes() async {
    try {
      final response = await supabase
          .from('notes')
          .select('*')
          .eq('user_id', _auth.currentUser?.id);

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

  Future<void> createNote({
    required Note note
  }) async {
    try {
      await supabase.from('notes').insert({
        'user_id': _auth.currentUser?.id,
        'title': note.title,
        'content': note.content,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> updateNote({
    required String noteId,
    required Note updatedNote
  }) async {
    try {
      await supabase.from('notes').update({
        'title': updatedNote.title,
        'content': updatedNote.content,
      }).eq('id', noteId);
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
