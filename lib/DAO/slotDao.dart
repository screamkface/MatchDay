import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';

class SlotDao {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Slot> _selectedSlots = [];

  List<Slot> get selectedSlots => _selectedSlots;

  final List<Slot> _slots = []; // Stato interno
  List<Slot> get slots => _slots;

  // Aggiungi una prenotazione
  Future<void> addPrenotazione(Prenotazione prenotazione) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('prenotazioni')
          .add(prenotazione.toMap());
      print("Prenotazione aggiunta con ID: ${docRef.id}");
    } catch (e) {
      print('Errore durante l\'aggiunta della prenotazione: $e');
    }
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

  Future<void> updateSlotAsUnavailable(
      String campoId, DateTime data, Slot slot) async {
    if (campoId.isEmpty) {
      throw Exception("L'ID del campo non può essere vuoto");
    }

    try {
      // Formatta la data come 'yyyy-MM-dd' per il documento
      final formattedDate = "${data.year}-${data.month}-${data.day}";

      // Percorso per accedere al documento specifico del giorno all'interno della collezione 'calendario'
      final documentPath = 'fields/$campoId/calendario/$formattedDate';

      // Recupera il documento che rappresenta il giorno selezionato
      DocumentSnapshot calendarioDoc =
          await FirebaseFirestore.instance.doc(documentPath).get();

      if (!calendarioDoc.exists) {
        // Se il documento non esiste, lo crea con una lista di slot vuota
        await FirebaseFirestore.instance.doc(documentPath).set({
          'slots': [] // Creiamo il documento con una lista vuota di slot
        });
        print('Documento calendario creato per la data $formattedDate');
      }

      // A questo punto, il documento esiste, quindi possiamo procedere con l'aggiornamento
      Map<String, dynamic> calendarioData =
          (await FirebaseFirestore.instance.doc(documentPath).get()).data()
              as Map<String, dynamic>;

      List<dynamic> slotsList = calendarioData['slots'];

      bool slotFound = false;

      // Trova lo slot corrispondente all'orario e imposta "disponibile" su false
      for (var slotItem in slotsList) {
        if (slotItem['orario'] == slot.orario) {
          // Imposta la disponibilità dello slot a false
          slotItem['disponibile'] = false;
          slotFound = true;
          break;
        }
      }

      // Se non abbiamo trovato lo slot, significa che dobbiamo aggiungerlo come non disponibile
      if (!slotFound) {
        slot.disponibile = false;
        slotsList.add(slot.toMap());
      }

      // Salva il documento aggiornato con il nuovo stato dello slot
      await FirebaseFirestore.instance.doc(documentPath).update({
        'slots': slotsList,
      });

      print('Slot aggiornato e impostato come non disponibile');
    } catch (e) {
      throw Exception('Errore nell\'aggiornare lo slot: $e');
    }
  }

  Future<void> updateSlotAsAvailable(
      String campoId, DateTime data, Slot slot) async {
    if (campoId.isEmpty) {
      throw Exception("L'ID del campo non può essere vuoto");
    }

    try {
      // Formatta la data come 'yyyy-MM-dd' per il documento
      final formattedDate = "${data.year}-${data.month}-${data.day}";

      // Percorso per accedere al documento specifico del giorno all'interno della collezione 'calendario'
      final documentPath = 'fields/$campoId/calendario/$formattedDate';

      // Recupera il documento che rappresenta il giorno selezionato
      DocumentSnapshot calendarioDoc =
          await FirebaseFirestore.instance.doc(documentPath).get();

      if (!calendarioDoc.exists) {
        // Se il documento non esiste, lo crea con una lista di slot vuota
        await FirebaseFirestore.instance.doc(documentPath).set({
          'slots': [] // Creiamo il documento con una lista vuota di slot
        });
        print('Documento calendario creato per la data $formattedDate');
      }

      // A questo punto, il documento esiste, quindi possiamo procedere con l'aggiornamento
      Map<String, dynamic> calendarioData =
          (await FirebaseFirestore.instance.doc(documentPath).get()).data()
              as Map<String, dynamic>;

      List<dynamic> slotsList = calendarioData['slots'];

      bool slotFound = false;

      // Trova lo slot corrispondente all'orario e imposta "disponibile" su true
      for (var slotItem in slotsList) {
        if (slotItem['orario'] == slot.orario) {
          // Imposta la disponibilità dello slot a true
          slotItem['disponibile'] = true;
          slotFound = true;
          break;
        }
      }

      // Se non abbiamo trovato lo slot, significa che dobbiamo aggiungerlo come disponibile
      if (!slotFound) {
        slot.disponibile = true;
        slotsList.add(slot.toMap());
      }

      // Salva il documento aggiornato con il nuovo stato dello slot
      await FirebaseFirestore.instance.doc(documentPath).update({
        'slots': slotsList,
      });

      print('Slot aggiornato e impostato come disponibile');
    } catch (e) {
      throw Exception('Errore nell\'aggiornare lo slot: $e');
    }
  }

  // Aggiorna lo slot su Firebase per renderlo non disponibile
  Future<void> updateSlotAvailability(
      String campoId, DateTime data, Slot slot) async {
    if (campoId.isEmpty) {
      throw Exception("L'ID del campo non può essere vuoto");
    }

    try {
      // Formatta la data come 'yyyy-MM-dd' per il documento
      final formattedDate = "${data.year}-${data.month}-${data.day}";

      // Percorso per accedere al documento specifico del giorno all'interno della collezione 'calendario'
      final documentPath = 'fields/$campoId/calendario/$formattedDate';

      // Recupera il documento che rappresenta il giorno selezionato
      DocumentSnapshot calendarioDoc =
          await FirebaseFirestore.instance.doc(documentPath).get();

      if (!calendarioDoc.exists) {
        // Se il documento non esiste, lo crea con una lista di slot vuota
        await FirebaseFirestore.instance.doc(documentPath).set({
          'slots': [] // Creiamo il documento con una lista vuota di slot
        });
        print('Documento calendario creato per la data $formattedDate');
      }

      // A questo punto, il documento esiste, quindi possiamo procedere con l'aggiornamento
      Map<String, dynamic> calendarioData =
          (await FirebaseFirestore.instance.doc(documentPath).get()).data()
              as Map<String, dynamic>;

      List<dynamic> slotsList = calendarioData['slots'];

      bool slotFound = false;

      // Trova lo slot corrispondente all'orario
      for (var slotItem in slotsList) {
        if (slotItem['orario'] == slot.orario) {
          // Aggiorna la disponibilità dello slot
          slotItem['disponibile'] = slot.disponibile;
          slotFound = true;
          break;
        }
      }

      // Se non abbiamo trovato lo slot, significa che dobbiamo aggiungerlo
      if (!slotFound) {
        slotsList.add(slot.toMap());
      }

      // Salva il documento aggiornato con il nuovo stato dello slot
      await FirebaseFirestore.instance.doc(documentPath).update({
        'slots': slotsList,
      });

      print('Slot aggiornato con successo');
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
    } catch (e) {
      throw Exception('Errore nel recupero degli slot: $e');
    }
  }

  // Metodo per aggiungere uno slot su Firebase
  Future<void> addSlot(String id, DateTime selectedDay, Slot slot) async {
    if (id.isEmpty) {
      throw Exception("L'ID del campo non può essere vuoto");
    }

    final formattedDate = _formatDate(selectedDay);

    try {
      await _firestore
          .collection('fields')
          .doc(id)
          .collection('calendario')
          .doc(formattedDate)
          .set({
        'slots': FieldValue.arrayUnion([slot.toMap()])
      }, SetOptions(merge: true));
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
      final dateFormat = DateFormat('yyyy-MM-dd'); // Usa il formato corretto

      for (var doc in snapshot.docs) {
        // Usa DateFormat per parsare correttamente l'ID della data
        DateTime slotDate =
            dateFormat.parse(doc.id); // ID del documento è 'yyyy-mm-dd'

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
      } // Notifica le modifiche
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
