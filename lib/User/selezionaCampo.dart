import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:match_day/Models/campo.dart';
import 'package:match_day/User/prenotazioniUser.dart';
import 'package:match_day/User/selezionaSlot.dart';
import 'package:match_day/User/userSettings.dart';

class CampoSelectionPage extends StatelessWidget {
  const CampoSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seleziona un campo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 34, 40, 49),
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('fields').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 34, 40, 49)),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Errore nel caricamento dei campi',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nessun campo disponibile',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final List<Campo> campi = snapshot.data!.docs.map((doc) {
            return Campo.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: campi.length,
            itemBuilder: (context, index) {
              final campo = campi[index];

              return Card(
                borderOnForeground: true,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Text(
                    campo.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color.fromARGB(255, 34, 40, 49),
                  ),
                  onTap: () {
                    Key('nav_button');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CampoCalendarUser(
                          campo: campo,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      backgroundColor: Colors.grey[100],
      persistentFooterButtons: [
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).primaryColor, // Colore di sfondo della barra
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2), // Ombra sopra la barra
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                key: Key('prenotazioni_utente'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PrenotazioniUtenteScreen(),
                  ));
                },
                icon: const Icon(Icons.bookmark, color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                isSelected: true,
                icon: const Icon(Icons.home, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const Usersettings(),
                  ));
                },
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
