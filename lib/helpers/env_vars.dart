import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvVars {
  static late final String supabaseUrl;
  static late final String supabaseAnonKey;
  static late final String googleWebClientId;
  static late final String googleIosClientId;

  static Future<void> loadEnv() async {
    await dotenv.load();
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    googleWebClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
    googleIosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';
  }
}