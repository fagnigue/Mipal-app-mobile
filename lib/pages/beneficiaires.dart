import 'package:flutter/material.dart';

class BeneficiairesPage extends StatefulWidget {
  @override
  State<BeneficiairesPage> createState() => _BeneficiairesPageState();
}

class _BeneficiairesPageState extends State<BeneficiairesPage> {
  TextEditingController _searchController = TextEditingController();
  final List<String> _allBeneficiaires = [
    'Alice Dupont',
    'Bob Martin',
    'Claire Durand',
    'David Leroy',
    'Emma Petit',
  ];
  List<String> _filteredBeneficiaires = [];

  @override
  void initState() {
    super.initState();
    _filteredBeneficiaires = List.from(_allBeneficiaires);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBeneficiaires = _allBeneficiaires
          .where((b) => b.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bénéficiaires'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher un bénéficiaire',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredBeneficiaires.isEmpty
                ? Center(child: Text('Aucun bénéficiaire trouvé.'))
                : ListView.builder(
                    itemCount: _filteredBeneficiaires.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_filteredBeneficiaires[index]),
                        leading: Icon(Icons.person),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}