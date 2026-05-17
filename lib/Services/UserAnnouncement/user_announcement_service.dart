import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lw_app/Models/UserAnnouncement/user_announcement.dart';

class UserAnnouncementService {
  final SupabaseClient supabase = Supabase.instance.client;
  final GoTrueClient _auth = Supabase.instance.client.auth;

  UserAnnouncementService();

  Future<List<UserAnnouncement>> getUserAnnouncements() async {
    try {
      final response = await supabase
          .from('user_announcements')
          .select('id, is_read, announcements (title, body, image_url, image_public_id, created_at, updated_at)')
          .eq('user_id', _auth.currentUser!.id)
          .eq('is_read', false);

      List<dynamic> listResponse = response;
      List<UserAnnouncement> data = listResponse
          .map((item) => UserAnnouncement.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      return Future.value(data);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> markUserNotificationsAsRead() async {
    try {
      await supabase
        .from('user_announcements')
        .update({'is_read': true})
        .eq('user_id', _auth.currentUser!.id);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> markUserNotificationAsRead(String id) async {
    try {
      await supabase
          .from('user_announcements')
          .update({'is_read': true})
          .eq('id', id)
          .eq('user_id', _auth.currentUser!.id);
    } catch (error) {
      throw error.toString();
    }
  }
}