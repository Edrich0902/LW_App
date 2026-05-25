import 'package:lw_app/Models/Event/rsvp_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventRsvpService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _currentUserId {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw 'Jy moet ingeteken wees om te RSVP.';
    return userId;
  }

  Future<void> upsertRsvp({
    required String eventId,
    required RsvpStatus status,
  }) async {
    try {
      final userId = _currentUserId;
      await _supabase.from('event_rsvps').upsert(
        {
          'event_id': eventId,
          'user_id': userId,
          'status': status.value,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'event_id,user_id',
      );
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> deleteRsvp({required String eventId}) async {
    try {
      final userId = _currentUserId;
      await _supabase
          .from('event_rsvps')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', userId);
    } catch (error) {
      throw error.toString();
    }
  }
}
