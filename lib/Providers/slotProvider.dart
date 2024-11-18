import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Aggiungi questa importazione per ChangeNotifier
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';

class FirebaseSlotProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _prenotazioniRef =
      FirebaseFirestore.instance.collection('prenotazioni');
  final CollectionReference _campiRef =
      FirebaseFirestore.instance.collection('fields');

  List<Slot> _selectedSlots = [];

  List<Slot> get selectedSlots => _selectedSlots;

  final List<Slot> _slots = []; // Stato interno
  List<Slot> get slots => _slots;

  // Aggiungi una prenotazione
  Future<void> addPrenotazione(Prenotazione prenotazione) async {
    await _prenotazioniRef.doc(prenotazione.id).set(prenotazione.toMap());
    notifyListeners(); // Notifica le modifiche
  }

  Stream<List<Slot>> fetchSlotsStream(String campoId, DateTime selectedDay) {
    final formattedDate = _formatDate(selectedDay);

    return _firestore
        .collection('fields')
        .doc(campoId)
        .collection('calendario')
        .doc(formattedDate)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        List<dynamic> slotData = snapshot['slots'];
        return slotData.map((data) => Slot.fromMap(data)).toList();
      } else {
        return [];
      }
    });
  }

  // Aggiorna lo slot su Firebase per renderlo non disponibile
  Future<void> updateSlotAvailability(
      String campoId, DateTime data, Slot slot) async {
    if (campoId.isEmpty) {
      throw Exception("L'ID del campo non può essere vuoto");
    }

    try {
      final documentPath =
          'fields/$campoId/slots/${data.toIso8601String()}_${slot.orario}';

      await FirebaseFirestore.instance.doc(documentPath).update(slot.toMap());
    } catch (e) {
      throw Exception('Errore nell\'aggiornare lo slot: $e');
    }
  }

  // Metodo per recuperare gli slot da Firebase per una data specifica
  Future<void> fetchSlots(String campoId, DateTime selectedDay) async {
    final formattedDate = _formatDate(selectedDay);

    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('fields')
          .doc(campoId)
          .collection('calendario')
          .doc(formattedDate)
          .get();

      if (snapshot.exists) {
        List<dynamic> slotData = snapshot['slots'];
        _selectedSlots = slotData.map((data) => Slot.fromMap(data)).toList();
      } else {
        _selectedSlots = [];
      }
      notifyListeners(); // Notifica i listener dopo aver aggiornato gli slot
    } catch (e) {
      throw Exception('Errore nel recupero degli slot: $e');
    }
  }

  // Metodo per aggiungere uno slot su Firebase
  Future<void> addSlot(String campoId, DateTime selectedDay, Slot slot) async {
    if (campoId.isEmpty) {
      throw Exception("L'ID del campo non può essere vuoto");
    }

    final formattedDate = _formatDate(selectedDay);

    try {
      await _firestore
          .collection('fields')
          .doc(campoId)
          .collection('calendario')
          .doc(formattedDate)
          .set({
        'slots': FieldValue.arrayUnion([slot.toMap()])
      }, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      throw Exception('Errore nell\'aggiungere lo slot: $e');
    }
  }

  DateTime _parseSlotTime(String orario) {
    // Supponiamo che l'orario sia nel formato 'HH:mm - HH:mm' (es. '10:00 - 11:00')
    final startTime = orario.split(' - ')[0];
    final now = DateTime.now();

    final timeParts = startTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // Metodo per eliminare tutti gli slot di giorni passati
  Future<void> removePastSlots(String campoId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('fields')
          .doc(campoId)
          .collection('calendario')
          .get();

      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        DateTime slotDate =
            DateTime.parse(doc.id); // ID del documento è 'yyyy-mm-dd'

        // Se la data è passata, elimina tutti gli slot del giorno
        if (slotDate.isBefore(DateTime(now.year, now.month, now.day))) {
          await doc.reference.delete();
        } else if (slotDate
            .isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
          // Se è il giorno corrente, controlla l'orario degli slot
          List<dynamic> slots = doc['slots'];

          List<dynamic> updatedSlots = [];

          for (var slotData in slots) {
            final slot = Slot.fromMap(slotData);

            // Confronta l'orario dello slot con l'orario attuale
            final slotTime = _parseSlotTime(
                slot.orario); // Funzione per ottenere l'orario dello slot

            if (slotTime.isAfter(now)) {
              updatedSlots.add(
                  slotData); // Mantieni gli slot che non sono ancora passati
            }
          }

          // Se ci sono ancora slot per la giornata, aggiorna il documento
          if (updatedSlots.isNotEmpty) {
            await doc.reference.update({'slots': updatedSlots});
          } else {
            // Altrimenti elimina tutto il documento se non ci sono slot validi
            await doc.reference.delete();
          }
        }
      }
      notifyListeners(); // Notifica le modifiche
    } catch (e) {
      throw Exception('Errore nel rimuovere gli slot di giorni passati: $e');
    }
  }

  // Metodo per rimuovere uno slot da Firebase
  Future<void> removeSlot(
      String campoId, DateTime selectedDay, Slot slot) async {
    final formattedDate = _formatDate(selectedDay);

    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('fields')
          .doc(campoId)
          .collection('calendario')
          .doc(formattedDate)
          .get();

      if (snapshot.exists) {
        List<dynamic> slots = snapshot['slots'];

        // Rimuovi lo slot corrispondente
        slots.removeWhere((s) => s['orario'] == slot.orario);

        // Aggiorna il documento su Firebase con lo slot rimosso
        await _firestore
            .collection('fields')
            .doc(campoId)
            .collection('calendario')
            .doc(formattedDate)
            .update({
          'slots': slots,
        });
        notifyListeners(); // Notifica le modifiche
      }
    } catch (e) {
      throw Exception('Errore nel rimuovere lo slot: $e');
    }
  }

  // Metodo per aggiornare la disponibilità di uno slot su Firebase
  Future<void> updateSlot(
      String campoId, DateTime selectedDay, Slot slot) async {
    if (campoId.isEmpty) {
      throw Exception("L'ID del campo non può essere vuoto");
    }

    final formattedDate = _formatDate(selectedDay);

    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('fields')
          .doc(campoId)
          .collection('calendario')
          .doc(formattedDate)
          .get();

      if (snapshot.exists) {
        List<dynamic> slots = snapshot['slots'];

        for (var i = 0; i < slots.length; i++) {
          if (slots[i]['orario'] == slot.orario) {
            slots[i]['disponibile'] = slot.disponibile;
          }
        }

        await _firestore
            .collection('fields')
            .doc(campoId)
            .collection('calendario')
            .doc(formattedDate)
            .update({
          'slots': slots,
        });
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Errore nell\'aggiornare lo slot: $e');
    }
  }

  // Metodo per formattare la data in formato 'yyyy-mm-dd'
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }
}
