import 'package:mipal/helpers/format_exception.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/cagnotte.dart';
import 'package:mipal/models/transaction.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:mipal/services/cagnotte_service.dart';
import 'package:mipal/services/user_service.dart';

class TransactionService {
  TransactionService._internal();
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  
  Future<String> createTransaction(String recipient, double montant) async {
    try {
      final currentUser = supabase.auth.currentUser;
      final String? from = currentUser?.id;
      final UserProfile to = await UserService().getUserProfileByAccountId(recipient);
      final transaction = Transaction.create(
        from: from!,
        to: to.id!,
        montant: montant,
        type: "transaction",
      );
      await supabase.from('transactions').insert(transaction.toMap());
      await UserService().updateUserAmount(from, -montant);
      await UserService().updateUserAmount(to.id!, montant);
      return transaction.id;
    } catch (e) {
      throw Exception(AppFormatException.message(e.toString()));
    }
  }

  Future<String> createTransactionForCagnotte(String? from, String to, double montant, String cagnotteId) async {
    try {
      final transaction = Transaction.create(
        from: from,
        to: to,
        montant: montant,
        type: "cagnotte",
        cagnotteId: cagnotteId,
      );
      await supabase.from('transactions').insert(transaction.toMap());
      if (from != null) {
        await UserService().updateUserAmount(from, -montant);
        await CagnotteService().updateSoldeCagnotte(cagnotteId, montant);
      } else if (from == null) {
        await UserService().updateUserAmount(to, montant);
        await CagnotteService().updateSoldeCagnotte(cagnotteId, -montant);
      }
      return transaction.id;
    } catch (e) {
      throw Exception(AppFormatException.message(e.toString()));
    }
  }
  
  Future<Transaction?> getTransactionById(String transactionId) async {
    try {
      final response = await supabase
          .from('transactions')
          .select()
          .eq('id', transactionId)
          .maybeSingle();
      if (response == null) {
        return null;
      }

      final UserProfile? fromProfile = response['from'] != null ? await UserService().getUserProfileById(response['from']) :  null;
      final UserProfile? toProfile = await UserService().getUserProfileById(response['to']);
      final transaction = Transaction.fromMap(response);
      transaction.fromProfile = fromProfile;
      transaction.toProfile = toProfile;

      return transaction;
    } catch (e) {
      throw Exception('Erreur $e');
    }
  }

  
  Future<List<Transaction>> listTransactions(String userId,) async {
    try {
      final response = await supabase
          .from('transactions')
          .select()
          .or('from.eq.$userId,to.eq.$userId')
          .order('created_at', ascending: false);
      
      return Future.wait((response as List).map((e) async {
        final UserProfile? fromProfile = e['from'] != null ? await UserService().getUserProfileById(e['from']) : null;
        final UserProfile? toProfile = await UserService().getUserProfileById(e['to']);
        final transaction = Transaction.fromMap(e);
        transaction.fromProfile = fromProfile;
        transaction.toProfile = toProfile;
        if (e['cagnotte_id'] != null) {
          final Cagnotte? cagnotte = await CagnotteService().getCagnotteById(e['cagnotte_id']);
          transaction.cagnotte = cagnotte;
        }
        return transaction;
      }).toList());
    } catch (e) {
      throw Exception('Error listing transactions: $e');
    }
  }

  Future<List<Transaction>> listTransactionsByCagnotte(String cagnotteId) async {
    try {
      final response = await supabase
          .from('transactions')
          .select()
          .eq('cagnotte_id', cagnotteId)
          .order('created_at', ascending: false);

      return Future.wait((response as List).map((e) async {
        final UserProfile? fromProfile = e['from'] != null ? await UserService().getUserProfileById(e['from']) : null;
        final UserProfile? toProfile = await UserService().getUserProfileById(e['to']);
        final transaction = Transaction.fromMap(e);
        transaction.fromProfile = fromProfile;
        transaction.toProfile = toProfile;
        return transaction;
      }).toList());
    } catch (e) {
      throw Exception('Erreur lors de la récupération des transactions de la cagnotte: $e');
    }
  }


  Future<void> createDeposit(String userId, double montant, String? description) async {
    try {
      final Transaction transaction = Transaction.create(
        from: userId,
        montant: montant,
        type: 'depot',
      );

      await supabase.from('transactions').insert(transaction.toMap());
      await UserService().updateUserAmount(transaction.to!, montant);
    } catch (e) {
      throw Exception('Erreur lors du dépôt: $e');
    }
  }
}