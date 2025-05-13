import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/pages/cagnottes/create_cagnotte.dart';

class Cagnottes extends StatefulWidget {
  const Cagnottes({super.key});

  @override
  State<Cagnottes> createState() => _CagnottesState();
}

class _CagnottesState extends State<Cagnottes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cagnottes'),
        backgroundColor: AppColors.background
      ),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.monetization_on),
            title: Text('Cagnotte ${index + 1}'),
            subtitle: const Text('Description de la cagnotte'),
            onTap: () {
              // Action lors du clic sur une cagnotte
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        tooltip: 'Créer une Cagnotte',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCagnotte(),
            ),
          );
        },
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}