import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/widgets.dart';
import 'package:mipal/main.dart';
import 'package:mipal/services/transaction_service.dart';

class AddTransactionPage extends StatefulWidget {
  final double? initialBalance;
  const AddTransactionPage({super.key, required this.initialBalance});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TransactionService transactionService = TransactionService();
  bool canDeposit = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {
        double amountValue = double.tryParse(_amountController.text) ?? 0.0;
        canDeposit = amountValue > 0;
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _deposit() async {
    if (_formKey.currentState!.validate()) {
      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      try {
        final currentUser = supabase.auth.currentUser;
        if (currentUser != null) {
          await transactionService.createDeposit(currentUser.id, amount);
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Dépôt de $amount € effectué avec succès",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Erreur lors du dépôt: $e",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Effectuer un dépôt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppWidgets.buildTextField(
                labelText: 'Montant du dépôt',
                hintText: 'Entrez le montant à déposer',
                controller: _amountController,
                width: MediaQuery.of(context).size.width * 0.8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Veuillez entrer un montant valide supérieur à 0';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                prefixIcon: Icons.euro_symbol_rounded,
              ),
              SizedBox(height: 16),
              Text(
                'Solde actuel: ${widget.initialBalance} €',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 30),
              AppWidgets.buildValidationButton(
                text: 'Déposer',
                onPressed: canDeposit ? _deposit : null,
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