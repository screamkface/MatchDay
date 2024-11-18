import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    Provider.of<FirebaseSlotProvider>(context, listen: false)
        .removePastSlots(widget.campo.id); // Rimuove gli slot passati all'avvio
    _fetchSlotFirebase(); // Recupera gli slot attuali
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
    _fetchSlotFirebase(); // Fetch degli slot da Firebase per la data selezionata
  }

  void _fetchSlotFirebase() {
    Provider.of<FirebaseSlotProvider>(context, listen: false)
        .fetchSlots(widget.campo.id, _selectedDay);
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
            child: StreamBuilder<List<Slot>>(
              stream: Provider.of<FirebaseSlotProvider>(context)
                  .fetchSlotsStream(widget.campo.id, _selectedDay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                }

                final slots = snapshot.data ?? [];
                if (slots.isEmpty) {
                  return const Center(
                    child: Text(
                        "Nessuno slot disponibile per il giorno selezionato."),
                  );
                }

                return ListView.builder(
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
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
                                onChanged: (value) {
                                  slot.disponibile = value;
                                  Provider.of<FirebaseSlotProvider>(context,
                                          listen: false)
                                      .updateSlot(
                                          widget.campo.id, _selectedDay, slot);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  Provider.of<FirebaseSlotProvider>(context,
                                          listen: false)
                                      .removeSlot(
                                          widget.campo.id, _selectedDay, slot);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton(
              onPressed: _aggiungiSlotDialog,
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
      if (_selectedDay.isAtSameMomentAs(
          DateTime(currentDay.year, currentDay.month, currentDay.day))) {
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

      final TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: startTime.replacing(hour: startTime.hour + 1),
      );

      if (endTime != null) {
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

        String startFormatted =
            startTime.format(context).replaceAll(RegExp(r'\sAM|\sPM'), '');
        String endFormatted =
            endTime.format(context).replaceAll(RegExp(r'\sAM|\sPM'), '');

        final TextEditingController orarioController = TextEditingController(
          text: '$startFormatted - $endFormatted',
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
                readOnly: true,
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
                    Provider.of<FirebaseSlotProvider>(context, listen: false)
                        .addSlot(widget.campo.id, _selectedDay, nuovoSlot);
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
}
