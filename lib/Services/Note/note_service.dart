import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/Note/note.dart';

class NoteService {
  final SupabaseClient supabase = Supabase.instance.client;

  NoteService();

  Future<List<Note>> getUserNotes({required String userId}) async {
    try {
      final List<dynamic> response =
          await supabase.from('notes').select('*').eq('user_id', userId);

      List<Note> notes = response.map<Note>((json) {
        return Note.fromJson(Map<String, dynamic>.from(json));
      }).toList();

      return Future.value(notes);
    } catch (error) {
      throw error.toString();
    }
  }
}