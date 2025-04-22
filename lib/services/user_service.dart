import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mipal/helpers/env_vars.dart';
import 'package:mipal/helpers/generate_unique_random_id.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/userProfile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {

  Future<UserProfile?> getUserProfileById(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserProfile.fromMap(response);
    } catch (e) {
      return null;
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
      final response = await supabase
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
      await supabase.from('profiles').insert(userProfile.toJson());
      return await getUserProfileById(userProfile.id!);
    } catch (e) {
      throw Exception('Error creating user profile: $e');
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> googleSignIn(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: EnvVars.googleIosClientId,
      serverClientId: EnvVars.googleWebClientId
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de connexion avec Google.")),
      );
    }
    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken!,
      accessToken: accessToken,
    );
  }



}