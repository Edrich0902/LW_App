import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/Event/event.dart';

class EventService {
  final SupabaseClient supabase = Supabase.instance.client;

  EventService();

  Future<List<Event>> getEvents({String? type, String? category, DateTime? date}) async {
    try {
      var queryBuilder = supabase.from('events').select('*');

      if (type != null) {
        queryBuilder = queryBuilder.eq('type', type);
      }
      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category);
      }
      if (date != null) {
        queryBuilder = queryBuilder.gte('start_date', date);
      }

      final response = await queryBuilder;

      List<dynamic> listResponse = response;
      List<Event> data = listResponse
        .map((item) => Event.fromJson(Map<String, dynamic>.from(item)))
        .toList();

      return Future.value(data);
    } catch (error) {
      throw error.toString();
    }
  }

  /// Fetches upcoming ONCE-type events merged with RSVP counts and the
  /// current user's RSVP status. Uses three parallel queries and merges
  /// the results client-side.
  Future<List<Event>> getUpcomingEventsWithRsvp({DateTime? date}) async {
    try {
      final userId = supabase.auth.currentUser?.id;

      var eventsQuery = supabase
          .from('events')
          .select('*')
          .eq('type', 'once');

      if (date != null) {
        eventsQuery = eventsQuery.gte('start_date', date.toIso8601String().split('T').first);
      }

      final results = await Future.wait([
        eventsQuery.order('start_date', ascending: true),
        supabase.from('event_rsvp_summary').select('*'),
        if (userId != null)
          supabase
              .from('event_rsvps')
              .select('event_id, status')
              .eq('user_id', userId)
        else
          Future.value(<dynamic>[]),
      ]);

      final events = List<Map<String, dynamic>>.from(results[0]);
      final summaries = List<Map<String, dynamic>>.from(results[1]);
      final userRsvps = List<Map<String, dynamic>>.from(results[2]);

      // Index by event_id for O(1) lookups
      final summaryMap = {
        for (final s in summaries) s['event_id'].toString(): s,
      };
      final userRsvpMap = {
        for (final r in userRsvps) r['event_id'].toString(): r['status'].toString(),
      };

      return events.map((item) {
        final id = item['id'].toString();
        final summary = summaryMap[id];
        return Event.fromJson({
          ...item,
          'attending_count': summary?['attending_count'] ?? 0,
          'interested_count': summary?['interested_count'] ?? 0,
          'not_attending_count': summary?['not_attending_count'] ?? 0,
          'user_rsvp_status': userRsvpMap[id],
        });
      }).toList();
    } catch (error) {
      throw error.toString();
    }
  }
}
