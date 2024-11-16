// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:match_day/Admin/admin_home.dart';
import 'package:match_day/Models/campo.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/Providers/slotProvider.dart';
import 'package:match_day/components/adminNavbar.dart';
import 'package:table_calendar/table_calendar.dart';

class CampoCalendar extends StatefulWidget {
  final Campo campo;

  const CampoCalendar({super.key, required this.campo});

  @override
  _CampoCalendarState createState() => _CampoCalendarState();
}

class _CampoCalendarState extends State<CampoCalendar> {
  DateTime _selectedDay = DateTime.now();
  List<Slot> _selectedSlots = [];
  final FirebaseSlotProvider _firebaseSlotProvider = FirebaseSlotProvider();

  int _selectedIndex = 0;

  // Lista delle pagine da visualizzare
  final List<Widget> _pages = [const AdminHomePage()];

  // Funzione per cambiare pagina
  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _firebaseSlotProvider.removePastSlots(widget.campo.id);
    _aggiornaSlot();
    _fetchSlotFirebase();
  }

  void _aggiornaSlot() {
    _selectedSlots = widget.campo.calendario[_formatDate(_selectedDay)] ?? [];
    _firebaseSlotProvider.removePastSlots(widget.campo.id);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _fetchSlotFirebase(); // Fetch degli slot da Firebase per la data selezionata
      _firebaseSlotProvider.removePastSlots(widget.campo.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AdminNavbar(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
      appBar: AppBar(
        title: Text("Calendario ${widget.campo.nome}"),
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
                          color: slot.disponibile ? Colors.green : Colors.red,
                          child: ListTile(
                            title: Text(slot.orario),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: slot.disponibile,
                                  onChanged: (value) => setState(() {
                                    slot.disponibile = value;
                                    _aggiornaSlotFirebase(slot);
                                  }),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _rimuoviSlot(slot);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton(
              onPressed: () {
                _aggiungiSlotDialog();
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  void _aggiungiSlotDialog() async {
    final now = TimeOfDay.now();
    final DateTime currentDay = DateTime.now();

    // Mostra il TimePicker per scegliere l'orario di inizio
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: now,
    );

    if (startTime != null) {
      // Controlla se la data selezionata è il giorno corrente
      if (_selectedDay.isAtSameMomentAs(
          DateTime(currentDay.year, currentDay.month, currentDay.day))) {
        // Se l'orario di inizio è prima dell'orario attuale, mostra un errore
        if (startTime.hour < now.hour ||
            (startTime.hour == now.hour && startTime.minute < now.minute)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Non è possibile selezionare un orario nel passato')),
          );
          return;
        }
      }

      // Mostra il TimePicker per scegliere l'orario di fine
      final TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: startTime.replacing(
            hour: startTime.hour +
                1), // Imposta l'ora di fine come 1 ora dopo l'inizio
      );

      if (endTime != null) {
        // Controlla se l'orario di fine è nel passato rispetto all'ora corrente
        if (_selectedDay.isAtSameMomentAs(
            DateTime(currentDay.year, currentDay.month, currentDay.day))) {
          if (endTime.hour < now.hour ||
              (endTime.hour == now.hour && endTime.minute < now.minute)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Non è possibile selezionare un orario di fine nel passato')),
            );
            return;
          }
        }

        // Formatta gli orari senza AM/PM
        String startFormatted =
            startTime.format(context).replaceAll(RegExp(r'\sAM|\sPM'), '');
        String endFormatted =
            endTime.format(context).replaceAll(RegExp(r'\sAM|\sPM'), '');

        final TextEditingController orarioController = TextEditingController(
          text:
              '$startFormatted - $endFormatted', // Mostra l'intervallo di tempo
        );

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Aggiungi Slot'),
              content: TextField(
                controller: orarioController,
                decoration: const InputDecoration(
                    labelText: 'Orario (es. 10:00 - 11:00)'),
                readOnly: true, // Rendi il campo di testo di sola lettura
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final nuovoSlot = Slot(orario: orarioController.text);
                    setState(() {
                      widget.campo
                          .aggiungiSlot(_formatDate(_selectedDay), nuovoSlot);
                      _aggiornaSlot();
                      _aggiungiSlotFirebase(nuovoSlot); // Aggiungi su Firebase
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Aggiungi'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  // Metodo per recuperare gli slot da Firebase
  void _fetchSlotFirebase() async {
    final slots =
        await _firebaseSlotProvider.fetchSlots(widget.campo.id, _selectedDay);
    setState(() {
      _selectedSlots = slots;
    });
  }

  // Metodo per aggiungere uno slot su Firebase
  void _aggiungiSlotFirebase(Slot slot) async {
    await _firebaseSlotProvider.addSlot(widget.campo.id, _selectedDay, slot);
    _firebaseSlotProvider.removePastSlots(widget.campo.id);
    _fetchSlotFirebase();
  }

  // Metodo per aggiornare la disponibilità dello slot su Firebase
  void _aggiornaSlotFirebase(Slot slot) async {
    await _firebaseSlotProvider.updateSlot(widget.campo.id, _selectedDay, slot);
    _firebaseSlotProvider.removePastSlots(widget.campo.id);
    _fetchSlotFirebase();
  }

  // Metodo per rimuovere uno slot
  void _rimuoviSlot(Slot slot) async {
    await _firebaseSlotProvider.removeSlot(widget.campo.id, _selectedDay, slot);
    _firebaseSlotProvider.removePastSlots(widget.campo.id);
    _fetchSlotFirebase();
  }
}
