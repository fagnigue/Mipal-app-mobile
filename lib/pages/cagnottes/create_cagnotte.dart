import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/widgets.dart';

class CreateCagnotte extends StatefulWidget {
  const CreateCagnotte({super.key});

  @override
  State<CreateCagnotte> createState() => _CreateCagnotteState();
}

class _CreateCagnotteState extends State<CreateCagnotte> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _soldeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool canSend = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      setState(() {
        canSend = _titleController.text.isNotEmpty && _titleController.text.length > 3;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _soldeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final balance = double.tryParse(_soldeController.text) ?? 0.0;
      final description = _descriptionController.text;

      print('Title: $title');
      print('Balance: $balance');
      print('Description: $description');
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
                hintText: 'Entrez le solde de départ',
                controller: _soldeController,
                width: MediaQuery.of(context).size.width * 0.8,
                keyboardType: TextInputType.number
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
              AppWidgets.buildValidationButton(
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