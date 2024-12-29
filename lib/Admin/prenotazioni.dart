// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/Providers/slotProvider.dart';
import 'package:match_day/components/custom_snackbar.dart';
import 'package:provider/provider.dart';

import '../Providers/prenotazioniProvider.dart';

Future<String> fetchUserDetails(String userId) async {
  try {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      String nome = userDoc['nome'] ?? '';
      String cognome = userDoc['cognome'] ?? '';
      String phone = userDoc['phone'] ?? '';
      return '$nome $cognome +39 $phone';
    }
    return 'Unknown User';
  } catch (e) {
    print('Error fetching user data: $e');
    return 'Error';
  }
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

class PrenotazioniScreen extends StatelessWidget {
  const PrenotazioniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Prenotazioni'),
      ),
      body: Consumer<PrenotazioneProvider>(
        builder: (context, prenotazioneProvider, child) {
          return StreamBuilder<List<Prenotazione>>(
            stream: prenotazioneProvider.fetchPrenotazioniStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Errore: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nessuna prenotazione'));
              }

              final prenotazioni = snapshot.data!;

              return ListView.builder(
                itemCount: prenotazioni.length,
                itemBuilder: (context, index) {
                  final prenotazione = prenotazioni[index];
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
                          FutureBuilder<String>(
                            future: fetchCampoName(prenotazione.idCampo),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError || snapshot.data == null) {
                                return Text(
                                  'Campo: Errore o non disponibile',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                );
                              }
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    snapshot.data!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      prenotazioneProvider
                                          .eliminaPrenotazione(prenotazione.id)
                                          .then((value) {});
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text("Prenotazione Eliminata"),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<String>(
                            future: fetchUserDetails(prenotazione.idUtente),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError || snapshot.data == null) {
                                return Text('Utente: Errore o non disponibile');
                              }
                              return Text(
                                snapshot.data!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
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
                          if (prenotazione.stato == Stato.inAttesa)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    prenotazioneProvider
                                        .accettaPrenotazione(prenotazione.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Accetta'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    prenotazioneProvider.rifiutaPrenotazione(
                                      prenotazione.id,
                                      prenotazione.idCampo,
                                      prenotazione.slot!.id,
                                      prenotazione.dataPrenotazione,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Prenotazione Annullata"),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Rifiuta'),
                                ),
                              ],
                            ),
                          if (prenotazione.stato == Stato.richiestaModifica)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    prenotazioneProvider
                                        .accettaModificaPrenotazione(
                                      prenotazione.id,
                                      prenotazione.idCampo,
                                      prenotazione.slot!.id,
                                      prenotazione.dataPrenotazione,
                                      prenotazione.slot!.orario,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Modifica Confermata"),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Accetta Modifica'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    prenotazioneProvider.aggiornaPrenotazione(
                                      prenotazione.id,
                                      Stato.annullata,
                                    );

                                    Slot? sl = prenotazione.slot;

                                    Provider.of<FirebaseSlotProvider>(context,
                                            listen: false)
                                        .updateSlotAsAvailable(
                                            prenotazione.idCampo,
                                            DateFormat('dd MMMM yyyy').parse(
                                                prenotazione
                                                    .dataPrenotazione), // Conversione corretta
                                            sl!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Modifica Rifiutata"),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Rifiuta Modifica'),
                                ),
                              ],
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
