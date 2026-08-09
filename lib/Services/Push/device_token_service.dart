import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Upserts and deletes FCM tokens for the signed-in user.
class DeviceTokenService {
  DeviceTokenService({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String get _platform => Platform.isIOS ? 'ios' : 'android';

  Future<void> upsertToken(String fcmToken) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || fcmToken.isEmpty) return;

    await _client.from('user_device_tokens').upsert(
      {
        'user_id': userId,
        'fcm_token': fcmToken,
        'platform': _platform,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'fcm_token',
    );
  }

  Future<void> deleteToken(String? fcmToken) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    if (fcmToken != null && fcmToken.isNotEmpty) {
      await _client
          .from('user_device_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('fcm_token', fcmToken);
      return;
    }

    await _client.from('user_device_tokens').delete().eq('user_id', userId);
  }
}
