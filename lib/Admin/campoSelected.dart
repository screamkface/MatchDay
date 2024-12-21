// ignore_for_file: library_private_types_in_public_api, unused_element

import 'package:flutter/material.dart';
import 'package:match_day/components/customTbCalendar.dart';
import 'package:provider/provider.dart';
import 'package:match_day/Admin/admin_home.dart';
import 'package:match_day/Models/campo.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/Providers/slotProvider.dart';

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
        .removePastSlots(widget.campo.id);
    _fetchSlotFirebase();
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _fetchSlotFirebase(); // Fetch degli slot da Firebase per la data selezionata
    });
  }

  void _fetchSlotFirebase() {
    Provider.of<FirebaseSlotProvider>(context, listen: false)
        .fetchSlots(widget.campo.id, _selectedDay);
    Provider.of<FirebaseSlotProvider>(context, listen: false)
        .removePastSlots(widget.campo.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendario ${widget.campo.nome}"),
      ),
      body: Column(
        children: [
          CustomTableCalendar(onDaySelected: _onDaySelected),
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

  // Function to convert TimeOfDay to a 24-hour formatted string
  String _formatTo24HourString(TimeOfDay time) {
    final DateTime dateTime =
        DateTime(2024, 1, 1, time.hour, time.minute); // Using a fixed date
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  void _aggiungiSlotDialog() async {
    final now = TimeOfDay.now();
    final DateTime currentDay = DateTime.now();

    // Show the TimePicker for the start time
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (startTime != null) {
      // Check if the selected day is today
      bool isToday = _selectedDay.isAtSameMomentAs(
        DateTime(currentDay.year, currentDay.month, currentDay.day),
      );

      if (isToday) {
        if (startTime.hour < now.hour ||
            (startTime.hour == now.hour && startTime.minute < now.minute)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Non è possibile selezionare un orario di inizio nel passato')),
          );
          return;
        }
      }

      // Show the TimePicker for the end time
      final TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: startTime.replacing(hour: startTime.hour + 1),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (endTime != null) {
        // Check if the selected day is today for the end time validation
        if (isToday) {
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

        // Convert start and end times to DateTime using _selectedDay instead of currentDay
        final startDateTime = DateTime(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
          startTime.hour,
          startTime.minute,
        );
        final endDateTime = DateTime(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
          endTime.hour,
          endTime.minute,
        );

        // Ensure the times are not in the past if the day is today
        if (isToday &&
            (startDateTime.isBefore(DateTime.now()) ||
                endDateTime.isBefore(DateTime.now()))) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Non puoi selezionare orari nel passato')),
          );
          return;
        }

        // Format times to 24-hour string
        String startFormatted = _formatTo24HourString(startTime);
        String endFormatted = _formatTo24HourString(endTime);

        // Create a controller to display the formatted time range
        final TextEditingController orarioController = TextEditingController(
          text: '$startFormatted - $endFormatted',
        );

        // Show the dialog to confirm adding the slot
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Aggiungi Slot'),
              content: TextField(
                controller: orarioController,
                decoration: const InputDecoration(
                    labelText: 'Orario (es. 12:00 - 13:00)'),
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
                    // Create a new Slot with the 24-hour formatted time
                    final nuovoSlot = Slot(
                      disponibile: true,
                      orario: '$startFormatted - $endFormatted',
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                    );
                    // Call the provider to add the slot
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
