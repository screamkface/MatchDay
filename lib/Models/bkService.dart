// services/booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:match_day/components/custom_snackbar.dart';
import 'prenotazione.dart';

class BookingServiceManager with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadBooking({
    required Prenotazione newBooking,
  }) async {
    try {
      await _firestore.collection('prenotazioni').add({
        'dataPrenotazione': newBooking.dataPrenotazione,
        'stato': newBooking.stato.toString(),
        'idCampo': newBooking.idCampo,
        'idUtente': newBooking.idUtente,
      });
      CustomSnackbar("Prenotazione aggiunta con successo!");
    } catch (e) {
      CustomSnackbar("Errore durante l'aggiunta della prenotazione: $e");
    }
  }

  List<DateTimeRange> convertStreamResultToDateTimeRanges({
    required List<Prenotazione> streamResult,
  }) {
    return streamResult.map((prenotazione) {
      return DateTimeRange(
        start: prenotazione.dataPrenotazione,
        end: prenotazione.dataPrenotazione
            .add(const Duration(hours: 1)), // Ad esempio, durata di 1 ora
      );
    }).toList();
  }

  // Metodo per ottenere lo stream delle prenotazioni
  Stream<List<Prenotazione>> getBookingStream({
    required DateTime start,
    required DateTime end,
  }) {
    // Restituisce uno stream di prenotazioni filtrate da Firestore tra start ed end
    return FirebaseFirestore.instance
        .collection(
            'prenotazioni') // Assicurati di usare il percorso corretto della tua collezione
        .where('dataPrenotazione', isGreaterThanOrEqualTo: start)
        .where('dataPrenotazione', isLessThanOrEqualTo: end)
        .snapshots() // Ottiene i dati in tempo reale
        .map((snapshot) {
      // Converte i dati di ogni documento in oggetti Prenotazione
      return snapshot.docs.map((doc) {
        return Prenotazione(
          id: doc.id,
          dataPrenotazione: (doc['dataPrenotazione'] as Timestamp).toDate(),
          stato: Stato.values.firstWhere((e) => e.toString() == doc['stato']),
          idCampo: doc['idCampo'],
          idUtente: doc['idUtente'],
        );
      }).toList();
    });
  }

  // Crea una prenotazione
  Future<void> createPrenotazione(Prenotazione prenotazione) async {
    await _firestore.collection('prenotazioni').add({
      'dataPrenotazione': prenotazione.dataPrenotazione,
      'stato': prenotazione.stato.toString(),
      'idCampo': prenotazione.idCampo,
      'idUtente': prenotazione.idUtente,
    });
  }

  // Modifica una prenotazione
  Future<void> updatePrenotazione(String id, Prenotazione prenotazione) async {
    await _firestore.collection('prenotazioni').doc(id).update({
      'dataPrenotazione': prenotazione.dataPrenotazione,
      'stato': prenotazione.stato.toString(),
      'idCampo': prenotazione.idCampo,
      'idUtente': prenotazione.idUtente,
    });
  }

  // Cancella una prenotazione
  Future<void> deletePrenotazione(String id) async {
    await _firestore.collection('prenotazioni').doc(id).delete();
  }

  // Recupera una prenotazione specifica
  Future<Prenotazione?> getPrenotazione(String id) async {
    DocumentSnapshot doc =
        await _firestore.collection('prenotazioni').doc(id).get();
    if (doc.exists) {
      return Prenotazione(
        id: doc.id,
        dataPrenotazione: (doc['dataPrenotazione'] as Timestamp).toDate(),
        stato: Stato.values.firstWhere((e) => e.toString() == doc['stato']),
        idCampo: doc['idCampo'],
        idUtente: doc['idUtente'],
      );
    }
    return null;
  }
}
