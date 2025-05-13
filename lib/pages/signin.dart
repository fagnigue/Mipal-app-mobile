import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/popup.dart';
import 'package:mipal/helpers/widgets.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:mipal/pages/home.dart';
import 'package:mipal/services/storage.dart';
import 'package:mipal/services/user_service.dart';

class SigninPage extends StatefulWidget {
  final String userId;
  final String email;
  const SigninPage({super.key, required this.userId, required this.email});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController villeController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    adresseController.dispose();
    villeController.dispose();
    telephoneController.dispose();
    super.dispose();
  }

  Future<void> saveUser() async {
    if (nomController.text.isEmpty ||
        prenomController.text.isEmpty ||
        adresseController.text.isEmpty ||
        villeController.text.isEmpty ||
        telephoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }
    
    UserService userService = UserService();
    final user = UserProfile(
      id: widget.userId,
      email: widget.email,
      nom: nomController.text,
      prenom: prenomController.text,
      adresse: adresseController.text,
      ville: villeController.text,
      telephone: "+33${telephoneController.text}",
      solde: 0.0,
      numeroCompte: await userService.generateUniqueId(),
    );
    
    await userService.createUserProfile(user);
    final userProfile = await userService.getUserProfileById(user.id!);
    if (userProfile != null) {
      await StorageService().saveUser(userProfile);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      if (mounted) {
        Popup.showError(context, "Erreur lors de la création du profil.");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Inscription'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Informations complémentaires",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            AppWidgets.buildTextField(
                labelText: 'Nom',
                controller: nomController,
                width: fieldWidth,
              ),
            SizedBox(height: 20),
            AppWidgets.buildTextField(
                labelText: 'Prénom',
                controller: prenomController,
                width: fieldWidth,
              ),
            SizedBox(height: 20),
            AppWidgets.buildTextField(
                labelText: 'Adresse',
                controller: adresseController,
                width: fieldWidth,
              ),
            SizedBox(height: 20),
            AppWidgets.buildTextField(
                labelText: 'Ville',
                controller: villeController,
                width: fieldWidth,
              ),
            SizedBox(height: 20),
            _buildPhoneNumberField(telephoneController),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                saveUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                "S'inscrire",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
}


  Widget _buildPhoneNumberField(TextEditingController controller) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Color.fromARGB(104, 255, 255, 255),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            "+33",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 9,
            decoration: InputDecoration(
              counterText: "",
              labelText: "Numéro de téléphone",
              filled: true,
              fillColor: Color(0x68E0E0E0),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
          ),
        ),
      ],
    );
  }
}