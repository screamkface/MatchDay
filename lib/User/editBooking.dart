import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Providers/prenotazioniProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ModificaPrenotazioneScreen extends StatefulWidget {
  final Prenotazione prenotazione;
  const ModificaPrenotazioneScreen({super.key, required this.prenotazione});

  @override
  _ModificaPrenotazioneScreenState createState() =>
      _ModificaPrenotazioneScreenState();
}

class _ModificaPrenotazioneScreenState
    extends State<ModificaPrenotazioneScreen> {
  late DateTime selectedDate;
  late String selectedSlot;
  late List<String> availableSlots; // Lista degli slot disponibili
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Se la data della prenotazione non è già nel formato giusto, riformattala
    DateTime parsedDate;
    try {
      // Se la data arriva nel formato "dd MMMM yyyy", usa DateFormat per convertirla
      parsedDate = DateFormat('dd MMMM yyyy')
          .parse(widget.prenotazione.dataPrenotazione);
    } catch (e) {
      // Gestisci l'errore nel caso in cui il formato non sia corretto
      print("Errore nel parsing della data: $e");
      parsedDate = DateTime.now(); // Imposta la data attuale come fallback
    }

    selectedDate = parsedDate;
    selectedSlot = widget.prenotazione.slot?.orario ?? '';
    availableSlots = []; // Inizialmente la lista è vuota
    _fetchAvailableSlots(
        selectedDate); // Recupera gli slot disponibili per la data iniziale
  }

  // Funzione per recuperare gli slot disponibili da Firestore
  Future<void> _fetchAvailableSlots(DateTime date) async {
    // Formatta la data per utilizzarla nella query
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    try {
      // Recupera gli slot dal Firestore in base alla data
      var snapshot = await FirebaseFirestore.instance
          .collection(
              'slots') // Assicurati di usare la tua collezione Firestore
          .where('idCampo',
              isEqualTo:
                  widget.prenotazione.idCampo) // Aggiungi filtro per idCampo
          .where('data', isEqualTo: formattedDate) // Filtro per la data
          .get();

      // Mappa i dati degli slot e aggiorna la lista
      setState(() {
        availableSlots =
            snapshot.docs.map((doc) => doc['orario'].toString()).toList();
      });
    } catch (e) {
      print('Errore nel recuperare gli slot: $e');
      setState(() {
        availableSlots = [];
      });
    }
  }

  // Funzione per modificare la prenotazione
  void _modificaPrenotazione() {
    final prenotazioneProvider =
        Provider.of<PrenotazioneProvider>(context, listen: false);

    prenotazioneProvider.modificaPrenotazione(
        widget.prenotazione.id, selectedDate.toString(), selectedSlot);

    // Mostra una snackbar di conferma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prenotazione modificata con successo!')),
    );

    // Torna indietro alla schermata precedente
    Navigator.pop(context);
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _fetchAvailableSlots(
          _selectedDay); // Ricarica gli slot per la data selezionata
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Prenotazione'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleziona una nuova data:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Seleziona uno slot:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            availableSlots.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : DropdownButton<String>(
                    value: selectedSlot.isEmpty ? null : selectedSlot,
                    hint: const Text('Seleziona uno slot'),
                    onChanged: (newSlot) {
                      setState(() {
                        selectedSlot = newSlot!;
                      });
                    },
                    items: availableSlots
                        .map<DropdownMenuItem<String>>((String slot) {
                      return DropdownMenuItem<String>(
                        value: slot,
                        child: Text(slot),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedSlot.isEmpty ? null : _modificaPrenotazione,
              child: const Text('Conferma Modifica'),
            ),
          ],
        ),
      ),
    );
  }
}
