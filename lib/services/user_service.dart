import 'package:mipal/helpers/format_exception.dart';
import 'package:mipal/helpers/generate_unique_random_id.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:mipal/services/storage_service.dart';

class UserService {
  Future<UserProfile?> getUserProfileById(String id) async {
    try {
      final response =
          await supabase.from('profiles').select().eq('id', id).maybeSingle();

      if (response == null) {
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

  Future<void> ajouterBeneficiaire(String numero) async {
    try {
      final UserProfile user = await getUserProfileByAccountId(numero);
      final List<UserProfile> beneficiaires = getBeneficiaires();
      if (beneficiaires.any((b) => b.id == user.id)) {
        throw Exception('Ce bénéficiaire est déjà ajouté.');
      }
      if (user.id == supabase.auth.currentUser!.id) {
        throw Exception('Vous ne pouvez pas ajouter votre propre compte comme bénéficiaire.');
      }
      StorageService().ajouterBeneficiaire(user);
    } catch (e) {
      throw Exception(AppFormatException.message(e.toString()));
    }
  }

  List<UserProfile> getBeneficiaires() {
    try {
      return StorageService().getBeneficiaires();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des bénéficiaires: $e');
    }
  }

  supprimerBeneficiaire(UserProfile beneficiaire) {
    try {
      StorageService().supprimerBeneficiaire(beneficiaire);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du bénéficiaire: $e');
    }
  }
}
