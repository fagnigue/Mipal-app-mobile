import 'package:flutter/material.dart';
import 'package:mipal/helpers/format_exception.dart';
import 'package:mipal/main.dart';
import 'package:mipal/pages/auth/register.dart';
import 'package:mipal/pages/home.dart';
import 'package:mipal/services/storage_service.dart';
import 'package:mipal/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> googleSignIn() async {
    try {
      final googleUser = await appGoogleSignIn.signIn();
      if (googleUser == null) {
        throw Exception();
      }
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception();
      }
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      throw Exception(
        AppFormatException.message("Erreur de connexion avec Google"),
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
    } catch (error) {
      throw Exception(AppFormatException.message("Erreur de connexion"));
    }
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      return await supabase.auth.signUp(email: email, password: password);
    } catch (error) {
      throw Exception(AppFormatException.message("Erreur d'inscription"));
    }
  }



  dynamic handleAuthstateChange(AuthState data, BuildContext context) async {
    if (data.session != null) {
        final userId = data.session!.user.id;
        final userProfile = await UserService().getUserProfileById(userId);

        if (userProfile != null) {
          await StorageService().saveUser(userProfile);
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) => RegisterPage(
                      userId: userId,
                      email: data.session!.user.email!,
                    ),
              ),
            );
          }
        }
      }
  }
}
