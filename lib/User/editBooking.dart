import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/Providers/prenotazioniProvider.dart';
import 'package:match_day/Providers/slotProvider.dart';
import 'package:match_day/components/customTbCalendar.dart';
import 'package:match_day/components/custom_snackbar.dart';
import 'package:provider/provider.dart';

class ModificaPrenotazione extends StatefulWidget {
  const ModificaPrenotazione({super.key, required this.primaPrenotazione});

  final Prenotazione primaPrenotazione;

  @override
  State<ModificaPrenotazione> createState() => _ModificaPrenotazioneState();
}

class _ModificaPrenotazioneState extends State<ModificaPrenotazione> {
  DateTime _selectedDay = DateTime.now();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchSlotFirebase();
    Provider.of<FirebaseSlotProvider>(context, listen: false)
        .removePastSlots(widget.primaPrenotazione.idCampo);
  }

  @override
  Widget build(BuildContext context) {
    final firebaseSlotProvider = Provider.of<FirebaseSlotProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifica Prenotazione"),
      ),
      body: Column(
        children: [
          // Passa correttamente la funzione _onDaySelected come callback
          CustomTableCalendar(onDaySelected: _onDaySelected),
          const Padding(
            padding: EdgeInsets.all(5),
            child: Divider(
              thickness: 1,
              color: Colors.black,
            ),
          ),
          const Text("Seleziona nuovo slot",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: StreamBuilder<List<Slot>>(
              stream: firebaseSlotProvider.fetchSlotsStream(
                  widget.primaPrenotazione.idCampo, _selectedDay),
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
                                        onPressed: () async {
                                          String dateString = widget
                                              .primaPrenotazione
                                              .dataPrenotazione;

                                          // Usa DateFormat per il parsing
                                          DateFormat format =
                                              DateFormat("d MMMM yyyy");
                                          DateTime dateTime =
                                              format.parse(dateString);

                                          await Provider.of<
                                                      PrenotazioneProvider>(
                                                  context,
                                                  listen: false)
                                              .modificaPrenotazione(
                                            widget.primaPrenotazione
                                                .id, // ID della prenotazione
                                            widget.primaPrenotazione
                                                .dataPrenotazione, // Data della prenotazione precedente
                                            slot, // Nuovo slot selezionato
                                            // ID del campo della prenotazione precedente
                                            widget.primaPrenotazione.idCampo,
                                            widget.primaPrenotazione.slot!
                                                .id, // ID dello slot precedente
                                          );

                                          CustomSnackbar.show(context,
                                              "Richiesta di modifica inviata!");
                                          await Provider.of<
                                                      PrenotazioneProvider>(
                                                  context,
                                                  listen: false)
                                              .modificaPrenotazioneinAnnullata(
                                                  widget.primaPrenotazione.id);

                                          await Provider.of<
                                                      FirebaseSlotProvider>(
                                                  context,
                                                  listen: false)
                                              .updateSlotAsAvailable(
                                                  widget.primaPrenotazione
                                                      .idCampo,
                                                  dateTime,
                                                  widget
                                                      .primaPrenotazione.slot);
                                        },
                                        child: const Text('Modifica'),
                                      )
                                    : const Text(
                                        "Non disponibile",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
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
    provider.fetchSlots(widget.primaPrenotazione.idCampo, _selectedDay);
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _fetchSlotFirebase(); // Fetch degli slot da Firebase per la data selezionata
    });
  }
}
