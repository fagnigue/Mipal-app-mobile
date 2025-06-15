import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/popup.dart';
import 'package:mipal/helpers/widgets.dart';
import 'package:mipal/models/cagnotte.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:mipal/services/cagnotte_service.dart';
import 'package:mipal/services/storage_service.dart';
import 'package:mipal/services/user_service.dart';

class BeneficiairesPage extends StatefulWidget {
  const BeneficiairesPage({super.key});

  @override
  State<BeneficiairesPage> createState() => _BeneficiairesPageState();
}

class _BeneficiairesPageState extends State<BeneficiairesPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ajouterBeneficiaireController =
      TextEditingController();

  final List<Object> _allBeneficiaires = [];
  List<Object> _filteredBeneficiaires = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBeneficiairesAndCagnottes();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBeneficiaires =
          _allBeneficiaires.where((b) {
            if (b is UserProfile) {
              return "${b.nom}".contains(query) ||
                  "${b.prenom}".contains(query) ||
                  "${b.numeroCompte}".contains(query) ||
                  "${b.telephone}".contains(query);
            } else if (b is Cagnotte) {
              return b.titre.contains(query) || b.code.contains(query);
            }
            return false;
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAjouterBeneficiaireDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text('N°Compte ou N°Cagnotte', style: TextStyle(fontSize: 15)),
          content: AppWidgets.buildTextField(
            controller: _ajouterBeneficiaireController,
            labelText: '',
            prefixIcon: Icons.add,
            width: MediaQuery.of(context).size.width * 1.0,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Fermer"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: Text("Ajouter"),
            ),
          ],
        );
      },
    );

    if (result == true && _ajouterBeneficiaireController.text.isEmpty) {
      Popup.showError(
        context,
        "Veuillez entrer un numéro de compte ou de cagnotte.",
      );
      return;
    }

    if (result == true &&
        _ajouterBeneficiaireController.text.isNotEmpty &&
        _ajouterBeneficiaireController.text.length == 6) {
      await _ajouterBeneficiaire(_ajouterBeneficiaireController.text.trim());
    }

    if (result == true &&
        _ajouterBeneficiaireController.text.isNotEmpty &&
        _ajouterBeneficiaireController.text.length == 7) {
      await _ajouterCagnotte(_ajouterBeneficiaireController.text.trim());
    }
  }

  void _showSupprimerBeneficiaireDialog(Object beneficiaire) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text('Supprimer Bénéficiaire', style: TextStyle(fontSize: 20)),
          content: Text(
            beneficiaire is UserProfile
                ? 'Êtes-vous sûr de vouloir supprimer ${beneficiaire.nom} ${beneficiaire.prenom} ?'
                : beneficiaire is Cagnotte
                ? 'Êtes-vous sûr de vouloir supprimer la cagnotte ${beneficiaire.titre} ?'
                : '',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: Text("Supprimer", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        setState(() => _isLoading = true);
        if (beneficiaire is UserProfile) {
          StorageService().supprimerBeneficiaire(beneficiaire);
        } else if (beneficiaire is Cagnotte) {
          StorageService().supprimerCagnotte(beneficiaire);
        }
        setState(() => _isLoading = false);
        _loadBeneficiairesAndCagnottes();
      } catch (e) {
        if (mounted) {
          Popup.showError(context, "Erreur : $e");
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _loadBeneficiairesAndCagnottes() {
    final beneficiaires = UserService().getBeneficiaires();
    final cagnottes = StorageService().getCagnottes();
    setState(() {
      _allBeneficiaires.clear();
      _allBeneficiaires.addAll(beneficiaires);
      _allBeneficiaires.addAll(cagnottes);
      _filteredBeneficiaires = List.from(_allBeneficiaires);
    });
  }

  Future<void> _ajouterBeneficiaire(String numeroCompte) async {
    try {
      setState(() => _isLoading = true);
      await UserService().ajouterBeneficiaire(
        _ajouterBeneficiaireController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _ajouterBeneficiaireController.clear();
      });
      _loadBeneficiairesAndCagnottes();
    } catch (e) {
      if (mounted) {
        Popup.showError(context, "Erreur : $e");
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _ajouterCagnotte(String numeroCagnotte) async {
    try {
      setState(() => _isLoading = true);
      await CagnotteService().ajouterCagnotte("CAG-$numeroCagnotte");

      setState(() {
        _isLoading = false;
        _ajouterBeneficiaireController.clear();
      });
      _loadBeneficiairesAndCagnottes();
    } catch (e) {
      if (mounted) {
        Popup.showError(context, "Erreur : $e");
        setState(() => _isLoading = false);
      }
    }
  }

  dynamic formatListTile(Object item) {
    if (item is UserProfile) {
      return ListTile(
        title: Text("${item.nom} ${item.prenom}"),
        leading: Icon(Icons.person),
        subtitle: Text("${item.numeroCompte}"),
        onTap: () {
          Navigator.pop(context, item);
        },
        onLongPress: () => _showSupprimerBeneficiaireDialog(item),
      );
    }
    if (item is Cagnotte) {
      return ListTile(
        title: Text(item.titre),
        leading: Icon(Icons.account_balance_wallet),
        subtitle: Text(item.code),
        onTap: () {
          Navigator.pop(context, item);
        },
        onLongPress: () => _showSupprimerBeneficiaireDialog(item),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Bénéficiaires'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: AppWidgets.buildTextField(
              controller: _searchController,
              labelText: 'Rechercher un bénéficiaire',
              prefixIcon: Icons.search,
              width: MediaQuery.of(context).size.width * 0.9,
            ),
          ),
          TextButton(
            onPressed: _showAjouterBeneficiaireDialog,
            child: Text('Ajouter un bénéficiaire ou une cagnotte'),
          ),
          _isLoading ? CircularProgressIndicator() : SizedBox.shrink(),
          Expanded(
            child:
                _filteredBeneficiaires.isEmpty
                    ? Center(child: Text('Aucun bénéficiaire trouvé.'))
                    : ListView.builder(
                      itemCount: _filteredBeneficiaires.length,
                      itemBuilder: (context, index) {
                        return formatListTile(_filteredBeneficiaires[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
