import 'package:mipal/helpers/format_exception.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/transaction.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:mipal/services/user_service.dart';

class TransactionService {
  final UserService userService = UserService();
  
  Future<String> createTransaction(String recipient, double amount) async {
    try {
      final currentUser = supabase.auth.currentUser;
      final String? from = currentUser?.id;
      final UserProfile to = await userService.getUserProfileByAccountId(recipient);
      final transaction = Transaction.create(
        from: from!,
        to: to.id!,
        montant: amount,
        type: "transaction",
      );
      await supabase.from('transactions').insert(transaction.toMap());
      await userService.updateUserAmount(from, -amount);
      await userService.updateUserAmount(to.id!, amount);
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

      final UserProfile? fromProfile = await userService.getUserProfileById(response['from']);
      final UserProfile? toProfile = await userService.getUserProfileById(response['to']);
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
        final UserProfile? fromProfile = await userService.getUserProfileById(e['from']);
        final UserProfile? toProfile = await userService.getUserProfileById(e['to']);
        final transaction = Transaction.fromMap(e);
        transaction.fromProfile = fromProfile;
        transaction.toProfile = toProfile;
        return transaction;
      }).toList());
    } catch (e) {
      throw Exception('Error listing transactions: $e');
    }
  }


  Future<void> createDeposit(String userId, double amount) async {
    try {
      await supabase.from('transactions').insert({
        'from': userId,
        'to': userId,
        'montant': amount,
        'type': 'depot',
        'created_at': DateTime.now().toIso8601String(),
      });

      await supabase.from('profiles').update({
        'solde': supabase.from('profiles').select('solde').eq('id', userId).single().then((res) => res['solde'] + amount),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Erreur lors du dépôt: $e');
    }
  }
}