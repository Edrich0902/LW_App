import 'package:lw_app/Models/PrayerRequest/prayer_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrayerRequestService {
  final SupabaseClient supabase = Supabase.instance.client;
  final GoTrueClient _auth = Supabase.instance.client.auth;

  Future<List<PrayerRequest>> getPublicPrayerRequests() async {
    try {
      final response = await supabase
          .from('prayer_requests_public_view')
          .select('*')
          .order('created_at', ascending: false);

      final reactions = await _getCurrentUserReactionIds();
      final reactionSet = reactions.toSet();
      final items = List<Map<String, dynamic>>.from(response);

      return items
          .map(
            (item) => PrayerRequest.fromJson(item).copyWith(
              hasReacted: reactionSet.contains(item['id']),
            ),
          )
          .toList();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<List<PrayerRequest>> getMyPrayerRequests() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final response = await supabase
          .from('prayer_requests_owner_view')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response)
          .map(PrayerRequest.fromJson)
          .toList();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> createPrayerRequest({
    required PrayerCategory category,
    required String body,
    required bool isAnonymous,
    bool isPrivate = false,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Jy moet ingeteken wees om \'n gebedsversoek te stuur.';
      }

      final request = PrayerRequest(
        category: category,
        body: body,
        isAnonymous: isAnonymous,
        isPrivate: isPrivate,
        status: PrayerRequestStatus.pending,
      );

      await supabase.from('prayer_requests').insert(
            request.toCreateJson(userId: currentUser.id),
          );
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> resolvePrayerRequest(String requestId, {String? praiseReport}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Jy moet ingeteken wees om \'n gebedsversoek af te handel.';
      }

      await supabase.from('prayer_requests').update({
        'status': PrayerRequestStatus.resolved.value,
        'resolved_at': DateTime.now().toUtc().toIso8601String(),
        'resolved_by': currentUser.id,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'praise_report': praiseReport,
      }).eq('id', requestId);
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> toggleReaction({
    required String requestId,
    required bool hasReacted,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Jy moet ingeteken wees om te reageer.';
      }

      if (hasReacted) {
        await supabase
            .from('prayer_request_reactions')
            .delete()
            .eq('prayer_request_id', requestId)
            .eq('user_id', currentUser.id);
      } else {
        await supabase.from('prayer_request_reactions').insert({
          'prayer_request_id': requestId,
          'user_id': currentUser.id,
        });
      }
    } catch (error) {
      throw error.toString();
    }
  }

  Future<List<String>> _getCurrentUserReactionIds() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    final response = await supabase
        .from('prayer_request_reactions')
        .select('prayer_request_id')
        .eq('user_id', currentUser.id);

    return List<Map<String, dynamic>>.from(response)
        .map((item) => item['prayer_request_id'].toString())
        .toList();
  }
}
