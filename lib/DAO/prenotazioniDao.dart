import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:match_day/DAO/slotDao.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/components/custom_snackbar.dart';

class PrenotazioniDao {
  List<Prenotazione> _prenotazioni = [];

  List<Prenotazione> get prenotazioni => _prenotazioni;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SlotDao slotDao = SlotDao();

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

  Future<void> modificaPrenotazioneinAnnullata(String idPrenotazione) async {
    try {
      // Aggiorna lo stato della prenotazione nel database a "annullata"
      await _firestore.collection('prenotazioni').doc(idPrenotazione).update({
        'stato': 'annullata',
      });
    } catch (error) {
      throw Exception(
          'Errore durante la modifica dello stato della prenotazione: $error');
    }
  }

  Future<void> modificaPrenotazioneConSlot(
    String id, // ID della prenotazione precedente
    String dataPrenotazioneString, // Data della prenotazione
    Slot selectedSlot, // Nuovo slot selezionato
    String idCampoPrecedente, // ID del campo precedente
    String slotPrecedenteId, // ID dello slot precedente
  ) async {
    try {
      // Usa DateFormat per parsare la stringa della data in formato 'dd MMMM yyyy'
      DateFormat format = DateFormat('dd MMMM yyyy');
      DateTime dataPrenotazione =
          format.parse(dataPrenotazioneString); // Converte in DateTime

      // Formatta la data in '23 December 2024'
      String formattedDataPrenotazione =
          DateFormat('dd MMMM yyyy').format(dataPrenotazione);

      // Creazione di un nuovo ID per la prenotazione di richiesta modifica
      String newPrenotazioneId =
          FirebaseFirestore.instance.collection('prenotazioni').doc().id;

      // Recupero dell'ID dell'utente attualmente loggato
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Creazione della nuova prenotazione in stato "richiestaModifica"
      Prenotazione prenotazioneModificata = Prenotazione(
        id: newPrenotazioneId, // Usa un nuovo ID per la nuova prenotazione
        idCampo: idCampoPrecedente, // ID del campo che è passato come parametro
        dataPrenotazione: formattedDataPrenotazione, // Usa la data formattata
        stato: Stato.richiestaModifica, // Stato corretto: richiestaModifica
        idUtente: userId, // ID dell'utente attualmente loggato
        slot: selectedSlot, // Usa il nuovo slot selezionato
      );

      // Aggiungi la nuova prenotazione alla collezione "prenotazioni"
      await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(newPrenotazioneId)
          .set({
        'dataPrenotazione': prenotazioneModificata.dataPrenotazione,
        'slot': {
          'id': selectedSlot.id,
          'orario': selectedSlot.orario,
          'disponibile': false, // Imposta il nuovo slot come non disponibile
        },
        'stato': 'richiestaModifica', // Imposta lo stato corretto
        'idCampo': idCampoPrecedente, // Campo selezionato
        'idUtente': userId, // ID dell'utente
      });

      // **Aggiorna lo slot selezionato e imposta "disponibile" a false usando il nuovo metodo**
      await slotDao.updateSlotAsUnavailable(
          idCampoPrecedente, dataPrenotazione, selectedSlot);

      // Rendi disponibile lo slot precedente
      await FirebaseFirestore.instance
          .collection('slots')
          .doc(slotPrecedenteId)
          .update(
              {'disponibile': true}); // Rendi disponibile lo slot precedente

      // **Aggiorna la prenotazione precedente e imposta lo stato a "annullata"**
      await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(id) // Usa l'ID della prenotazione precedente
          .update({
        'stato': 'annullata', // Imposta lo stato a annullata
      });

      // Mostra un messaggio di successo
      CustomSnackbar(
          "La tua richiesta di modifica è stata inviata per approvazione e la prenotazione precedente è stata annullata!");
    } catch (e) {
      CustomSnackbar("Errore nella modifica della prenotazione: $e");
    }
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
      case 'richiestaModifica':
        return Stato.richiestaModifica;
      default:
        return Stato.inAttesa;
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
      }
    } catch (e) {
      print('Errore durante l\'aggiornamento della prenotazione: $e');
    }
  }

  Future<Slot?> recuperaSlot(String campoId, String dataPrenotazione) async {
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

  Future<void> eliminaPrenotazione(String prenotazioneId) async {
    try {
      await FirebaseFirestore.instance
          .collection('prenotazioni')
          .doc(prenotazioneId)
          .delete();

      // Rimuovi la prenotazione dalla lista locale
      _prenotazioni.removeWhere((p) =>
          p.id ==
          prenotazioneId); // Notifica i listener dopo aver eliminato una prenotazione
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

      print('Prenotazione aggiornata con successo.');
    } catch (e) {
      print('Errore durante l\'aggiornamento della prenotazione: $e');
    }
  }

  Future<void> rifiutaModificaPrenotazione(String id) async {
    try {
      // Riferimento al documento della prenotazione
      DocumentReference prenotazioneRef =
          FirebaseFirestore.instance.collection('prenotazioni').doc(id);

      // Recupero della prenotazione
      DocumentSnapshot prenotazioneSnapshot = await prenotazioneRef.get();
      if (prenotazioneSnapshot.exists) {
        Map<String, dynamic> prenotazioneData =
            prenotazioneSnapshot.data() as Map<String, dynamic>;

        // Controllo se 'idCampo' e 'slotId' esistono e non sono nulli
        if (prenotazioneData.containsKey('idCampo') &&
            prenotazioneData['idCampo'] != null &&
            prenotazioneData.containsKey('slot.id') &&
            prenotazioneData['slot']['id'] != null) {
          String idCampo = prenotazioneData['idCampo'];
          String slotId = prenotazioneData['slot']
              ['id']; // Modificato per accedere alla mappa slot

          // Aggiornamento dello slot: lo slot torna disponibile
          await FirebaseFirestore.instance
              .collection('fields') // La collezione dei campi
              .doc(idCampo)
              .update({
            'calendario.slots.$slotId.disponibile':
                true, // Aggiornato per modificare lo stato di disponibilità
          });

          // Rimozione della prenotazione dalla collezione
          await prenotazioneRef.delete();

          print("Prenotazione rifiutata e slot reso disponibile.");
        } else {
          print('Dati mancanti: idCampo o slotId non trovati.');
        }
      } else {
        print('Prenotazione non trovata!');
      }
    } catch (e) {
      print("Errore nel rifiutare la modifica della prenotazione: $e");
    }
  }

  Future<void> accettaModificaPrenotazione(String id, String idCampo,
      String slotId, String dataPrenotazione, String orarioSlot) async {
    try {
      // Riferimento alla prenotazione da modificare
      DocumentReference prenotazioneRef =
          FirebaseFirestore.instance.collection('prenotazioni').doc(id);

      // Recupero della prenotazione esistente
      DocumentSnapshot prenotazioneSnapshot = await prenotazioneRef.get();
      if (prenotazioneSnapshot.exists) {
        Map<String, dynamic> prenotazioneData =
            prenotazioneSnapshot.data() as Map<String, dynamic>;

        // Recupero dell'ID del campo e dello slot precedente dalla prenotazione
        String idSlotPrecedente = prenotazioneData['slot']['id'];

        // Aggiorna la prenotazione con il nuovo slot e la nuova data
        await prenotazioneRef.update({
          'slot': {
            'id': slotId,
            'orario': orarioSlot,
            'disponibile': false,
          },
          'dataPrenotazione': dataPrenotazione, // Nuova data
          'stato': 'confermata', // Stato confermato
        });

        // Recupera il documento del campo per aggiornare gli slot
        DocumentSnapshot fieldSnapshot = await FirebaseFirestore.instance
            .collection('fields')
            .doc(idCampo)
            .get();

        if (fieldSnapshot.exists) {
          Map<String, dynamic> fieldData =
              fieldSnapshot.data() as Map<String, dynamic>;

          // Trova lo slot precedente nell'array di slot e rendilo disponibile
          List<dynamic> slots = fieldData['calendario']['slots'];
          int indexSlotPrecedente =
              slots.indexWhere((slot) => slot['id'] == idSlotPrecedente);

          if (indexSlotPrecedente != -1) {
            slots[indexSlotPrecedente]['disponibile'] = true;
          }

          // Trova il nuovo slot nell'array di slot e impostalo come non disponibile
          int indexNuovoSlot = slots.indexWhere((slot) => slot['id'] == slotId);

          if (indexNuovoSlot != -1) {
            slots[indexNuovoSlot]['disponibile'] = false;
          }

          // Aggiorna il campo con lo stato aggiornato degli slot
          await FirebaseFirestore.instance
              .collection('fields')
              .doc(idCampo)
              .update({
            'calendario.slots': slots,
          });

          print('Modifica prenotazione accettata!');
        } else {
          print('Campo non trovato!');
        }
      } else {
        print('Prenotazione non trovata!');
      }
    } catch (e) {
      print("Errore nell'accettare la modifica della prenotazione: $e");
    }
  }
}
