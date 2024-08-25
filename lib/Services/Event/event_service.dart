import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/Event/event.dart';

class EventService {
  final SupabaseClient supabase = Supabase.instance.client;

  EventService();

  Future<List<Event>> getEvents({String? type}) async {
    try {
      var queryBuilder = supabase.from('events').select('*');

      if (type != null) queryBuilder.eq('type', type);

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
}