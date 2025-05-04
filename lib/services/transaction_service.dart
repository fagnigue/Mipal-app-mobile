import 'package:mipal/main.dart';
import 'package:mipal/models/transaction.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:mipal/services/user_service.dart';

class TransactionService {
  final UserService userService = UserService();
  
  Future<void> createTransaction(String recipient, double amount) async {
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
    } catch (e) {
      throw Exception('$e');
    }
  }

  
  Future<Transaction?> getTransaction(String transactionId) async {
    try {
      final response = await supabase
          .from('transactions')
          .select()
          .eq('id', transactionId)
          .single();
      return Transaction.fromMap(response);
    } catch (e) {
      return null;
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
}