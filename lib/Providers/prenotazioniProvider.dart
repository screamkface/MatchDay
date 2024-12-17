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
    await _prenotazioniDao.rifiutaPrenotazione(prenotazioneId, campoId, slotId, dataPrenotazione);
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

  // Metodo per modificare una prenotazione
  void modificaPrenotazione(
      String id, String dataPrenotazioneString, String selectedSlot) {
    _prenotazioniDao.modificaPrenotazione(id, dataPrenotazioneString, selectedSlot);
  }
}
