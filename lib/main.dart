import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mipal/helpers/env_vars.dart';
import 'package:mipal/pages/home.dart';
import 'package:mipal/pages/auth/login.dart';
import 'package:mipal/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await EnvVars.loadEnv();
  await StorageService().init();
  await Supabase.initialize(
    url: EnvVars.supabaseUrl,
    anonKey: EnvVars.supabaseAnonKey,
  );

  runApp(const MyApp());
}

final GoogleSignIn appGoogleSignIn = GoogleSignIn(
      clientId: EnvVars.googleIosClientId,
      serverClientId: EnvVars.googleWebClientId,
    );
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  verifierUser() {
    final user = supabase.auth.currentUser;
    final userProfile = StorageService().getUser();

    if (user == null || userProfile == null) {
      return const LoginPage();
    }
    return const HomePage();
  }

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return MaterialApp(
      title: 'Instruments',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: verifierUser(),
    );
  }
}
