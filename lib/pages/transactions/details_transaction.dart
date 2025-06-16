import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/constants.dart';
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
    switch (transaction.type) {
      case "transaction":
        return transaction.from == currentUser!.id ? "Envoi" : "Réception";
      case "depot":
        return "Dépôt";
      case "cagnotte":
        return "Cagnotte";
      default:
        return transaction.type;
    }
  }

  Widget formatRecipientOrSender(Transaction transaction) {
    if (transaction.type == 'depot') {
      return Text(
        "Effectué par ${transaction.fromProfile?.prenom ?? ''} ${transaction.fromProfile?.nom ?? ''}",
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      );
    }
    return Text(
      transaction.from == currentUser!.id
          ? "Destinataire: ${transaction.toProfile?.prenom ?? ''} ${transaction.toProfile?.nom ?? ''}"
          : "Expéditeur: ${transaction.fromProfile?.prenom ?? ''} ${transaction.fromProfile?.nom ?? ''}",
      style: const TextStyle(fontSize: 18, color: Colors.grey),
    );
  }

  String formatDate(DateTime date) {
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    return "$day/$month/${date.year} à $hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: AppConstants.detailsTransactionPageTitle,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactionDetails != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${formatTransactionType(transactionDetails!)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            if (transactionDetails!.type == 'depot')
              Row(
                children: [
                  const Icon(Icons.description, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Description: ${transactionDetails!.description ?? 'Aucune description'}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            if (transactionDetails!.type != 'depot' &&
                transactionDetails!.description != null &&
                transactionDetails!.description!.isNotEmpty)
              Text(
                'Description: ${transactionDetails!.description}',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            const SizedBox(height: 15),
            formatRecipientOrSender(transactionDetails!),
            const SizedBox(height: 15),
            Text(
              'Montant: ${transactionDetails!.montant} €',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              'Date: ${formatDate(transactionDetails!.createdAt)}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : const Center(child: Text('Aucune donnée disponible')),
    );
  }
}