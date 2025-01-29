import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:match_day/Providers/prenotazioniProvider.dart';

class TestPrenotazioneProvider extends PrenotazioneProvider {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  TestPrenotazioneProvider({required this.auth, required this.firestore})
      : super();

  @override
  Future<void> modificaPrenotazioneinAnnullata(String id) async {
    try {
      await firestore
          .collection('prenotazioni')
          .doc(id)
          .update({'stato': Stato.annullata.name});
    } catch (e) {
      print("Errore durante l'annullamento della prenotazione $e");
    }
  }

  @override
  Stream<List<Prenotazione>> fetchPrenotazioniUtenteStream() {
    final userId = auth.currentUser!.uid;

    return firestore
        .collection('prenotazioni')
        .where('idUtente', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Prenotazione.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }
}
