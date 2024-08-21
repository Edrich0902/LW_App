import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/Roleplayer/roleplayer.dart';

class RoleplayerService {
  final SupabaseClient supabase = Supabase.instance.client;

  RoleplayerService();

  Future<List<Roleplayer>> getRolePlayers() async {
    try {
      final response = await supabase.from('roleplayers').select('*');

      List<dynamic> listResponse = response;
      List<Roleplayer> data = listResponse
          .map((item) => Roleplayer.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      return Future.value(data);
    } catch (error) {
      throw error.toString();
    }
  }
}