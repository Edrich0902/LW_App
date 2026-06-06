import 'package:lw_app/Models/AppFeedback/app_feedback.dart';
import 'package:lw_app/Utils/lwp_i18n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppFeedbackService {
  final SupabaseClient supabase = Supabase.instance.client;
  final GoTrueClient _auth = Supabase.instance.client.auth;

  Future<List<AppFeedback>> getMyFeedback() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final response = await supabase
          .from('app_feedback_owner_view')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response)
          .map(AppFeedback.fromJson)
          .toList();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> createFeedback({
    required FeedbackCategory category,
    required String title,
    required String body,
    required String deviceOs,
    required String deviceModel,
    required String appVersion,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw LwpI18n.current?.feedbackAuthRequired ??
            'You must be signed in to send feedback.';
      }

      await supabase.from('app_feedback').insert({
        'user_id': currentUser.id,
        'category': category.value,
        'title': title.trim(),
        'body': body.trim(),
        'status': FeedbackStatus.open.value,
        'device_os': deviceOs,
        'device_model': deviceModel,
        'app_version': appVersion,
      });
    } catch (error) {
      throw error.toString();
    }
  }
}
