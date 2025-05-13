import 'package:flutter/material.dart';
import 'package:mipal/helpers/format_exception.dart';
import 'package:mipal/helpers/generate_unique_random_id.dart';
import 'package:mipal/helpers/popup.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  Future<UserProfile?> getUserProfileById(String userId) async {
    try {
      final response =
          await supabase.from('profiles').select().eq('id', userId).maybeSingle();
      if (response == null) {
        return null;
      }
      return UserProfile.fromMap(response);
    } catch (e) {
      throw Exception(e.toString());
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
}
