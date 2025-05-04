import 'package:mipal/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class Transaction {
  final String id;
  final DateTime createdAt;
  final String? from;
  final String? to;
  final double montant;
  final String type;

  UserProfile? fromProfile;
  UserProfile? toProfile;

  Transaction({
    required this.id,
    required this.createdAt,
    required this.from,
    required this.to,
    required this.montant,
    required this.type,
    this.fromProfile,
    this.toProfile,
  });

  
  factory Transaction.create({
    required String from,
    required String to,
    required double montant,
    required String type,
  }) {
    return Transaction(
      id: Uuid().v4(),
      createdAt: DateTime.now(),
      from: from,
      to: to,
      montant: montant,
      type: type,
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
    };
  }

  Transaction.fromMap(Map<String, dynamic> map)
      : id = map['id'].toString(),
        createdAt = DateTime.parse(map['created_at']),
        from = map['from'],
        to = map['to'],
        montant = (map['montant'] as num).toDouble(),
        type = map['type'];
}