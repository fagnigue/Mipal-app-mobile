import 'package:mipal/helpers/generate_unique_random_id.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/cagnotte.dart';
import 'package:mipal/services/user_service.dart';

class CagnotteService {
  final UserService userService = UserService();
  final currentUser = supabase.auth.currentUser;

  // Méthode pour créer une cagnotte
  Future<void> createCagnotte(String titre, double solde, String? description) async {
    try {
      final cagnotte = Cagnotte.create(
        titre: titre,
        solde: solde,
        createurId: currentUser!.id,
        description: description,
        code: await generateUniqueCode(),
      );

      await supabase.from('cagnottes').insert(cagnotte.toJson());


      await userService.updateUserAmount(currentUser!.id, -solde);

      
    } catch (e) {
      throw Exception('Erreur lors de la création de la cagnotte: $e');
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

}