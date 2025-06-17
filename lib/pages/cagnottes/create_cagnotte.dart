import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/popup.dart';
import 'package:mipal/helpers/widgets.dart';
import 'package:mipal/services/cagnotte_service.dart';

class CreateCagnotte extends StatefulWidget {
  final double? initialAmount;
  const CreateCagnotte({super.key, required this.initialAmount});

  @override
  State<CreateCagnotte> createState() => _CreateCagnotteState();
}

class _CreateCagnotteState extends State<CreateCagnotte> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  double restant = 0.0;
  bool canSend = false;
  bool titleValid = false;
  bool montantValid = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      setState(() {
        titleValid =
            _titleController.text.isNotEmpty &&
            _titleController.text.length > 3;
        canSend = titleValid && montantValid;
      });
    });

    _montantController.addListener(() {
      setState(() {
        if (_montantController.text.isNotEmpty) {
          double montantValue = double.tryParse(_montantController.text) ?? 0.0;
            restant = double.parse((widget.initialAmount! - montantValue).toStringAsFixed(2));
          montantValid = montantValue > 0 && restant >= 0;
          canSend = titleValid && montantValid;
        }
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _montantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final montantDeBase = double.tryParse(_montantController.text) ?? 0.0;
      final description = _descriptionController.text;

      try {
        setState(() {
          isLoading = true;
        });
        final CagnotteService cagnotteService = CagnotteService();
        await cagnotteService.createCagnotte(title, montantDeBase, description);
        if (mounted) {
          Popup.showSuccess(context, 'Cagnotte créée avec succès');
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Popup.showError(context, 'Erreur lors de la création de la cagnotte');
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une Cagnotte'),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 10),
              AppWidgets.buildTextField(
                labelText: 'Titre',
                hintText: 'Donnez un titre à votre cagnotte',
                controller: _titleController,
                width: MediaQuery.of(context).size.width * 0.8,
              ),
              SizedBox(height: 16),
              AppWidgets.buildTextField(
                labelText: 'Solde (Facultatif)',
                hintText: 'Entrez le montant de départ',
                controller: _montantController,
                width: MediaQuery.of(context).size.width * 0.8,
                keyboardType: TextInputType.number,
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
              SizedBox(height: 16),
              AppWidgets.buildTextField(
                labelText: 'Description (Facultatif)',
                maxLines: 3,
                hintText: 'Entrez ici',
                controller: _descriptionController,
                width: MediaQuery.of(context).size.width * 0.8,
              ),
              SizedBox(height: 30),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : AppWidgets.buildValidationButton(
                    text: 'Créer Cagnotte',
                    onPressed: canSend ? _submitForm : null,
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
