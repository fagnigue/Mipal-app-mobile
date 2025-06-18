# MIPAL
<p>
    <img src="https://fkpsfgtycmsvgouzattt.supabase.co/storage/v1/object/public/assets/images/mipal-splashscreen.jpg" alt="Splashscreen MIPAL" width="200"/>
    <img src="https://fkpsfgtycmsvgouzattt.supabase.co/storage/v1/object/public/assets/images/mipal-signin-page.jpg" alt="Page de connexion MIPAL" width="200"/>
    <img src="https://fkpsfgtycmsvgouzattt.supabase.co/storage/v1/object/public/assets/images/mipal-home-page.jpg" alt="Page d'accueil MIPAL" width="200"/>
</p>


MIPAL est une application Flutter de gestion d'argent entre particuliers, permettant d'envoyer, recevoir, déposer de l'argent, et de gérer des cagnottes collaboratives. L'application utilise Supabase pour l'authentification et la gestion des données, ainsi qu'un stockage local pour certaines informations utilisateur.

## Fonctionnalités principales

- **Authentification** :
  - Inscription et connexion par email/mot de passe
  - Connexion via Google
    > ⚠️ **Attention !**
    > En environnement de développement, la connexion avec Google peut ne pas fonctionner en raison de la configuration du SHA dans la console Google. Le SHA étant unique à chaque ordinateur, la compilation de l'application sur une autre machine empêchera l'utilisation de Google Sign-In tant que le SHA correspondant n'aura pas été ajouté à la configuration Google Auth.
  - Gestion de session et déconnexion

- **Gestion du profil** :
  - Affichage et modification des informations personnelles
  - Visualisation du solde actuel

- **Transactions** :
  - Envoi d'argent à un autre utilisateur
  - Réception d'argent
  - Dépôt d'argent sur son propre compte
  - Consultation de l'historique des transactions
  - Détail d'une transaction

- **Cagnottes** :
  - Création de cagnottes (fonds communs)
  - Ajout de cagnottes existantes via un code
  - Dépôt d'argent dans une cagnotte
  - Visualisation et gestion des cagnottes

- **Bénéficiaires** :
  - Ajout/suppression de bénéficiaires (utilisateurs ou cagnottes)
  - Recherche et gestion des bénéficiaires

- **Stockage local** :
  - Conservation du profil utilisateur, des bénéficiaires et des cagnottes pour un accès rapide

## Structure du projet

```bash
lib/
├── main.dart                # Point d'entrée de l'application, initialisation Supabase et navigation principale
├── helpers/                 # Fichiers utilitaires (couleurs, constantes, widgets, popups, etc.)
├── models/                  # Modèles de données (UserProfile, Transaction, Cagnotte, etc.)
├── services/                # Services métier (auth, utilisateur, transaction, cagnotte, stockage local)
└── pages/
  ├── auth/                # Pages d'authentification (login, signup, register)
  ├── cagnottes/           # Pages liées aux cagnottes (liste, création, détails)
  ├── transactions/        # Pages liées aux transactions (envoi, dépôt, détails)
  ├── home.dart            # Page d'accueil (solde, actions principales, liste des transactions)
  ├── profile.dart         # Page de profil utilisateur
  └── beneficiaires.dart   # Page de gestion des bénéficiaires

assets/
├── images/                  # Images utilisées dans l'application
└── icons/                   # Icônes personnalisées
```

## Technologies utilisées
- **Flutter** (Dart)
- **Supabase** (authentification, base de données)
- **localstorage** (stockage local)
- **Google Sign-In** 

## Lancement du projet
1. Cloner le dépôt
2. Installer les dépendances :
   ```
   flutter pub get
   ```
3. Configurer les variables d'environnement dans `.env` (voir `lib/helpers/env_vars.dart`)
4. Lancer l'application :
   ```
   flutter run
   ```

## Auteur
Projet réalisé dans le cadre d'un Master 1 - Développement mobile.
- COULIBALY N'Djo-Soro
- ABDRAMAN Abakar
