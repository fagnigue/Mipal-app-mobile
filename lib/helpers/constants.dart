// Ce fichier contient toutes les constantes utilisées dans l'application

import 'package:flutter/material.dart';

class AppConstants {
  static const Text appName = Text(
          "MIPAL.",
          style: TextStyle(
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        textBaseline: TextBaseline.alphabetic,
        fontSize: 20,
        color: const Color.fromARGB(255, 0, 0, 0),
          ),
        );
  static const String appVersion = '1.0.0';
}