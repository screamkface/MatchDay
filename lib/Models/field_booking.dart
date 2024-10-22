import 'package:flutter/material.dart';

class FieldBooking {
  final String email;
  final String userId;
  final DateTime start;
  final DateTime end;
  final String phoneNumber;
  final String fieldName;

  FieldBooking({
    required this.email,
    required this.userId,
    required this.start,
    required this.end,
    required this.phoneNumber,
    required this.fieldName,
  });

  // Funzione per convertire la prenotazione in un formato mappa (utile per Firebase)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'userId': userId,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'phoneNumber': phoneNumber,
      'fieldName': fieldName,
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
      fieldName: map['fieldName'],
    );
  }
/*
  void onBookingConfirmed(FieldBooking booking) {
    // Salva la prenotazione nel database
    print('Prenotazione confermata: ${booking.fieldName}');
    // Qui puoi integrare il codice per salvare su Firebase
  }

  Future<List<DateTimeRange>> getBookedSlots(
      DateTime start, DateTime end) async {
    // Ottieni le prenotazioni dal database, convertili in slot prenotati
    List<FieldBooking> bookings =
        await fetchBookingsFromDatabase(); // Da implementare
    return bookings
        .map((b) => DateTimeRange(start: b.start, end: b.end))
        .toList();
  }
  */

/*Future<List<FieldBooking>> fetchBookingsFromDatabase() async {
  try {
    // Riferimento alla collezione "bookings" in Firestore
    final CollectionReference bookingsRef = FirebaseFirestore.instance.collection('bookings');

    // Ottiene i documenti dalla collezione
    QuerySnapshot snapshot = await bookingsRef.get();

    // Converte ogni documento in un oggetto FieldBooking
    List<FieldBooking> bookings = snapshot.docs.map((doc) {
      return FieldBooking.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return bookings;
  } catch (e) {
    print("Errore nel recupero delle prenotazioni: $e");
    return [];
  }
}

*/
}
