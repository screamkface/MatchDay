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
                                          DateTime newDate =
                                              _selectedDay; // Nuova data selezionata

                                          if (newDate != dateTime) {
                                            // Crea un nuovo oggetto Prenotazione con la nuova data e slot
                                            Prenotazione nuovaPrenotazione =
                                                Prenotazione(
                                              id: '', // L'ID verrà generato da Firebase
                                              idUtente: userId,
                                              dataPrenotazione:
                                                  newDate.toString(),
                                              stato: Stato
                                                  .richiestaModifica, // Stato della prenotazione (puoi cambiarlo come preferisci)
                                              idCampo: widget
                                                  .primaPrenotazione.idCampo,
                                              slot:
                                                  slot, // Nuovo slot selezionato
                                            );

                                            // Aggiungi la nuova prenotazione nel database
                                            await Provider.of<
                                                        FirebaseSlotProvider>(
                                                    context,
                                                    listen: false)
                                                .addPrenotazione(
                                                    nuovaPrenotazione);

                                            CustomSnackbar.show(context,
                                                "Prenotazione modificata con successo!");

                                            // Annulla la prenotazione precedente
                                            await Provider.of<
                                                        PrenotazioneProvider>(
                                                    context,
                                                    listen: false)
                                                .modificaPrenotazioneinAnnullata(
                                                    widget
                                                        .primaPrenotazione.id);

                                            // Disattiva il vecchio slot
                                            await Provider.of<
                                                        FirebaseSlotProvider>(
                                                    context,
                                                    listen: false)
                                                .updateSlotAsAvailable(
                                              widget.primaPrenotazione.idCampo,
                                              dateTime,
                                              widget.primaPrenotazione.slot!,
                                            );

                                            // Disattiva il nuovo slot selezionato

                                            Slot newSlot = slot;
                                            await Provider.of<
                                                        FirebaseSlotProvider>(
                                                    context,
                                                    listen: false)
                                                .updateSlotAsUnavailable(
                                              widget.primaPrenotazione.idCampo,
                                              newDate,
                                              newSlot,
                                            );

                                            Navigator.pop(context);
                                          } else {
                                            CustomSnackbar.show(context,
                                                "La data selezionata è la stessa della prenotazione originale.");
                                          }
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

  void _fetchSlotFirebase() {
    final provider = Provider.of<FirebaseSlotProvider>(context, listen: false);
    provider.fetchSlots(widget.primaPrenotazione.idCampo, _selectedDay);
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _fetchSlotFirebase();
    });
  }
}
