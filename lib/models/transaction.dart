import 'package:mipal/models/cagnotte.dart';
import 'package:mipal/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class Transaction {
  final String id;
  final DateTime createdAt;
  final String? from;
  final String? to;
  final double montant;
  final String type;
  final String? cagnotteId;
  final String? description;
  UserProfile? fromProfile;
  UserProfile? toProfile;
  Cagnotte? cagnotte;

  Transaction({
    required this.id,
    required this.createdAt,
    required this.from,
    required this.to,
    required this.montant,
    required this.type,
    required this.description,
    this.fromProfile,
    this.toProfile,
    this.cagnotteId,
    this.cagnotte,
  });

  
  factory Transaction.create({
    String? from,
    String? to,
    required double montant,
    required String type,
    String? cagnotteId,
    String? description,
  }) {
    return Transaction(
      id: Uuid().v4(),
      createdAt: DateTime.now(),
      from: from,
      to: to,
      montant: montant,
      type: type,
      cagnotteId: cagnotteId,
      description: description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'from': from,
      'to': to,
      'montant': montant,
      'type': type,
      'cagnotte_id': cagnotteId,
      'description': description,
    };
  }

  Transaction.fromMap(Map<String, dynamic> map)
      : id = map['id'].toString(),
        createdAt = DateTime.parse(map['created_at']),
        from = map['from'],
        to = map['to'],
        montant = (map['montant'] as num).toDouble(),
        type = map['type'],
        description = map['description'],
        cagnotteId = map['cagnotte_id'];
}