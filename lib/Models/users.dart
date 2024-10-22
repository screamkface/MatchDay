import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String userId;
  final String email;
  final String phone;
  final String role;
  final String nome;
  final String cognome;

  Users({
    required this.userId,
    required this.email,
    required this.phone,
    required this.role,
    required this.nome,
    required this.cognome,
  });

  factory Users.fromDocument(DocumentSnapshot doc) {
    return Users(
      role: doc['Ruolo'] ?? '',
      email: doc['email'] ?? '',
      userId: doc['user-id'] ?? '',
      phone: doc['phone'] ?? '',
      nome: doc['nome'] ?? '',
      cognome: doc['cognome'] ?? '',
    );
  }
}
