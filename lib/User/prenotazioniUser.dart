// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:match_day/Admin/prenotazioni.dart';
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/User/editBooking.dart';
import 'package:provider/provider.dart';
import '../Providers/prenotazioniProvider.dart';

class PrenotazioniUtenteScreen extends StatelessWidget {
  const PrenotazioniUtenteScreen({super.key});

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
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                );
                              }
                              return Text(
                                snapshot.data!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              );
                            },
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
                                          : Colors.green,
                                ),
                          ),
                          const SizedBox(height: 12),
                          // Pulsante di modifica solo se lo stato è confermato
                          if (prenotazione.stato == Stato.confermata)
                            ElevatedButton(
                              onPressed: () {
                                // Logica per la modifica della prenotazione
                                // Puoi navigare a una schermata di modifica o cambiare lo stato della prenotazione
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ModificaPrenotazioneScreen(
                                            prenotazione: prenotazione),
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
