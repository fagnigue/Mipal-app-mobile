import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/format_exception.dart';
import 'package:mipal/helpers/popup.dart';
import 'package:mipal/helpers/widgets.dart';
import 'package:mipal/models/cagnotte.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:mipal/pages/beneficiaires.dart';
import 'package:mipal/pages/transactions/details_transaction.dart';
import 'package:mipal/services/transaction_service.dart';

class SendTransactionPage extends StatefulWidget {
  final double? initialAmount;
  const SendTransactionPage({super.key, required this.initialAmount});

  @override
  State<SendTransactionPage> createState() => _SendTransactionPageState();
}

class _SendTransactionPageState extends State<SendTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TransactionService transactionService = TransactionService();
  late double restant;
  bool canSend = false;
  bool recipientValid = false;
  bool amountValid = false;
  UserProfile? beneficiaire;
  Cagnotte? cagnotte;

  @override
  void initState() {
    super.initState();
    restant = widget.initialAmount!;
    _amountController.addListener(() {
      setState(() {
        double amountValue = double.tryParse(_amountController.text) ?? 0.0;
        restant = widget.initialAmount! - amountValue;
        amountValid = amountValue > 0 && restant >= 0;
        canSend = recipientValid && amountValid;
      });
    });
    _recipientController.addListener(() {
      setState(() {
        recipientValid = _recipientController.text.isNotEmpty;
        canSend = recipientValid && amountValid;
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  void _sendTransaction() async {
    if (_formKey.currentState!.validate()) {
      final amount = _amountController.text.trim();
      final recipient = _recipientController.text.trim();

      final double amountValue = double.tryParse(amount) ?? 0.0;
      try {
        String? transactionId;
        if (beneficiaire != null) {
          transactionId = await transactionService.createTransaction(
            recipient,
            amountValue,
          );
        }
        if (cagnotte != null) {
          transactionId = await transactionService.createTransactionForCagnotte(
            recipient,
            amountValue,
            cagnotte!.id,
          );
        }
        if (transactionId != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) =>
                      DetailsTransaction(transactionId: transactionId!),
            ),
          );
          Popup.showSuccess(context, "Transaction envoyée avec succès");
        }
      } catch (e) {
        Popup.showError(
          context,
          "Erreur: ${AppFormatException.message(e.toString())}",
        );
        return;
      }
    }
  }

  void goToBenefiaires() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BeneficiairesPage()),
    );

    if (result != null && result is UserProfile) {
      setState(() {
        beneficiaire = result;
        cagnotte = null;
        _recipientController.text = beneficiaire?.numeroCompte ?? '';
      });
    } else if (result != null && result is Cagnotte) {
      setState(() {
        cagnotte = result;
        beneficiaire = null;
        _recipientController.text = cagnotte?.profileId ?? '';
      });
    }
  }

  String formatText() {
    if (beneficiaire != null) {
      return "${beneficiaire!.nom} ${beneficiaire!.prenom}";
    } else if (cagnotte != null) {
      return cagnotte!.titre;
    }
    return "Beneficaire";
  }

  IconData formatIcon() {
    if (beneficiaire != null) {
      return Icons.person;
    } else if (cagnotte != null) {
      return Icons.account_balance_wallet_rounded;
    }
    return Icons.person_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Envoyer de l\'argent'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppWidgets.buildUnwrittableInput(
                icon: formatIcon(),
                text: formatText(),
                width: MediaQuery.of(context).size.width * 0.8,
                onTap: goToBenefiaires,
              ),
              SizedBox(height: 16),
              AppWidgets.buildTextField(
                labelText: 'Montant',
                hintText: 'Entrez le montant à envoyer',
                controller: _amountController,
                width: MediaQuery.of(context).size.width * 0.8,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.euro_symbol_rounded,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Montant initial: ${widget.initialAmount} €',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "restant: $restant €",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 30),
              AppWidgets.buildValidationButton(
                text: 'Envoyer',
                onPressed: canSend ? _sendTransaction : null,
                color: AppColors.primary,
                textColor: Colors.white,
                width: MediaQuery.of(context).size.width * 0.8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
