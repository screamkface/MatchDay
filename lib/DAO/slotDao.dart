import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/components/custom_snackbar.dart';
import 'package:match_day/main.dart';

class SlotDao {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Slot> _selectedSlots = [];

  List<Slot> get selectedSlots => _selectedSlots;

  final List<Slot> _slots = []; // Stato interno
  List<Slot> get slots => _slots;

  Future<void> addPrenotazione(Prenotazione prenotazione) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final prenotazioniRef = firestore.collection('prenotazioni');

      // Avvia una transazione
      await firestore.runTransaction((transaction) async {
        // Verifica se lo slot è già prenotato
        final querySnapshot = await prenotazioniRef
            .where('campoId', isEqualTo: prenotazione.idCampo)
            .where('data', isEqualTo: prenotazione.dataPrenotazione)
            .where('orario', isEqualTo: prenotazione.slot!.orario)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Lo slot è già prenotato, lancia un'eccezione per interrompere la transazione
          throw Exception('Lo slot è già prenotato.');
        }

        // Aggiungi la prenotazione se lo slot è libero
        final docRef = prenotazioniRef.doc();
        transaction.set(docRef, prenotazione.toMap());
        print("Prenotazione aggiunta con ID: ${docRef.id}");
      });
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
      String campoId, DateTime data, Slot? slot) async {
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

      // Se lo slot è nullo, creiamo uno slot vuoto con valori predefiniti
      slot ??= Slot(
        orario: 'Non disponibile', // Modifica con un valore appropriato
        disponibile: true,
        id: 'nuovoSlot', // Un ID per lo slot, puoi generarlo dinamicamente
      );

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
      showMySnackBar("L'ID del campo non può essere vuoto");

      return;
    }

    final formattedDate = _formatDate(selectedDay);

    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('fields')
          .doc(id)
          .collection('calendario')
          .doc(formattedDate)
          .get();

      List<dynamic> existingSlots = [];

      if (snapshot.exists && snapshot.data() != null) {
        final data =
            snapshot.data() as Map<String, dynamic>?; // Cast to Map or null
        if (data != null && data.containsKey('slots')) {
          existingSlots =
              data['slots'] as List<dynamic>; // Safe cast as List<dynamic>
        }
      }

      bool slotExists = existingSlots
          .any((existingSlot) => existingSlot['orario'] == slot.orario);

      if (slotExists) {
        showMySnackBar("Uno slot con questo orario esiste già.");
        return;
      }

      await _firestore
          .collection('fields')
          .doc(id)
          .collection('calendario')
          .doc(formattedDate)
          .set({
        'slots': FieldValue.arrayUnion([slot.toMap()])
      }, SetOptions(merge: true));
      showMySnackBar('Slot aggiunto con successo!');
    } catch (e) {
      showMySnackBar('Errore nell\'aggiungere lo slot: $e');
    }
  }

  Future<void> generateHourlySlots(DateTime startHour, DateTime endHour,
      String campoId, DateTime selectedDay) async {
    // Controllo per assicurarsi che l'ora di inizio sia precedente all'ora di fine
    if (startHour.isAfter(endHour)) {
      throw Exception("L'ora di inizio deve essere precedente all'ora di fine");
    }

    List<Slot> slots = [];

    // Ciclo per creare gli slot con intervalli di un'ora nel range di date
    DateTime currentHour = startHour;
    while (currentHour.isBefore(endHour)) {
      DateTime nextHour = currentHour.add(const Duration(hours: 1));

      // Creazione dello slot
      Slot slot = Slot(
        id: FirebaseFirestore.instance
            .collection('fields')
            .doc(campoId)
            .collection('calendario')
            .doc()
            .id, // ID univoco generato da Firestore
        orario: "${_formatTime(currentHour)} - ${_formatTime(nextHour)}",
        disponibile: true, // Imposta il valore di default se necessario
      );

      // Aggiungi lo slot alla lista
      slots.add(slot);

      // Passa all'ora successiva
      currentHour = nextHour;
    }

    // Converti la data selezionata in formato stringa
    String formattedDate = _formatDate(selectedDay);

    try {
      // Aggiungi gli slot al database Firestore
      await FirebaseFirestore.instance
          .collection('fields')
          .doc(campoId)
          .collection('calendario')
          .doc(formattedDate)
          .set({
        'slots':
            FieldValue.arrayUnion(slots.map((slot) => slot.toMap()).toList()),
      }, SetOptions(merge: true));

      print("Slot aggiunti correttamente");
    } catch (e) {
      print("Errore nel salvataggio degli slot: $e");
      throw Exception('Errore nel salvataggio degli slot: $e');
    }
  }

// Metodo di formattazione dell'orario in formato stringa (esempio: 7:00)
  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
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
