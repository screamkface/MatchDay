import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/Providers/slotProvider.dart';
import 'package:match_day/User/editBooking.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';
import '../Providers/prenotazioniProvider.dart';

class PrenotazioniUtenteScreen extends StatefulWidget {
  const PrenotazioniUtenteScreen({super.key});

  @override
  State<PrenotazioniUtenteScreen> createState() =>
      _PrenotazioniUtenteScreenState();
}

Future<String> fetchCampoName(String campoId) async {
  try {
    final campoDoc = await FirebaseFirestore.instance
        .collection('fields')
        .doc(campoId)
        .get();
    if (campoDoc.exists) {
      String campoName = campoDoc['nome'] ?? 'Campo Non Disponibile';
      return campoName;
    }
    return 'Campo Non Trovato';
  } catch (e) {
    print('Error fetching campo data: $e');
    return 'Errore';
  }
}

class _PrenotazioniUtenteScreenState extends State<PrenotazioniUtenteScreen> {
  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Le Mie Prenotazioni'),
      ),
      body: Consumer<PrenotazioneProvider>(
        builder: (context, prenotazioneProvider, child) {
          return StreamBuilder<List<Prenotazione>>(
            stream: prenotazioneProvider.fetchPrenotazioniStreamByUser(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Errore: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('Nessuna prenotazione trovata'));
              }

              final prenotazioni = snapshot.data!;

              prenotazioni.sort((a, b) {
                int getStatoPriority(Stato stato) {
                  switch (stato) {
                    case Stato.inAttesa:
                      return 1;
                    case Stato.confermata:
                      return 2;
                    case Stato.richiestaModifica:
                      return 3;
                    case Stato.annullata:
                      return 4;
                  }
                }

                // Confronta le prenotazioni in base alla priorità dello stato
                return getStatoPriority(a.stato)
                    .compareTo(getStatoPriority(b.stato));
              });

              return ListView.builder(
                itemCount: prenotazioni.length,
                itemBuilder: (context, index) {
                  final prenotazione = prenotazioni[index];
                  final DateTime prenotazioneData = DateFormat('d MMMM yyyy')
                      .parse(prenotazione.dataPrenotazione);

// Converti l'orario dello slot in un oggetto DateTime
                  final DateTime slotOrario =
                      DateFormat('HH:mm').parse(prenotazione.slot!.orario);
                  final DateTime slotDataOrario = DateTime(
                    prenotazioneData.year,
                    prenotazioneData.month,
                    prenotazioneData.day,
                    slotOrario.hour,
                    slotOrario.minute,
                  );

// Data e orario corrente
                  final DateTime now = DateTime.now();

// Verifica se il tempo rimanente allo slot è maggiore di 24 ore
                  final bool canCancelOrModify = slotDataOrario
                      .subtract(const Duration(hours: 24))
                      .isAfter(now);

// Controllo per mostrare o nascondere il pulsante Annulla
                  final bool canCancel = canCancelOrModify &&
                      prenotazione.stato != Stato.annullata;

// Controllo per mostrare o nascondere il pulsante Modifica
                  final bool canModify = canCancelOrModify &&
                      prenotazione.stato == Stato.confermata;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FutureBuilder<String>(
                                future: fetchCampoName(prenotazione.idCampo),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError ||
                                      snapshot.data == null) {
                                    return Text(
                                      'Campo: Errore o non disponibile',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    );
                                  }
                                  return Flexible(
                                    child: TextScroll(
                                      snapshot.data!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                              ),
                              if (canCancel) // Mostra il pulsante Annulla se mancano più di 24 ore
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Conferma Annullamento'),
                                          content: Text(
                                              'Sei sicuro di voler annullare questa prenotazione?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Annulla'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Slot? sl = prenotazione.slot;
                                                prenotazioneProvider
                                                    .modificaPrenotazioneinAnnullata(
                                                        prenotazione.id);
                                                Provider.of<FirebaseSlotProvider>(
                                                        context,
                                                        listen: false)
                                                    .updateSlotAsAvailable(
                                                        prenotazione.idCampo,
                                                        DateFormat(
                                                                'dd MMMM yyyy')
                                                            .parse(prenotazione
                                                                .dataPrenotazione),
                                                        sl!);

                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Conferma',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Data: ${prenotazione.dataPrenotazione}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          if (prenotazione.slot != null)
                            Text(
                              'Orario Slot: ${prenotazione.slot!.orario}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'Stato: ${prenotazione.stato.toString().split('.').last}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: prenotazione.stato == Stato.inAttesa
                                      ? Colors.orange
                                      : prenotazione.stato == Stato.annullata
                                          ? Colors.red
                                          : prenotazione.stato ==
                                                  Stato.richiestaModifica
                                              ? Colors.blue
                                              : Colors.green,
                                ),
                          ),
                          const SizedBox(height: 12),
                          if (canModify &&
                              prenotazione.stato ==
                                  Stato
                                      .confermata) // Mostra il pulsante Modifica se mancano più di 24 ore e lo stato è confermato
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ModificaPrenotazione(
                                        primaPrenotazione: prenotazione),
                                  ),
                                );
                              },
                              child: const Text('Modifica Prenotazione'),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
