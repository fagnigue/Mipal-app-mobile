import 'package:mipal/helpers/format_exception.dart';
import 'package:mipal/helpers/generate_unique_random_id.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/cagnotte.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:mipal/services/storage_service.dart';
import 'package:mipal/services/transaction_service.dart';
import 'package:mipal/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CagnotteService {
  static final CagnotteService _instance = CagnotteService._internal();
  factory CagnotteService() => _instance;
  CagnotteService._internal();
  
  final UserService userService = UserService();
  final User? currentUser = supabase.auth.currentUser;


  Future<String> createCagnotte(String titre, double montantDeBase, String? description) async {
    try {
      final cagnotte = Cagnotte.create(
        titre: titre,
        solde: 0.0,
        profileId: currentUser!.id,
        description: description,
        code: await generateUniqueCode(),
      );

      await supabase.from('cagnottes').insert(cagnotte.toJson());
      if (montantDeBase > 0) {
        await TransactionService().createTransactionForCagnotte(
          currentUser!.id,
          currentUser!.id,
          montantDeBase,
          cagnotte.id,
        );
      }
      return cagnotte.id;
    } catch (e) {
      throw Exception(AppFormatException.message("Erreur: $e"));
    }
  }

  Future<void> updateSoldeCagnotte(String cagnotteId, double solde) async {
    try {
      final cagnotte = await getCagnotteById(cagnotteId);
      await supabase.from('cagnottes').update({'solde': cagnotte!.solde + solde}).eq('id', cagnotteId);
    } catch (e) {
      throw Exception(AppFormatException.message("Erreur: $e"));
    }
  }

  Future<String> generateUniqueCode() async {
    String randomValue;
    do {
      randomValue = GenerateUniqueRandomId().generateWithPrefix("CAG-");
    } while (await isCodeExists(randomValue));
    return randomValue.toString();
  }

  Future<bool> isCodeExists(String code) async {
    try {
      final response = await supabase
          .from('cagnottes')
          .select()
          .eq('code', code)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<Cagnotte?> getCagnotteById(String cagnotteId) async {
    try {
      final response = await supabase
          .from('cagnottes')
          .select()
          .eq('id', cagnotteId)
          .maybeSingle();
      if (response == null) {
        return null;
      }
      return Cagnotte.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la cagnotte: $e');
    }
  }

  Future<Cagnotte> getCagnotteByCode(String code) async {
    try {
      final response = await supabase
          .from('cagnottes')
          .select()
          .eq('code', code)
          .maybeSingle();
      if (response == null) {
        throw Exception('Aucune cagnotte trouvée avec ce code.');
      }
      return Cagnotte.fromJson(response);
    } catch (e) {
      throw Exception(AppFormatException.message("$e"));
    }
  }

  Future<List<Cagnotte>> getCagnottes() async {
    try {
      final response = await supabase
          .from('cagnottes')
          .select()
          .eq('profile_id', currentUser!.id)
          .eq('statut', 'en cours')
          .order('created_at', ascending: false);
      
      return Future.wait((response as List).map((e) async {
        final UserProfile? userProfile = await userService.getUserProfileById(e['profile_id']);
        final Cagnotte cagnotte = Cagnotte.fromJson(e);
        cagnotte.profile = userProfile;
        return cagnotte;
      })); 
    } catch (e) {
      throw Exception('Erreur lors de la récupération des cagnottes');
    }
  }

  Future<void> ajouterCagnotte(String codeCagnotte) async {
    try {
      final Cagnotte cagnotte = await getCagnotteByCode(codeCagnotte);
      final List<Cagnotte > cagnottes = StorageService().getCagnottes();

      if (cagnottes.any((c) => c.code == cagnotte.code)) {
        throw Exception('Cette cagnotte est déjà ajoutée.');
      }
      
      StorageService().ajouterCagnotte(cagnotte);
    } catch (e) {
      throw Exception(AppFormatException.message(e.toString()));
    }
  }

  Future<void> cloturerCagnotte(String id)async {
    try {
      final Cagnotte? cagnotte = await getCagnotteById(id);
      await supabase.from('cagnottes').update({'statut': 'cloturée'}).eq('id', id);
      await TransactionService().createTransactionForCagnotte(null, currentUser!.id, cagnotte!.solde, cagnotte.id);
    } catch (e) {
      throw Exception('Erreur lors de la clôture de la cagnotte');
    }
  }

}