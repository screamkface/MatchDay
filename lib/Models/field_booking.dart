import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FieldBooking {
  final String email;
  final String userId;
  final DateTime start;
  final DateTime end;
  final String phoneNumber;
  final String fieldId; // Aggiungi questo campo

  FieldBooking({
    required this.email,
    required this.userId,
    required this.start,
    required this.end,
    required this.phoneNumber,
    required this.fieldId,
  });

  // Funzione per convertire la prenotazione in un formato mappa (utile per Firebase)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'userId': userId,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'phoneNumber': phoneNumber,
      'fieldId': fieldId, // Aggiungi questo campo alla mappa
    };
  }

  // Funzione per creare una prenotazione da una mappa
  factory FieldBooking.fromMap(Map<String, dynamic> map) {
    return FieldBooking(
      email: map['email'],
      userId: map['userId'],
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
      phoneNumber: map['phoneNumber'],
      fieldId: map['fieldId'], // Aggiungi qui per la conversione dalla mappa
    );
  }
}

Future<List<FieldBooking>> fetchBookingsFromDatabase(String fieldId) async {
  try {
    final CollectionReference bookingsRef =
        FirebaseFirestore.instance.collection('bookings');

    // Filtra le prenotazioni per l'ID del campo
    QuerySnapshot snapshot =
        await bookingsRef.where('fieldId', isEqualTo: fieldId).get();

    List<FieldBooking> bookings = snapshot.docs.map((doc) {
      return FieldBooking.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return bookings;
  } catch (e) {
    print("Errore nel recupero delle prenotazioni: $e");
    return [];
  }
}
