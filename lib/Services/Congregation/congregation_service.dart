import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/Congregation/congregation.dart';

class CongregationService {
  final SupabaseClient supabase = Supabase.instance.client;

  CongregationService();

  Future<List<Congregation>> getCongregations() async {
    try {
      final List<dynamic> response =
          await supabase.rpc('get_congregations_with_favourites', params: {
            'current_user_id': supabase.auth.currentUser?.id
          });

      List<Congregation> congregations = response.map<Congregation>((json) {
        return Congregation.fromJson(Map<String, dynamic>.from(json));
      }).toList();

      return Future.value(congregations);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> favouriteCongregation({
    required String congregationId,
    required String userId,
  }) async {
    try {
      await supabase.from('user_congregations').insert({
        'user_id': userId,
        'congregation_id': congregationId,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> unFavouriteCongregation({
    required String congregationId,
    required String userId,
  }) async {
    try {
      await supabase.from('user_congregations').delete()
          .eq('user_id', userId).eq('congregation_id', congregationId);
    } catch (error) {
      throw error.toString();
    }
  }
}
