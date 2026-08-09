import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get fileName => kReleaseMode ? ".env.production" : ".env.development";

  /// Resolves Supabase API base URL for the current platform.
  ///
  /// Local `.env.development` typically uses `http://127.0.0.1:54321`, which
  /// works on the iOS Simulator (shares the Mac loopback). On Android:
  /// - Emulator: loopback is rewritten to `10.0.2.2` (host machine).
  /// - Physical device: set `SUPABASE_URL_ANDROID` to your Mac's LAN IP, e.g.
  ///   `http://192.168.1.20:54321` (emulator alias is unreachable from hardware).
  static String get supabaseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidOverride = dotenv.env['SUPABASE_URL_ANDROID']?.trim();
      if (androidOverride != null && androidOverride.isNotEmpty) {
        return androidOverride;
      }
      return _rewriteLoopbackForAndroidEmulator(dotenv.env['SUPABASE_URL'] ?? '');
    }
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseKey => dotenv.env['SUPABASE_KEY'] ?? '';
  static String get cloudinaryCloud => dotenv.env['CLOUDINARY_CLOUD'] ?? '';
  static String get cloudinaryUploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  static String get youversionKey => dotenv.env['YOUVERSION_KEY'] ?? '';
  static String get authCallbackUrl => dotenv.env['AUTH_CALLBACK_URL'] ?? '';

  static String _rewriteLoopbackForAndroidEmulator(String url) {
    if (url.isEmpty) return url;
    return url
        .replaceAll('127.0.0.1', '10.0.2.2')
        .replaceAll('localhost', '10.0.2.2');
  }
}