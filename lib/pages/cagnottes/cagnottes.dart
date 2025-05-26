import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/popup.dart';
import 'package:mipal/models/cagnotte.dart';
import 'package:mipal/pages/cagnottes/create_cagnotte.dart';
import 'package:mipal/services/cagnotte_service.dart';

class Cagnottes extends StatefulWidget {
  final double? initialAmount;
  const Cagnottes({super.key, required this.initialAmount});

  @override
  State<Cagnottes> createState() => _CagnottesState();
}

class _CagnottesState extends State<Cagnottes> {
  List<Cagnotte>? _cagnottes;
  

  @override
  void initState() {
    super.initState();
    _loadCagnottes();
  }

  void goToCreateCagnotte() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCagnotte(initialAmount: widget.initialAmount),
      ),
    );
    _loadCagnottes();
  }


  void _loadCagnottes() async {
    try {
      final cagnottes = await CagnotteService().getCagnottes();
      setState(() {
        _cagnottes = cagnottes;
      });
    } catch (e) {
      if (mounted) {
        Popup.showError(context, "Erreur lors du chargement des cagnottes");
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cagnottes'),
        backgroundColor: AppColors.background
      ),
      backgroundColor: AppColors.background,
      body: _cagnottes == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _cagnottes!.length,
              itemBuilder: (context, index) {
                final cagnotte = _cagnottes![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                  child: ListTile(
                    tileColor: const Color.fromARGB(255, 232, 234, 237),
                    contentPadding: const EdgeInsets.all(2.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: const Icon(Icons.account_balance_wallet_rounded, size: 40,),
                    title: Text(cagnotte.titre),
                    subtitle: Text(
                      "Créée le ${_formatDate(cagnotte.createdAt!)}\n"
                      "Solde: ${cagnotte.solde} €\n"
                    ),
                    onTap: () {
                      // Action lors du clic sur une cagnotte
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        tooltip: 'Créer une Cagnotte',
        onPressed: () {
          goToCreateCagnotte();
        },
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}