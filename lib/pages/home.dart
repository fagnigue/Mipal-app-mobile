import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/constants.dart';
import 'package:mipal/helpers/popup.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/transaction.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:mipal/pages/cagnottes/cagnottes.dart';
import 'package:mipal/pages/profile.dart';
import 'package:mipal/pages/transactions/details_transaction.dart';
import 'package:mipal/pages/transactions/send_transaction.dart';
import 'package:mipal/services/transaction_service.dart';
import 'package:mipal/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'transactions/deposit_transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserService userService = UserService();
  final TransactionService transactionService = TransactionService();
  UserProfile? userProfile;
  List<Transaction> transactions = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = supabase.auth.currentUser;
    _loadUserProfile();
    _loadTransactions();
  }

  IconData predictTransactionIcon(Transaction transaction) {
    switch (transaction.type) {
      case "transaction":
        return transaction.from == currentUser!.id
            ? Icons.arrow_upward_rounded
            : Icons.arrow_downward_rounded;
      case "depot":
        return Icons.arrow_downward_rounded;
      case "cagnotte":
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.add_business_rounded;
    }
  }

  Text formatTitle(Transaction transaction) {
    if (transaction.type == "cagnotte") {
      return Text(transaction.cagnotte?.titre ?? '');
    }
    if (transaction.type == "depot") {
      return const Text("Dépôt");
    }
    return Text(
      transaction.from == currentUser!.id
          ? "à ${transaction.toProfile?.prenom ?? ''} ${transaction.toProfile?.nom ?? ''}"
          : "de ${transaction.fromProfile?.prenom ?? ''} ${transaction.fromProfile?.nom ?? ''}",
    );
  }

  Text formatMontant(Transaction transaction) {
    final isFromCurrentUser = transaction.from == currentUser!.id;
    final montantText =
        "${isFromCurrentUser ? '-' : ''}${transaction.montant} €";
    return Text(
      montantText,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: isFromCurrentUser ? Colors.black : Colors.green,
      ),
    );
  }

  String formatTransactionType(Transaction transaction) {
    String type = "";
    if (transaction.type == "transaction") {
      type = transaction.from == currentUser!.id ? "Envoyé" : "Reçu";
    } else if (transaction.type == "depot") {
      type = "Dépôt";
    } else {
      type = transaction.type;
    }
    return type;
  }

  String formatDate(DateTime date) {
    String month = date.month.toString().padLeft(2, '0');
    return "${date.day}/$month/${date.year}";
  }

  Future<void> _loadUserProfile() async {
    if (currentUser != null) {
      final userProfileLoaded = await userService.getUserProfileById(
        currentUser!.id,
      );
      if (mounted) {
        setState(() {
          userProfile = userProfileLoaded;
        });
      }
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        final transactionsLoaded = await transactionService.listTransactions(
          currentUser.id,
        );
        if (mounted) {
          setState(() {
            transactions = transactionsLoaded;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Popup.showError(context, "Erreur lors du chargement des transactions");
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: AppConstants.appName,
        automaticallyImplyLeading: false,
        actions: [
          SizedBox(
            width: 40,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => ProfilePage(userProfile: userProfile!),
                    ),
                  );
                },
                icon: Icon(Icons.person, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserProfile();
          await _loadTransactions();
        },
        color: AppColors.background,
        backgroundColor: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30),
              child: Center(
                child: Column(
                  children: [
                    AppConstants.solde,
                    const SizedBox(height: 10),
                    Text(
                      userProfile != null ? "${userProfile!.solde} €" : "...",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      AppConstants.envoyer,
                      const Icon(Icons.arrow_upward_rounded, size: 30),
                      () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => SendTransactionPage(
                                  initialAmount: userProfile!.solde,
                                ),
                          ),
                        );
                        await _loadUserProfile();
                        await _loadTransactions();
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      AppConstants.depot,
                      const Icon(Icons.arrow_downward_rounded, size: 30),
                      () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => DepositTransactionPage(
                                  initialBalance: userProfile!.solde,
                                ),
                          ),
                        );
                        await _loadUserProfile();
                        await _loadTransactions();
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      AppConstants.cagnotte,
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 30,
                      ),
                      () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => Cagnottes(
                                  initialAmount: userProfile!.solde,
                                ),
                          ),
                        );

                        await _loadUserProfile();
                        await _loadTransactions();
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      AppConstants.service,
                      const Icon(Icons.add_business_rounded, size: 30),
                      () {
                        Popup.showInfo(context, "Action pas encore implémentée");
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              padding: const EdgeInsets.only(left: 20),
              child: AppConstants.transactions,
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: transactions.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(
                        predictTransactionIcon(transactions[index]),
                      ),
                      title: formatTitle(transactions[index]),
                      subtitle: Text(
                        "${formatTransactionType(transactions[index])} - ${formatDate(transactions[index].createdAt)}",
                      ),
                      trailing: formatMontant(transactions[index]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DetailsTransaction(
                                  transactionId: transactions[index].id,
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildActionButton(Text label, Icon icon, VoidCallback onPressed) {
  return Column(
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 82, 79, 255),
        ),
        child: IconButton(
          icon: icon,
          onPressed: onPressed,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 5),
      label,
    ],
  );
}
