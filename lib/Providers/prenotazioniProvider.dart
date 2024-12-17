import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:match_day/DAO/prenotazioniDao.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/components/custom_snackbar.dart';

class PrenotazioneProvider extends ChangeNotifier {
  List<Prenotazione> _prenotazioni = [];

  final PrenotazioniDao _prenotazioniDao = PrenotazioniDao();

  List<Prenotazione> get prenotazioni => _prenotazioni;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Recuperare tutte le prenotazioni
  Future<void> fetchPrenotazioni() async {
    await _prenotazioniDao.fetchPrenotazioni();
    notifyListeners();
  }

  Stream<List<Prenotazione>> fetchPrenotazioniStream() {
    return FirebaseFirestore.instance
        .collection('prenotazioni')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        var data = doc.data();
        return Prenotazione(
          id: doc.id,
          idCampo: data['idCampo'],
          idUtente: data['idUtente'],
          stato: _getStatoFromString(data['stato']),
          dataPrenotazione: data['dataPrenotazione'],
          slot: data['slot'] != null ? Slot.fromMap(data['slot']) : null,
        );
      }).toList();
    });
  }

  Stato _getStatoFromString(String stato) {
    switch (stato) {
      case 'inAttesa':
        return Stato.inAttesa;
      case 'confermata':
        return Stato.confermata;
      case 'annullata':
        return Stato.annullata;
      default:
        return Stato.inAttesa; // Stato di fallback se il valore non è valido
    }
  }

  Future<void> rifiutaPrenotazione(String prenotazioneId, String campoId,
      String slotId, String dataPrenotazione) async {
    try {
      // 1. Trasforma la data da "05 December 2024" a "2024-12-5"
      DateTime parsedDate = DateFormat('dd MMMM yyyy').parse(dataPrenotazione);
      String dataFormattata = DateFormat('yyyy-MM-d').format(parsedDate);

      // 2. Recupera il documento della prenotazione
      DocumentSnapshot prenotazioneSnapshot = await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(prenotazioneId)
          .get();

      if (prenotazioneSnapshot.exists) {
        // 3. Recupera il documento della data del calendario nel campo specifico
        final slotDocRef = FirebaseFirestore.instance
            .collection('fields')
            .doc(campoId)
            .collection('calendario')
            .doc(dataFormattata); // Usa la data nel formato "2024-12-5"

        DocumentSnapshot slotSnapshot = await slotDocRef.get();

        if (slotSnapshot.exists) {
          // 4. Recupera gli slot dalla data specifica
          var dataCalendario = slotSnapshot.data() as Map<String, dynamic>;
          List<dynamic> slots = List.from(dataCalendario['slots'] ?? []);

          // 5. Cerca lo slot corrispondente per ID e aggiorna la disponibilità
          for (var i = 0; i < slots.length; i++) {
            if (slots[i]['id'] == slotId) {
              slots[i]['disponibile'] = true; // Rendi lo slot disponibile
              break;
            }
          }

          // 6. Aggiorna lo stato dello slot nel database Firestore
          await slotDocRef.update({
            'slots': slots, // Aggiorna l'array degli slot nella data specifica
          });

          // 5. Aggiorna lo stato della prenotazione a "annullata" senza rimuoverla
          await FirebaseFirestore.instance
              .collection('prenotazioni')
              .doc(prenotazioneId)
              .update({
            'stato': 'annullata',
          });

          // Notifica l'aggiornamento
          notifyListeners();
        } else {
          throw Exception('Calendario per la data non trovato');
        }
      } else {
        throw Exception('Prenotazione non trovata');
      }
    } catch (e) {
      print('Errore nel rifiutare la prenotazione: $e');
      throw Exception('Errore nel rifiutare la prenotazione');
    }
  }

  Stream<List<Prenotazione>> fetchPrenotazioniStreamByUser(String userId) {
    return FirebaseFirestore.instance
        .collection('prenotazioni')
        .where('idUtente', isEqualTo: userId) // Filtro per idUtente
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        return Prenotazione(
          id: doc.id,
          idUtente: data['idUtente'] ?? '',
          idCampo: data['idCampo'] ?? '',
          dataPrenotazione: data['dataPrenotazione'] ?? '',
          slot: data['slot'] != null ? Slot.fromMap(data['slot']) : null,
          stato: _getStatoFromString(
              data['stato'] ?? 'inAttesa'), // Conversione dello stato
        );
      }).toList();
    });
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

  Future<void> accettaPrenotazione(String prenotazioneId) async {
    try {
      await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(prenotazioneId)
          .update({'stato': 'confermata'});

      notifyListeners();
      print('Prenotazione aggiornata con successo.');
    } catch (e) {
      print('Errore durante l\'aggiornamento della prenotazione: $e');
    }
  }

  // Metodo per modificare una prenotazione
  void modificaPrenotazione(
      String id, String dataPrenotazioneString, String selectedSlot) async {
    // Usa DateFormat per parsare la stringa della data in formato 'dd MMMM yyyy'
    DateFormat format = DateFormat('dd MMMM yyyy'); // '06 December 2024'
    DateTime dataPrenotazione =
        format.parse(dataPrenotazioneString); // Converte in DateTime

    // Ottieni l'oggetto Slot per il nuovo slot selezionato
    Slot nuovoSlot = Slot(
      id: selectedSlot, // Assumi che selectedSlot contenga l'ID dello slot selezionato
      orario: selectedSlot, // Imposta l'orario per il nuovo slot, se necessario
      disponibile: false, // O altro stato, in base alla logica della tua app
    );

    // Crea una nuova prenotazione con i nuovi dati
    Prenotazione prenotazioneModificata = Prenotazione(
      id: id,
      idCampo: 'idCampo', // Aggiungi l'id del campo, se necessario
      dataPrenotazione: dataPrenotazione
          .toIso8601String(), // Converte la data in formato ISO 8601
      stato: Stato.inAttesa, // Puoi cambiare lo stato a seconda della logica
      idUtente: 'userId', // Usa l'ID dell'utente attualmente loggato
      slot: nuovoSlot,
    );

    // Aggiorna la prenotazione nel database (Firestore)
    try {
      await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(id) // Usa l'ID della prenotazione da modificare
          .update({
        'dataPrenotazione': prenotazioneModificata.dataPrenotazione,
        'slot': prenotazioneModificata.slot
            ?.toMap(), // Assicurati di convertire lo slot in mappa
        'stato': prenotazioneModificata.stato.toString(),
      });

      // Mostra un messaggio di conferma
      CustomSnackbar("Prenotazione modificata!");
    } catch (e) {
      // Gestisci eventuali errori
      CustomSnackbar("Errore nella modifica!");
    }
  }
}
