import 'package:flutter/material.dart';
import 'package:mipal/helpers/env_vars.dart';
import 'package:mipal/pages/home.dart';
import 'package:mipal/pages/login.dart';
import 'package:mipal/services/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvVars.loadEnv();
  await StorageService().init();
  await Supabase.initialize(
    url: EnvVars.supabaseUrl,
    anonKey: EnvVars.supabaseAnonKey,
  );

  runApp(const MyApp());
}

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
    return MaterialApp(
      title: 'Instruments',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: verifierUser(),
    );
  }
}
