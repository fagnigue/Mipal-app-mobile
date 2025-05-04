import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/constants.dart';
import 'package:mipal/main.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:mipal/pages/login.dart';
import 'package:mipal/services/storage.dart';
import 'package:mipal/services/user_service.dart';

class ProfilePage extends StatelessWidget {
  final UserProfile userProfile;

  final userService = UserService();

  ProfilePage({super.key, required this.userProfile});

  _googleSignOut(BuildContext context) async {
    await StorageService().clearUser();
    await supabase.auth.signOut().then((value) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }).catchError((error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la déconnexion.")),
        );
        
      }
    });
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: AppConstants.appName,
      ),
      body: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://www.w3schools.com/howto/img_avatar.png'),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProfile.nom!,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userProfile.prenom!,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userProfile.numeroCompte!,
                    style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 41, 41, 41)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Mes informations',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              _googleSignOut(context);
            },
            child: const Text(
              'Deconnexion',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          )
        ],
      ),
    );
  }
}