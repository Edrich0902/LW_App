import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get fileName => kReleaseMode ? ".env.production" : ".env.development";
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseKey => dotenv.env['SUPABASE_KEY'] ?? '';
  static String get cloudinaryCloud => dotenv.env['CLOUDINARY_CLOUD'] ?? '';
  static String get cloudinaryUploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  static String get youversionKey => dotenv.env['YOUVERSION_KEY'] ?? '';
  static String get authCallbackUrl => dotenv.env['AUTH_CALLBACK_URL'] ?? '';
}