import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Utils/environment.dart';

class AuthService {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  final SupabaseClient supabase = Supabase.instance.client;

  AuthService();

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await _auth.signUp(
        password: password, 
        email: email, 
        data: data,
        emailRedirectTo: '${Environment.authCallbackUrl}/auth/callback',
      );
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithPassword(password: password, email: email);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> createInitialProfile({
    required String? userId,
    required String firstName,
    required String lastName,
    String? profileUrl,
    String? profilePublicId,
  }) async {
    try {
      await supabase.from("user_profile").insert({
        'id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'profile_url': profileUrl,
        'profile_public_id': profilePublicId,
      });
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.resetPasswordForEmail(email, redirectTo: '${Environment.authCallbackUrl}/auth/reset-password');
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } catch (error) {
      throw error.toString();
    }
  }
}
