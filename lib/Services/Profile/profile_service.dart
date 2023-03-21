import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  ProfileService();

  Future<User> updateUser({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final UserResponse response = await _auth.updateUser(
        UserAttributes(data: {
          'firstName': firstName,
          'lastName': lastName,
        }),
      );

      Future<User> user = Future.value(response.user);
      return user;
    } catch (error) {
      throw error.toString();
    }
  }

  User? getUser() {
    try {
      return _auth.currentUser;
    } catch (error) {
      throw error.toString();
    }
  }
}
