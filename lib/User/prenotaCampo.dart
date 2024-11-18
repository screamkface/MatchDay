import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:match_day/Models/campo.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/Providers/slotProvider.dart';
import 'package:provider/provider.dart'; // Importa Provider
import 'package:table_calendar/table_calendar.dart';

import '../Models/prenotazione.dart';

class CampoCalendarUser extends StatefulWidget {
  final Campo campo;

  const CampoCalendarUser({super.key, required this.campo});

  @override
  _CampoCalendarUserState createState() => _CampoCalendarUserState();
}

class _CampoCalendarUserState extends State<CampoCalendarUser> {
  DateTime _selectedDay = DateTime.now();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchSlotFirebase();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _fetchSlotFirebase(); // Fetch degli slot da Firebase per la data selezionata
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseSlotProvider = Provider.of<FirebaseSlotProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Prenota uno slot per ${widget.campo.nome}"),
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarFormat: CalendarFormat.twoWeeks,
            calendarStyle: const CalendarStyle(isTodayHighlighted: true),
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
          ),
          Expanded(
            child: StreamBuilder<List<Slot>>(
              stream: firebaseSlotProvider.fetchSlotsStream(
                  widget.campo.id, _selectedDay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                }

                final selectedSlots = snapshot.data ?? [];
                return selectedSlots.isEmpty
                    ? const Center(
                        child: Text(
                            "Nessuno slot disponibile per il giorno selezionato."),
                      )
                    : ListView.builder(
                        itemCount: selectedSlots.length,
                        itemBuilder: (context, index) {
                          final slot = selectedSlots[index];
                          return Padding(
                            padding: const EdgeInsets.all(5),
                            child: Card(
                              elevation: 5,
                              color:
                                  slot.disponibile ? Colors.green : Colors.grey,
                              child: ListTile(
                                title: Text(slot.orario),
                                trailing: slot.disponibile
                                    ? ElevatedButton(
                                        onPressed: () {
                                          _prenotaSlot(slot);
                                        },
                                        child: const Text('Prenota'),
                                      )
                                    : const Text(
                                        "Non disponibile",
                                        style: TextStyle(color: Colors.red),
                                      ),
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Metodo per recuperare gli slot da Firebase
  void _fetchSlotFirebase() {
    // Recupera gli slot utilizzando il provider
    final provider = Provider.of<FirebaseSlotProvider>(context, listen: false);
    provider.fetchSlots(widget.campo.id, _selectedDay);
  }

  // Metodo per prenotare uno slot
  void _prenotaSlot(Slot slot) async {
    final provider = Provider.of<FirebaseSlotProvider>(context, listen: false);

    // Crea una nuova prenotazione
    final nuovaPrenotazione = Prenotazione(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      idCampo: widget.campo.id,
      dataPrenotazione: _selectedDay,
      stato: Stato.inAttesa,
      idUtente: userId,
    );

    try {
      // Salva la prenotazione su Firebase
      await provider.addPrenotazione(nuovaPrenotazione);

      // Aggiorna lo stato dello slot su Firebase (disponibile -> non disponibile)
      Slot slotAggiornato = Slot(
        orario: slot.orario,
        disponibile: false,
      );

      await provider.updateSlotAvailability(
        widget.campo.id,
        _selectedDay,
        slotAggiornato,
      );

      // Mostra un messaggio di conferma all'utente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Slot prenotato con successo!')),
      );

      // Aggiorna lo stato locale per riflettere i cambiamenti
      _fetchSlotFirebase();
    } catch (e) {
      // Gestione degli errori
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante la prenotazione: $e')),
      );
    }
  }
}
