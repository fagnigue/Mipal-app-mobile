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
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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

  _showClotureDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clôturer la cagnotte"),
          content: const Text(
            "Voulez-vous vraiment clôturer cette cagnotte ?\nLe solde restant sera transféré sur votre compte.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Clôturer"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _cloturerCagnotte();
    }
  }

  _showDescriptionModal() {
    showMaterialModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.background,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color.fromARGB(255, 201, 201, 201), width: 0.5),
                ),
              ),
              child: const Text(
                "Description",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                cagnotte?.description ?? 'Aucune description disponible',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  _loadCagnotteDetails() async {
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

  _loadTransactions() async {
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

  _cloturerCagnotte() async {
    try {
      await CagnotteService().cloturerCagnotte(cagnotte!.id);
      Popup.showSuccess(context, "Cagnotte clôturée avec succès");
      _loadCagnotteDetails();
      _loadTransactions();
    } catch (e) {
      Popup.showError(context, "Erreur lors de la clôture de la cagnotte");
    }
  }

  String formatTitle(Transaction transaction) {
    if (transaction.from == null) {
      return "transfert sur compte";
    }
    return transaction.from == currentUser!.id
        ? "de Moi"
        : "de ${transaction.fromProfile?.prenom} ${transaction.fromProfile?.nom}";
  }

  String formatDate(DateTime date) {
    String month = date.month.toString().padLeft(2, '0');
    return "${date.day}/$month/${date.year}";
  }

  bool estCagnotteCloturee() {
    return cagnotte?.statut == "cloturée";
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
                    cagnotte?.titre ?? "chargement...",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: _showDescriptionModal,
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          "Description",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
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
                  estCagnotteCloturee()
                      ? Container(
                        width: "cloturée".length * 10.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(5.0),
                        child: const Center(
                          child: Text(
                            "cloturée",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      )
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            187,
                            61,
                            52,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          _showClotureDialog();
                        },
                        child: const Text(
                          "Cloturer",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [AppConstants.transactions],
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
