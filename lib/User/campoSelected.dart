import 'package:flutter/material.dart';
import 'package:match_day/Models/campo.dart';
import 'package:match_day/Models/slot.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CampoCalendar extends StatefulWidget {
  final Campo campo;

  CampoCalendar({required this.campo});

  @override
  _CampoCalendarState createState() => _CampoCalendarState();
}

class _CampoCalendarState extends State<CampoCalendar> {
  DateTime _selectedDay = DateTime.now();
  List<Slot> _selectedSlots = [];

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
        title: Text("Calendario del Campo"),
      ),
      body: Column(
        children: [
          TableCalendar(
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
                        padding: const EdgeInsets.all(10),
                        child: Card(
                          elevation: 5,
                          borderOnForeground: true,
                          color: slot.disponibile ? Colors.green : Colors.red,
                          child: ListTile(
                            title: Text(slot.orario),
                            trailing: Switch(
                              value: slot.disponibile,
                              onChanged: (value) => setState(() {
                                slot.disponibile = value;
                                _aggiornaSlotFirebase(slot);
                              }),
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
    // Mostra il TimePicker per scegliere l'orario di inizio
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (startTime != null) {
      // Mostra il TimePicker per scegliere l'orario di fine
      final TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: startTime.replacing(
            hour: startTime.hour +
                1), // Imposta l'ora di fine come 1 ora dopo l'inizio
      );

      if (endTime != null) {
        // Formatta gli orari senza AM/PM
        String startFormatted =
            startTime.format(context).replaceAll(RegExp(r'\sAM|\sPM'), '');
        String endFormatted =
            endTime.format(context).replaceAll(RegExp(r'\sAM|\sPM'), '');

        final TextEditingController _orarioController = TextEditingController(
          text:
              '$startFormatted - $endFormatted', // Mostra l'intervallo di tempo
        );

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Aggiungi Slot'),
              content: TextField(
                controller: _orarioController,
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
                    final nuovoSlot = Slot(orario: _orarioController.text);
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

  void _fetchSlotFirebase() async {
    final formattedDate = _formatDate(_selectedDay);

    // Fetch del documento corrispondente alla data selezionata
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('fields')
        .doc(widget
            .campo.id) // Usa l'ID del campo per accedere al documento corretto
        .collection('calendario')
        .doc(formattedDate)
        .get();

    if (snapshot.exists) {
      List<dynamic> slotData = snapshot['slots'];

      // Converte i dati fetchati in oggetti Slot
      setState(() {
        _selectedSlots = slotData.map((data) => Slot.fromMap(data)).toList();
      });

      print("Slot fetchati da Firebase");
    } else {
      // Se non esiste il documento per quella data, setta gli slot vuoti
      setState(() {
        _selectedSlots = [];
      });

      print("Nessuno slot disponibile per la data selezionata");
    }
  }

  // Metodo per aggiungere un nuovo slot su Firebase
  void _aggiungiSlotFirebase(Slot slot) async {
    final formattedDate = _formatDate(_selectedDay);

    await FirebaseFirestore.instance
        .collection('fields')
        .doc(widget.campo.id)
        .collection('calendario')
        .doc(formattedDate)
        .set({
      'slots': FieldValue.arrayUnion([slot.toMap()])
    }, SetOptions(merge: true));

    setState(() {
      _fetchSlotFirebase();
    });
  }

  // Metodo per aggiornare uno slot su Firebase
  void _aggiornaSlotFirebase(Slot slot) async {
    final formattedDate = _formatDate(_selectedDay);

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('fields')
        .doc(widget.campo.id)
        .collection('calendario')
        .doc(formattedDate)
        .get();

    if (snapshot.exists) {
      List<dynamic> slots = snapshot['slots'];

      // Trova lo slot corrispondente e aggiorna il valore della disponibilità
      for (var i = 0; i < slots.length; i++) {
        if (slots[i]['orario'] == slot.orario) {
          slots[i]['disponibile'] = slot.disponibile;
        }
      }

      // Aggiorna i dati su Firebase
      await FirebaseFirestore.instance
          .collection('fields')
          .doc(widget.campo.id)
          .collection('calendario')
          .doc(formattedDate)
          .update({
        'slots': slots,
      });
    }
  }
}
