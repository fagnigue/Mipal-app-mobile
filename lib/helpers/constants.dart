// Ce fichier contient toutes les constantes utilisées dans l'application

import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';

class AppConstants {
  static const Text appName = Text(
    "MIPAL.",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      letterSpacing: 2.0,
      textBaseline: TextBaseline.alphabetic,
      fontSize: 20,
      color: AppColors.primary,
    ),
  );
  static const String appVersion = '1.0.0';
  static const Text solde = Text(
    "SOLDE ACTUEL",
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );
  static const Text envoyer = Text(
    "Envoyer",
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );
  static const Text depot = Text(
    "Déposer",
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );
  static const Text retirer = Text(
    "Retirer",
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );
  static const Text cagnotte = Text(
    "Cagnotte",
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );
  static const Text service = Text(
    "Service",
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );
  static const Text transactions = Text(
    "TRANSACTIONS",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      letterSpacing: 1.3,
      textBaseline: TextBaseline.alphabetic,
      fontSize: 14,
      color: AppColors.textPrimary,
    ),
  );
}
