import 'package:mipal/helpers/format_exception.dart';
import 'package:mipal/helpers/generate_unique_random_id.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/cagnotte.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:mipal/services/transaction_service.dart';
import 'package:mipal/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CagnotteService {
  static final CagnotteService _instance = CagnotteService._internal();
  factory CagnotteService() => _instance;
  CagnotteService._internal();
  
  final UserService userService = UserService();
  final User? currentUser = supabase.auth.currentUser;


  Future<String> createCagnotte(String titre, double solde, String? description) async {
    try {
      final cagnotte = Cagnotte.create(
        titre: titre,
        solde: solde,
        profileId: currentUser!.id,
        description: description,
        code: await generateUniqueCode(),
      );

      await supabase.from('cagnottes').insert(cagnotte.toJson());
      if (solde > 0) {
        await TransactionService().createTransactionForCagnotte(
          currentUser!.id,
          solde,
          cagnotte.id,
        );
      }
      return cagnotte.id;
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

  Future<List<Cagnotte>> getCagnottes() async {
    try {
      final response = await supabase
          .from('cagnottes')
          .select()
          .eq('profile_id', currentUser!.id)
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

}