import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/Sermon/sermon.dart';

class SermonService {
  final SupabaseClient supabase = Supabase.instance.client;

  SermonService();

  Future<List<Sermon>> getSermons() async {
    try {
      final response = await supabase.from('sermons').select('*').order('created_at'); // Ensure latest sermons load at top

      List<dynamic> listResponse = response;
      List<Sermon> data = listResponse
          .map((item) => Sermon.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      return Future.value(data);
    } catch (error) {
      throw error.toString();
    }
  }
}