import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';
import 'package:mipal/helpers/widgets.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
              MaterialPageRoute(
                builder: (context) =>
                    SigninPage(userId: userId, email: data.session!.user.email!),
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/mipal-logo.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppWidgets.buildTextField(
                      labelText: 'E-mail',
                      hintText: 'Entrez votre e-mail',
                      controller: _emailController,
                      width: MediaQuery.of(context).size.width * 0.8,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un e-mail';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Veuillez entrer un e-mail valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppWidgets.buildTextField(
                      labelText: 'Mot de passe',
                      hintText: 'Entrez votre mot de passe',
                      controller: _passwordController,
                      width: MediaQuery.of(context).size.width * 0.8,
                      keyboardType: TextInputType.text,
                      prefixIcon: Icons.lock,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AppWidgets.buildValidationButton(
                      text: 'Se connecter',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await UserService().signInWithEmail(
                            context,
                            _emailController.text,
                            _passwordController.text,
                          );
                        }
                      },
                      color: AppColors.primary,
                      textColor: Colors.white, width: MediaQuery.of(context).size.width * 0.8,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await UserService().signUpWithEmail(
                            context,
                            _emailController.text,
                            _passwordController.text,
                          );
                        }
                      },
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ou',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await UserService().googleSignIn(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Erreur lors de la connexion Google: $e"),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/google.png',
                      width: 25,
                      height: 25,
                    ),
                    const SizedBox(width: 8),
                    const Text("S'identifier avec Google"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}