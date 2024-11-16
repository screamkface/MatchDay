import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:match_day/Models/campo.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/Providers/slotProvider.dart';
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
  List<Slot> _selectedSlots = [];
  final FirebaseSlotProvider _firebaseSlotProvider = FirebaseSlotProvider();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _aggiornaSlot();
    _fetchSlotFirebase();
  }

  void _aggiornaSlot() {
    _selectedSlots = widget.campo.calendario[_formatDate(_selectedDay)] ?? [];
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _fetchSlotFirebase(); // Fetch degli slot da Firebase per la data selezionata
    });
  }

  @override
  Widget build(BuildContext context) {
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
            child: _selectedSlots.isEmpty
                ? const Center(
                    child: Text(
                        "Nessuno slot disponibile per il giorno selezionato."))
                : ListView.builder(
                    itemCount: _selectedSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _selectedSlots[index];
                      return Padding(
                        padding: const EdgeInsets.all(5),
                        child: Card(
                          elevation: 5,
                          borderOnForeground: true,
                          color: slot.disponibile ? Colors.green : Colors.grey,
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
                  ),
          ),
        ],
      ),
    );
  }

  // Metodo per recuperare gli slot da Firebase
  void _fetchSlotFirebase() async {
    final slots =
        await _firebaseSlotProvider.fetchSlots(widget.campo.id, _selectedDay);
    setState(() {
      _selectedSlots = slots;
    });
  }

  // Metodo per prenotare uno slot
// Metodo per prenotare uno slot
  void _prenotaSlot(Slot slot) async {
    // Crea una nuova prenotazione
    final nuovaPrenotazione = Prenotazione(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Genera un ID univoco per la prenotazione
      idCampo: widget.campo.id,
      dataPrenotazione: _selectedDay,
      stato: Stato.inAttesa,
      idUtente:
          userId, // Usa l'enum che hai definito per lo stato della prenotazione
    );

    try {
      // Salva la prenotazione su Firebase
      await _firebaseSlotProvider.addPrenotazione(nuovaPrenotazione);

      // Aggiorna lo stato dello slot su Firebase (disponibile -> non disponibile)
      Slot slotAggiornato = Slot(
        orario: slot.orario,
        disponibile: false, // Imposta lo slot come non disponibile
      );

      await _firebaseSlotProvider.updateSlotAvailability(
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
