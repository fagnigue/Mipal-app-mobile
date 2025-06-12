import 'package:flutter/material.dart';
import 'package:mipal/helpers/format_exception.dart';
import 'package:mipal/helpers/generate_unique_random_id.dart';
import 'package:mipal/helpers/popup.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:mipal/services/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/colors.dart';
import '../pages/home.dart';
import '../pages/signin.dart';

class UserService {
  Future<UserProfile?> getUserProfileById(String id) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        final user = supabase.auth.currentUser;
        if (user != null) {
          final newProfile = {
            'id': id,
            'solde': 0.0,
            'prenom': user.userMetadata?['given_name'] ?? 'Utilisateur',
            'nom': user.userMetadata?['family_name'] ?? '',
            'account_id': user.email ?? id,
            'created_at': DateTime.now().toIso8601String(),
          };
          await supabase.from('profiles').insert(newProfile);
          return UserProfile.fromMap(newProfile);
        }
        return null;
      }
      return UserProfile.fromMap(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  Future<UserProfile> getUserProfileByAccountId(String accoundId) async {
    try {
      final response =
          await supabase
              .from('profiles')
              .select()
              .eq('numero_de_compte', accoundId)
              .maybeSingle();
      if (response == null) {
        throw Exception('Le profil utilisateur n\'existe pas.');
      }
      return UserProfile.fromMap(response);
    } catch (e) {
      throw Exception(AppFormatException.message(e.toString()));
    }
  }

  Future<String> generateUniqueId() async {
    String randomValue;
    do {
      randomValue = GenerateUniqueRandomId().generate();
    } while (await isIdExists(randomValue));
    return randomValue.toString();
  }

  Future<bool> isIdExists(String accountId) async {
    try {
      final response =
          await supabase
              .from('profiles')
              .select()
              .eq('numero_de_compte', accountId)
              .single();

      if (response.isEmpty) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserProfile?> createUserProfile(UserProfile userProfile) async {
    try {
      await supabase.from('profiles').insert(userProfile.toMap());
      return await getUserProfileById(userProfile.id!);
    } catch (e) {
      throw Exception('Error creating user profile: $e');
    }
  }

  Future<void> updateUserAmount(String userId, double amount) async {
    try {
      final profile = await getUserProfileById(userId);
      await supabase
          .from('profiles')
          .update({'solde': profile!.solde! + amount})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Erreur de modification du solde');
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> googleSignIn(BuildContext context) async {
    final googleUser = await appGoogleSignIn.signIn();
    if (googleUser == null) {
      Popup.showError(context, "Erreur de connexion avec Google.");
      return;
    }
    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      Popup.showError(context, "Erreur de connexion avec Google.");
      return;
    }
    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken!,
      accessToken: accessToken,
    );
  }


  Future<void> signInWithEmail(
      BuildContext context, String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        final userProfile = await getUserProfileById(response.user!.id);
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
                builder: (context) => SigninPage(
                  userId: response.user!.id,
                  email: response.user!.email!,
                ),
              ),
            );
          }
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de connexion: $error"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }


  Future<void> signUpWithEmail(
      BuildContext context, String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SigninPage(
                userId: response.user!.id,
                email: response.user!.email!,
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de l'inscription: $error"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
