import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/popup.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/transaction.dart';
import 'package:mipal/services/transaction_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailsTransaction extends StatefulWidget {
  final String transactionId;

  const DetailsTransaction({super.key, required this.transactionId});

  @override
  State<DetailsTransaction> createState() => _DetailsTransactionState();
}

class _DetailsTransactionState extends State<DetailsTransaction> {
  Transaction? transactionDetails;
  TransactionService transactionService = TransactionService();
  User? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUser = supabase.auth.currentUser;
    _fetchTransactionDetails();
  }

  Future<void> _fetchTransactionDetails() async {
    try {
      transactionDetails = await transactionService.getTransactionById(widget.transactionId);
      if (transactionDetails == null) {
        setState(() {
          isLoading = false;
        });
        Popup.showError(context, "Aucune transaction trouvée.");
        return;
      }
      setState(() {
        transactionDetails = transactionDetails;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Popup.showError(context, "Erreur lors de la récupération des détails de la transaction.");
    }
  }

  String formatTransactionType(Transaction transaction) {
    String type = "";
    if (transaction.type == "transaction") {
      type = transaction.from == currentUser!.id ? "Envoi" : "Reception";
    } else if (transaction.type == "depot") {
      type = "Dépôt";
    } else {
      type = transaction.type;
    }
    return type;
  }

  Text formatRecipientOrSender(Transaction transaction) {
    return Text(
      transaction.from == currentUser!.id
          ? "Destinataire: ${transaction.toProfile?.prenom ?? ''} ${transaction.toProfile?.nom ?? ''}"
          : "Expéditeur: ${transaction.fromProfile?.prenom ?? ''} ${transaction.fromProfile?.nom ?? ''}",
    );
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Détails de la transaction'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactionDetails != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${formatTransactionType(transactionDetails!)}',
                          style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 15),
                      Text('${formatRecipientOrSender(transactionDetails!).data}',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 15),
                      Text('Montant: ${transactionDetails!.montant} €',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 15),
                      Text('Date: ${formatDate(transactionDetails!.createdAt)}',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 15),
                    ],
                  ),
                )
              : const Center(child: Text('Aucune donnée disponible')),
    );
  }
}