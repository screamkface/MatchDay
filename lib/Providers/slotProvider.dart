import 'package:flutter/material.dart'; // Aggiungi questa importazione per ChangeNotifier
import 'package:match_day/DAO/slotDao.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';

class FirebaseSlotProvider extends ChangeNotifier {
  final SlotDao _slotDao = SlotDao();

  // Aggiungi una prenotazione
  Future<void> addPrenotazione(Prenotazione prenotazione) async {
    await _slotDao.addPrenotazione(prenotazione);
  }

  Stream<List<Slot>> fetchSlotsStream(String campoId, DateTime selectedDay) {
    return _slotDao.fetchSlotsStream(campoId, selectedDay);
  }

  // Aggiorna lo slot su Firebase per renderlo non disponibile
  Future<void> updateSlotAvailability(
      String campoId, DateTime data, Slot slot) async {
    await _slotDao.updateSlotAvailability(campoId, data, slot);
    notifyListeners();
  }

  // Metodo per recuperare gli slot da Firebase per una data specifica
  Future<void> fetchSlots(String campoId, DateTime selectedDay) async {
    await _slotDao.fetchSlots(campoId, selectedDay);
    notifyListeners();
  }

  // Metodo per aggiungere uno slot su Firebase
  Future<void> addSlot(String id, DateTime selectedDay, Slot slot) async {
    await _slotDao.addSlot(id, selectedDay, slot);
    notifyListeners();
  }

  // Metodo per eliminare tutti gli slot di giorni passati

  Future<void> removePastSlots(String campoId) async {
    await _slotDao.removePastSlots(campoId);
    notifyListeners();
  }

  // Metodo per rimuovere uno slot da Firebase
  Future<void> removeSlot(
      String campoId, DateTime selectedDay, Slot slot) async {
    await _slotDao.removeSlot(campoId, selectedDay, slot);
    notifyListeners();
  }

  // Metodo per aggiornare la disponibilità di uno slot su Firebase
  Future<void> updateSlot(
      String campoId, DateTime selectedDay, Slot slot) async {
    await _slotDao.updateSlot(campoId, selectedDay, slot);
    notifyListeners();
  }

  Future<void> updateSlotAsUnavailable(
      String campoId, DateTime data, Slot slot) async {
    await _slotDao.updateSlotAsUnavailable(campoId, data, slot);
    notifyListeners();
  }

  Future<void> updateSlotAsAvailable(
      String campoId, DateTime data, Slot? slot) async {
    await _slotDao.updateSlotAsAvailable(campoId, data, slot);
    notifyListeners();
  }

  Future<void> generateHourlySlots(DateTime startHour, DateTime endHour,
      String campoId, DateTime selectedDay) async {
    await _slotDao.generateHourlySlots(
        startHour, endHour, campoId, selectedDay);
    notifyListeners();
  }
}
