import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/Providers/slotProvider.dart';

class TestFirebaseSlotProvider extends FirebaseSlotProvider {
  late final FirebaseFirestore firestore;

  TestFirebaseSlotProvider({required this.firestore}) : super() {
    this.firestore = firestore;
  }

  @override
  Future<void> updateSlotAsAvailable(
      String idCampo, DateTime date, Slot? slot) async {
    if (slot == null) return;
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final slotDocument = await firestore
          .collection('fields')
          .doc(idCampo)
          .collection('slots')
          .doc(dateString)
          .get();
      if (slotDocument.exists) {
        var slots =
            List<Map<String, dynamic>>.from(slotDocument.data()!['slots']);
        final index = slots.indexWhere((element) => element['id'] == slot.id);
        if (index != -1) {
          slots[index]['disponibile'] = true;
          await firestore
              .collection('fields')
              .doc(idCampo)
              .collection('slots')
              .doc(dateString)
              .update({'slots': slots});
        }
      }
    } catch (e) {
      print('errore durante l aggiornamento: $e');
    }
  }

  @override
  Future<void> updateSlotAsUnavailable(
      String idCampo, DateTime date, Slot? slot) async {
    if (slot == null) return;
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final slotDocument = await firestore
          .collection('fields')
          .doc(idCampo)
          .collection('slots')
          .doc(dateString)
          .get();
      if (slotDocument.exists) {
        var slots =
            List<Map<String, dynamic>>.from(slotDocument.data()!['slots']);
        final index = slots.indexWhere((element) => element['id'] == slot.id);
        if (index != -1) {
          slots[index]['disponibile'] = false;
          await firestore
              .collection('fields')
              .doc(idCampo)
              .collection('slots')
              .doc(dateString)
              .update({'slots': slots});
        }
      }
    } catch (e) {
      print('errore durante l aggiornamento: $e');
    }
  }

  @override
  Future<void> addPrenotazione(Prenotazione prenotazione) async {
    try {
      final docRef = firestore.collection('prenotazioni').doc();
      await docRef.set(prenotazione.toJson());
    } catch (e) {
      print("Errore durante l aggiunta della prenotazione: $e");
    }
  }

  @override
  Stream<List<Slot>> fetchSlotsStream(String idCampo, DateTime date) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    return firestore
        .collection('fields')
        .doc(idCampo)
        .collection('slots')
        .doc(dateString)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          final slots = List<Map<String, dynamic>>.from(data['slots']);
          return slots.map((slotData) => Slot.fromFirestore(slotData)).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    });
  }
}
