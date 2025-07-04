import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/constants.dart';
import 'package:mipal/helpers/popup.dart';
import 'package:mipal/models/cagnotte.dart';
import 'package:mipal/pages/cagnottes/create_cagnotte.dart';
import 'package:mipal/pages/cagnottes/details_cagnotte.dart';
import 'package:mipal/services/cagnotte_service.dart';

class Cagnottes extends StatefulWidget {
  final double? initialAmount;
  const Cagnottes({super.key, required this.initialAmount});

  @override
  State<Cagnottes> createState() => _CagnottesState();
}

class _CagnottesState extends State<Cagnottes> {
  final List<Cagnotte> _cagnottes = [];

  @override
  void initState() {
    super.initState();
    _loadCagnottes();
  }

  _goToCreateCagnotte() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateCagnotte(initialAmount: widget.initialAmount),
      ),
    );
    _loadCagnottes();
  }

  _goToDetailsCagnotte(String cagnotteId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsCagnottePage(cagnotteId: cagnotteId),
      ),
    );
    _loadCagnottes();
  }

  void _loadCagnottes() async {
    try {
      final cagnottes = await CagnotteService().getCagnottes();
      setState(() {
        _cagnottes.clear();
        _cagnottes.addAll(cagnottes);
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
        title: AppConstants.cagnottesPageTitle,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body:
          _cagnottes.isEmpty
              ? Center(
                child: Text(
                  "Pas de cagnottes en cours",
                  style: TextStyle(color: Colors.grey[600], fontSize: 18),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _cagnottes.length,
                itemBuilder: (context, index) {
                  final cagnotte = _cagnottes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 4.0,
                    ),
                    child: ListTile(
                      tileColor: const Color.fromARGB(255, 232, 234, 237),
                      contentPadding: const EdgeInsets.all(2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 40,
                      ),
                      title: Text(cagnotte.titre),
                      subtitle: Text(
                        "Créée le ${_formatDate(cagnotte.createdAt)}\n"
                        "Solde: ${cagnotte.solde} €\n",
                      ),
                      onTap: () {
                        _goToDetailsCagnotte(_cagnottes[index].id);
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        tooltip: 'Créer une Cagnotte',
        onPressed: () {
          _goToCreateCagnotte();
        },
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
