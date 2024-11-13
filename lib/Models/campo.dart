import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Campo {
  final String id;
  final String nome;

  Campo({
    required this.id,
    required this.nome,
  });

  factory Campo.fromMap(Map<String, dynamic> map) {
    return Campo(
      id: map['id'],
      nome: map['nome'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
    };
  }

  factory Campo.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Campo(
      nome: data['nome'] ?? '',
      id: doc.id, // Usa l'ID del documento come identificatore del campo
    );
  }

  Future<void> createCampoWithBookingSlots(
      String nomeCampo, String indirizzoCampo) async {
    // Riferimento alla collezione "fields"
    DocumentReference campoRef =
        await FirebaseFirestore.instance.collection('fields').add({
      'nome': nomeCampo,
      'indirizzo': indirizzoCampo,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Intervallo di orari per la prenotazione, ad esempio dalle 9:00 alle 18:00
    DateTime start =
        DateTime.now().add(const Duration(days: 1)); // A partire da domani
    DateTime end =
        start.add(const Duration(days: 7)); // Per i prossimi 7 giorni

    // Creiamo gli slot ogni ora tra le 9:00 e le 18:00 per i 7 giorni successivi
    List<DateTimeRange> slots =
        generateTimeSlots(start: start, end: end, startHour: 9, endHour: 18);

    // Aggiungiamo gli slot prenotabili al database, associandoli al campo appena creato
    for (var slot in slots) {
      await FirebaseFirestore.instance.collection('bookings').add({
        'campoId': campoRef.id,
        'start': slot.start.toIso8601String(),
        'end': slot.end.toIso8601String(),
        'isBooked': false, // Slot inizialmente disponibile
      });
    }
  }

  List<DateTimeRange> generateTimeSlots(
      {required DateTime start,
      required DateTime end,
      required int startHour,
      required int endHour}) {
    List<DateTimeRange> slots = [];
    DateTime current = start;

    while (current.isBefore(end)) {
      for (int hour = startHour; hour < endHour; hour++) {
        DateTime slotStart =
            DateTime(current.year, current.month, current.day, hour);
        DateTime slotEnd = slotStart.add(const Duration(hours: 1));
        slots.add(DateTimeRange(start: slotStart, end: slotEnd));
      }
      current = current.add(const Duration(days: 1));
    }

    return slots;
  }
}
