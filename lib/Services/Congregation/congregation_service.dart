import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/Congregation/congregation.dart';

class CongregationService {
  final SupabaseClient supabase = Supabase.instance.client;

  CongregationService();

  Future<List<Congregation>> getCongregations() async {
    try {
      final List<dynamic> response = await supabase
          .from('congregations')
          .select('*');

      List<Congregation> congregations = response.map<Congregation>((json) {
        return Congregation.fromJson(Map<String, dynamic>.from(json));
      }).toList();

      return Future.value(congregations);
    } catch (error) {
      throw error.toString();
    }
  }
}