import 'package:mipal/enums/cagnotte_statut.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class Cagnotte {
  final String id;
  final String titre;
  final String? description;
  final DateTime createdAt;
  final double solde;
  final String statut;
  final String code;
  final String? profileId;

  UserProfile? profile;

  Cagnotte({
    required this.id,
    required this.titre,
    this.description,
    required this.createdAt,
    required this.solde,
    required this.statut,
    required this.code,
    this.profile,
    this.profileId,
  });

  factory Cagnotte.create({
    required String titre,
    String? description,
    required String profileId,
    required double solde,
    required String code,
  }) {
    return Cagnotte(
      id: Uuid().v4(),
      titre: titre,
      description: description,
      createdAt: DateTime.now(),
      solde: solde,
      statut: CagnotteStatut.enCours.value,
      code: code,
      profileId: profileId,
    );
  }
  factory Cagnotte.fromJson(Map<String, dynamic> json) {
    return Cagnotte(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      solde: json['solde'].toDouble(),
      statut: json['statut'],
      code: json['code'],
      profileId: json['profile_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'solde': solde,
      'statut': statut,
      'code': code,
      'profile_id': profileId,
    };
  }
}