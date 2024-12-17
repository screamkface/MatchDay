import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/components/custom_snackbar.dart';

class PrenotazioniDao {
  List<Prenotazione> _prenotazioni = [];

  List<Prenotazione> get prenotazioni => _prenotazioni;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Recuperare tutte le prenotazioni
  Future<void> fetchPrenotazioni() async {
    try {
      // Fetch the data from Firebase or any API
      final snapshot =
          await FirebaseFirestore.instance.collection('prenotazioni').get();

      // Ensure you map the snapshot correctly into your data model
      _prenotazioni = snapshot.docs
          .map((doc) => Prenotazione.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching prenotazioni: $e');
    }
  }
}
