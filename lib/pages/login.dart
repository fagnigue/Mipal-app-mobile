import 'package:flutter/material.dart';
import 'package:mipal/main.dart';
import 'package:mipal/pages/home.dart';
import 'package:mipal/pages/signin.dart';
import 'package:mipal/services/storage.dart';
import 'package:mipal/services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
 
  
  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {

  @override
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) async {
      if (data.session != null) {
        final userId = data.session!.user.id;
        final userProfile = await UserService().getUserProfileById(userId);
        if (userProfile != null) {
          await StorageService().saveUser(userProfile);
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SigninPage(userId: userId, email: data.session!.user.email!)),
            );
          }
        }
    }});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/mipal-logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                UserService().googleSignIn(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                  'assets/images/google.png',
                  width: 25,
                  height: 25,
                  ),
                  SizedBox(width: 8),
                  Text("S'identifier avec Google"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}