import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/format_exception.dart';
import 'package:mipal/helpers/popup.dart';
import 'package:mipal/helpers/widgets.dart';
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
        recipientValid =
            _recipientController.text.isNotEmpty &&
            _recipientController.text.length == 6;
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
      final amount = _amountController.text;
      final recipient = _recipientController.text;

      final double amountValue = double.tryParse(amount) ?? 0.0;
      try {
        final String transactionId = await transactionService.createTransaction(
          recipient,
          amountValue,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => DetailsTransaction(transactionId: transactionId),
          ),
        );
        Popup.showSuccess(context, "Transaction envoyée avec succès");
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  BeneficiairesPage(),
      ),
    );
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
              // AppWidgets.buildTextField(
              //   labelText: 'Bénéficiaire',
              //   hintText: 'Entrez le numéro de compte',
              //   controller: _recipientController,
              //   width: MediaQuery.of(context).size.width * 0.8,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Veuillez entrer un numéro de compte';
              //     }
              //     return null;
              //   },
              //   keyboardType: TextInputType.number,
              //   prefixIcon: Icons.person,
              // ),
              AppWidgets.buildUnwrittableInput(
                icon: Icons.person,
                text: "Beneficaire",
                width: MediaQuery.of(context).size.width * 0.8,
                onTap: goToBenefiaires
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
