import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/Bible/user_verse_interaction.dart';

class BibleInteractionService {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  final SupabaseClient supabase = Supabase.instance.client;

  BibleInteractionService();

  String? get _userId => _auth.currentUser?.id;

  Future<List<UserVerseInteraction>> getInteractionsForChapter({
    required String versionId,
    required String bookId,
    required String chapterNumber,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) return [];

      final response = await supabase
          .from('user_bible_interactions')
          .select('*')
          .eq('user_id', userId)
          .eq('version_id', versionId)
          .eq('book_id', bookId)
          .eq('chapter_number', chapterNumber);

      final List listResponse = response;
      return listResponse
          .map((item) => UserVerseInteraction.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserVerseInteraction> upsertInteraction({
    required String versionId,
    required String bookId,
    required String chapterNumber,
    required String verseNumber,
    String? highlightColor,
    bool? isBookmarked,
    String? note,
    bool clearHighlight = false,
    bool clearNote = false,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('Gebruiker is nie aangemeld nie.');
      }

      final existingResponse = await supabase
          .from('user_bible_interactions')
          .select('*')
          .eq('user_id', userId)
          .eq('version_id', versionId)
          .eq('book_id', bookId)
          .eq('chapter_number', chapterNumber)
          .eq('verse_number', verseNumber)
          .maybeSingle();

      Map<String, dynamic> dataToUpsert = {
        'user_id': userId,
        'version_id': versionId,
        'book_id': bookId,
        'chapter_number': chapterNumber,
        'verse_number': verseNumber,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existingResponse != null) {
        final existing = UserVerseInteraction.fromJson(existingResponse);
        dataToUpsert['id'] = existing.id;
        dataToUpsert['highlight_color'] = clearHighlight ? null : (highlightColor ?? existing.highlightColor);
        dataToUpsert['is_bookmarked'] = isBookmarked ?? existing.isBookmarked;
        dataToUpsert['note'] = clearNote ? null : (note ?? existing.note);
      } else {
        dataToUpsert['highlight_color'] = clearHighlight ? null : highlightColor;
        dataToUpsert['is_bookmarked'] = isBookmarked ?? false;
        dataToUpsert['note'] = clearNote ? null : note;
      }

      final hasHighlight = dataToUpsert['highlight_color'] != null;
      final hasBookmark = dataToUpsert['is_bookmarked'] == true;
      final hasNote = dataToUpsert['note'] != null && (dataToUpsert['note'] as String).trim().isNotEmpty;

      if (!hasHighlight && !hasBookmark && !hasNote && dataToUpsert.containsKey('id')) {
        await supabase
            .from('user_bible_interactions')
            .delete()
            .eq('id', dataToUpsert['id']);
        return UserVerseInteraction(
          userId: userId,
          versionId: versionId,
          bookId: bookId,
          chapterNumber: chapterNumber,
          verseNumber: verseNumber,
        );
      }

      final upsertResponse = await supabase
          .from('user_bible_interactions')
          .upsert(dataToUpsert)
          .select()
          .single();

      return UserVerseInteraction.fromJson(Map<String, dynamic>.from(upsertResponse));
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<UserVerseInteraction>> getSavedVerses() async {
    try {
      final userId = _userId;
      if (userId == null) return [];

      final response = await supabase
          .from('user_bible_interactions')
          .select('*')
          .eq('user_id', userId)
          .or('is_bookmarked.eq.true,highlight_color.not.is.null')
          .order('updated_at', ascending: false);

      final List listResponse = response;
      return listResponse
          .map((item) => UserVerseInteraction.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<UserVerseInteraction>> getVersesWithNotes() async {
    try {
      final userId = _userId;
      if (userId == null) return [];

      final response = await supabase
          .from('user_bible_interactions')
          .select('*')
          .eq('user_id', userId)
          .not('note', 'is', null)
          .neq('note', '')
          .order('updated_at', ascending: false);

      final List listResponse = response;
      return listResponse
          .map((item) => UserVerseInteraction.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }
}
