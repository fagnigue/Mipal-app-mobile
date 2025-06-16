import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/constants.dart';
import 'package:mipal/helpers/popup.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/cagnotte.dart';
import 'package:mipal/models/transaction.dart';
import 'package:mipal/services/cagnotte_service.dart';
import 'package:mipal/services/transaction_service.dart';

class DetailsCagnottePage extends StatefulWidget {
  final String cagnotteId;

  const DetailsCagnottePage({super.key, required this.cagnotteId});

  @override
  State<DetailsCagnottePage> createState() => DetailsCagnottePageState();
}

class DetailsCagnottePageState extends State<DetailsCagnottePage> {
  Cagnotte? cagnotte;
  List<Transaction> transactions = [];
  final currentUser = supabase.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _loadCagnotteDetails();
    _loadTransactions();
  }

  void _loadCagnotteDetails() async {
    final Cagnotte? cagnotte = await CagnotteService().getCagnotteById(
      widget.cagnotteId,
    );

    if (cagnotte != null) {
      setState(() {
        this.cagnotte = cagnotte;
      });
    } else {
      Popup.showError(context, "Cagnotte non trouvée");
    }
  }

  void _loadTransactions() async {
    try {
      final transactions = await TransactionService()
          .listTransactionsByCagnotte(widget.cagnotteId);
      setState(() {
        this.transactions = transactions;
      });
    } catch (e) {
      Popup.showError(context, "Erreur lors du chargement des transactions");
    }
  }

  String formatTitle(Transaction transaction) {
    return transaction.from == currentUser!.id
        ? "de Moi"
        : "de ${transaction.fromProfile?.prenom ?? ''} ${transaction.fromProfile?.nom ?? ''}";
  }

  String formatDate(DateTime date) {
    String month = date.month.toString().padLeft(2, '0');
    return "${date.day}/$month/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: AppConstants.cagnottePageTitle,
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Column(
                children: [
                  Text(
                    cagnotte?.titre ?? "Cagnotte",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppConstants.solde,
                  const SizedBox(height: 10),
                  Text(
                    cagnotte != null ? "${cagnotte!.solde} €" : "...",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cagnotte?.code ?? "...",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: (cagnotte?.code ?? "...").replaceFirst(
                                "CAG-",
                                "",
                              ),
                            ),
                          );
                          Popup.showInfo(context, "Code copié !");
                        },
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppConstants.transactions
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  title: Text(
                    formatTitle(transaction),
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(formatDate(transaction.createdAt)),
                  leading: Icon(Icons.arrow_downward, color: Colors.green),
                  trailing: Text(
                    "${transaction.montant} €",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
