import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/SocialMedia/social_media.dart';

class SocialMediaService {
  final SupabaseClient supabase = Supabase.instance.client;

  SocialMediaService();

  Future<List<SocialMedia>> getSocialMedia() async {
    try {
      final response = await supabase.from('social_media').select('*');

      List<dynamic> listResponse = response;
      List<SocialMedia> data = listResponse
        .map((item) => SocialMedia.fromJson(Map<String, dynamic>.from(item)))
        .toList();

      return Future.value(data);
    } catch (error) {
      throw error.toString();
    }
  }
}