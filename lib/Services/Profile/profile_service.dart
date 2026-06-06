import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/User/user_profile.dart';

class ProfileService {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  final SupabaseClient supabase = Supabase.instance.client;

  ProfileService();

  Future<void> updateUser(
      {required String firstName,
      required String lastName,
      String? address,
      bool? isMember,
      bool? isBaptized}) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;
      await supabase.from('user_profile').update({
        'first_name': firstName,
        'last_name': lastName,
        'address': address,
        'is_member': isMember,
        'is_baptized': isBaptized,
      }).eq('id', currentUser.id);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> updateUserProfileImage(
      {required String profilePublicId, required String profileUrl}) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;
      await supabase.from('user_profile').update({
        'profile_public_id': profilePublicId,
        'profile_url': profileUrl
      }).eq('id', currentUser.id);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> updatePreferredLanguage({required String languageCode}) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;
      await supabase.from('user_profile').update({
        'preferred_language': languageCode,
      }).eq('id', currentUser.id);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<UserProfile> getUserProfile() async {
    try {
      final User? currentUser = _auth.currentUser;
      final response = await supabase
          .from('user_profile_view')
          .select('*')
          .eq('id', currentUser!.id)
          .single();

      UserProfile user =
          UserProfile.fromJson(Map<String, dynamic>.from(response));
      return Future.value(user);
    } catch (error) {
      throw error.toString();
    }
  }
}
