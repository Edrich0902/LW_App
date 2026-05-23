import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/TithesOfferings/tithes_offerings_settings.dart';

class TithesOfferingsService {
  final SupabaseClient supabase = Supabase.instance.client;

  TithesOfferingsService();

  Future<TithesOfferingsSettings?> getSettings() async {
    try {
      final response = await supabase
          .from('tithes_offerings_settings')
          .select('*')
          .maybeSingle();

      if (response == null) return null;
      return TithesOfferingsSettings.fromJson(Map<String, dynamic>.from(response));
    } catch (error) {
      throw error.toString();
    }
  }
}
