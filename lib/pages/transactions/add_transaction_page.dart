import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/popup.dart';
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
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
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
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _deposit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      final String description = _descriptionController.text.trim();
      try {
        final currentUser = supabase.auth.currentUser;
        if (currentUser != null) {
          await TransactionService().createDeposit(
            currentUser.id,
            amount,
            description: description.isNotEmpty ? description : null,
          );
          if (mounted) {
            Navigator.of(context).pop();
            Popup.showSuccess(
              context,
              "Dépôt de $amount € effectué avec succès",
            );
          }
        } else {
          throw Exception('Aucun utilisateur connecté');
        }
      } catch (e) {
        if (mounted) {
          Popup.showError(
            context,
            "Erreur lors du dépôt: $e",
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Effectuer un dépôt'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
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
                const SizedBox(height: 16),
                AppWidgets.buildTextField(
                  labelText: 'Description (facultatif)',
                  hintText: 'Entrez une description pour ce dépôt',
                  controller: _descriptionController,
                  width: MediaQuery.of(context).size.width * 0.8,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icons.description,
                ),
                const SizedBox(height: 16),
                Text(
                  'Solde actuel: ${widget.initialBalance ?? 0.0} €',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 30),
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
      ),
    );
  }
}