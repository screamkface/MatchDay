import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:match_day/DAO/prenotazioniDao.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';

class PrenotazioneProvider extends ChangeNotifier {
  final PrenotazioniDao _prenotazioniDao = PrenotazioniDao();

  // 1. Recuperare tutte le prenotazioni
  Future<void> fetchPrenotazioni() async {
    await _prenotazioniDao.fetchPrenotazioni();
    notifyListeners();
  }

  Stream<List<Prenotazione>> fetchPrenotazioniStream() {
    return _prenotazioniDao.fetchPrenotazioniStream();
  }

  Future<void> rifiutaPrenotazione(String prenotazioneId, String campoId,
      String slotId, String dataPrenotazione) async {
    await _prenotazioniDao.rifiutaPrenotazione(
        prenotazioneId, campoId, slotId, dataPrenotazione);
    notifyListeners();
  }

  Stream<List<Prenotazione>> fetchPrenotazioniStreamByUser(String userId) {
    return _prenotazioniDao.fetchPrenotazioniStreamByUser(userId);
  }

  // 3. Aggiornare lo stato di una prenotazione
  Future<void> aggiornaPrenotazione(
      String prenotazioneId, Stato nuovoStato) async {
    await _prenotazioniDao.aggiornaPrenotazione(prenotazioneId, nuovoStato);
    notifyListeners();
  }

  // Funzione per recuperare lo slot
  Future<Slot?> recuperaSlot(String campoId, String dataPrenotazione) async {
    await _prenotazioniDao.recuperaSlot(campoId, dataPrenotazione);
    return null;
  }

  // 4. Eliminare una prenotazione
  Future<void> eliminaPrenotazione(String prenotazioneId) async {
    await _prenotazioniDao.eliminaPrenotazione(prenotazioneId);
    notifyListeners();
  }

  Future<void> accettaPrenotazione(String prenotazioneId) async {
    await _prenotazioniDao.accettaPrenotazione(prenotazioneId);
    notifyListeners();
  }

  Future<void> modificaPrenotazione(
      String id,
      String dataPrenotazioneString,
      Slot selectedSlot,
      String idCampoPrecedente,
      String slotPrecedenteId) async {
    await _prenotazioniDao.modificaPrenotazioneConSlot(
        id,
        dataPrenotazioneString,
        selectedSlot,
        idCampoPrecedente,
        slotPrecedenteId);
    notifyListeners();
  }

  Future<void> modificaPrenotazioneinAnnullata(
    String idPrenotazione,
  ) async {
    _prenotazioniDao.modificaPrenotazioneinAnnullata(idPrenotazione);
    notifyListeners();
  }

  Future<void> rifiutaModificaPrenotazione(String id) async {
    await _prenotazioniDao.rifiutaModificaPrenotazione(id);
    notifyListeners();
  }

  Future<void> accettaModificaPrenotazione(String id, String idCampo,
      String slotId, String dataPrenotazione, String orarioSlot) async {
    await _prenotazioniDao.accettaModificaPrenotazione(
        id, idCampo, slotId, dataPrenotazione, orarioSlot);
    notifyListeners();
  }

  Stream<List<Prenotazione>> fetchPrenotazioniConfermate() {
    return FirebaseFirestore.instance
        .collection('prenotazioni')
        .where('stato', isEqualTo: Stato.confermata.toString().split('.').last)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Prenotazione.fromFirestore(doc);
      }).toList();
    });
  }
}
