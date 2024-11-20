import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';

class PrenotazioneProvider extends ChangeNotifier {
  List<Prenotazione> _prenotazioni = [];

  List<Prenotazione> get prenotazioni => _prenotazioni;

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

      notifyListeners();
    } catch (e) {
      print('Error fetching prenotazioni: $e');
    }
  }

  Future<void> ripristinaSlotDisponibile(
      String campoId, String data, Slot slot) async {
    try {
      final documentPath = 'fields/$campoId/calendario/$data';

      DocumentSnapshot calendarioDoc =
          await FirebaseFirestore.instance.doc(documentPath).get();

      if (!calendarioDoc.exists) {
        print('Documento calendario non trovato per la data $data');
        return;
      }

      Map<String, dynamic> calendarioData =
          calendarioDoc.data() as Map<String, dynamic>;
      List<dynamic> slotsList = calendarioData['slots'];

      // Trova lo slot per ID e aggiorna la disponibilità
      for (var slotItem in slotsList) {
        if (slotItem['id'] == slot.id) {
          slotItem['disponibile'] = true;
          await FirebaseFirestore.instance.doc(documentPath).update({
            'slots': slotsList,
          });
          print('Slot ripristinato come disponibile con successo');
          return;
        }
      }

      print('Slot non trovato nel calendario');
    } catch (e) {
      throw Exception(
          'Errore nel ripristinare la disponibilità dello slot: $e');
    }
  }

  // 3. Aggiornare lo stato di una prenotazione
  Future<void> aggiornaPrenotazione(
      String prenotazioneId, Stato nuovoStato) async {
    try {
      await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(prenotazioneId)
          .update({'stato': nuovoStato.toString().split('.').last});

      final index = _prenotazioni.indexWhere((p) => p.id == prenotazioneId);
      if (index != -1) {
        Prenotazione prenotazione = _prenotazioni[index];

        // Aggiorna lo stato nella lista locale
        _prenotazioni[index] = Prenotazione(
          id: prenotazione.id,
          dataPrenotazione: prenotazione.dataPrenotazione,
          stato: nuovoStato,
          idCampo: prenotazione.idCampo,
          idUtente: prenotazione.idUtente,
          slot: prenotazione.slot,
        );

        if (nuovoStato == Stato.annullata && prenotazione.slot != null) {
          await ripristinaSlotDisponibile(prenotazione.idCampo,
              prenotazione.dataPrenotazione, prenotazione.slot!);
        }

        notifyListeners();
      }
    } catch (e) {
      print('Errore durante l\'aggiornamento della prenotazione: $e');
    }
  }

  // Funzione per recuperare lo slot
  Future<Slot?> _recuperaSlot(String campoId, String dataPrenotazione) async {
    try {
      final documentPath = 'fields/$campoId/calendario/$dataPrenotazione';

      DocumentSnapshot calendarioDoc =
          await FirebaseFirestore.instance.doc(documentPath).get();

      if (!calendarioDoc.exists) {
        print('Nessun calendario trovato per questa data');
        return null;
      }

      Map<String, dynamic> calendarioData =
          calendarioDoc.data() as Map<String, dynamic>;
      List<dynamic> slotsList = calendarioData['slots'];

      // Supponendo che 'id' sia unico per lo slot
      final slotData = slotsList.firstWhere(
          (slot) => slot['data'] == dataPrenotazione,
          orElse: () => null);

      return slotData != null ? Slot.fromFirestore(slotData) : null;
    } catch (e) {
      print('Errore nel recupero dello slot: $e');
      return null;
    }
  }

  // 4. Eliminare una prenotazione
  Future<void> eliminaPrenotazione(String prenotazioneId) async {
    try {
      await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(prenotazioneId)
          .delete();

      // Rimuovi la prenotazione dalla lista locale
      _prenotazioni.removeWhere((p) => p.id == prenotazioneId);
      notifyListeners(); // Notifica i listener dopo aver eliminato una prenotazione
    } catch (e) {
      print('Errore durante l\'eliminazione della prenotazione: $e');
    }
  }
}
