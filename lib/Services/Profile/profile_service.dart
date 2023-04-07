import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/User/user_profile.dart';
import 'dart:convert';

class ProfileService {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  final SupabaseClient supabase = Supabase.instance.client;

  ProfileService();

  Future<void> updateUser({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      await supabase.from('user_profile').update({
        'first_name': firstName,
        'last_name': lastName,
      }).eq('id', currentUser?.id);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<UserProfile> getUserProfile() async {
    try {
      final User? currentUser = _auth.currentUser;
      final response = await supabase
          .from('user_profile')
          .select('*')
          .eq('id', currentUser?.id)
          .single();

      UserProfile user =
          UserProfile.fromJson(Map<String, dynamic>.from(response));
      return Future.value(user);
    } catch (error) {
      throw error.toString();
    }
  }
}
