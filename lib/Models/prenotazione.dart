// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:match_day/Models/slot.dart';

enum Stato {
  confermata,
  inAttesa,
  annullata,
}

class Prenotazione extends ChangeNotifier {
  final String id;
  final String dataPrenotazione;
  final Stato stato;
  final String idCampo;
  final String idUtente;
  final Slot? slot;

  Prenotazione({
    required this.id,
    required this.dataPrenotazione,
    required this.stato,
    required this.idCampo,
    required this.idUtente,
    this.slot,
  });

  factory Prenotazione.fromMap(Map<String, dynamic> map, String id) {
    var data = map['dataPrenotazione'];
    DateTime dataPrenotazione;

    // Se la data è una stringa, convertila in DateTime
    if (data is String) {
      dataPrenotazione = DateTime.parse(data);
    } else {
      dataPrenotazione =
          DateTime.now(); // Imposta una data predefinita se non è valida
    }

    return Prenotazione(
      id: id,
      dataPrenotazione: dataPrenotazione.toString(),
      stato: Stato.values.byName(map['stato'] as String),
      idCampo: map['idCampo'] as String,
      idUtente: map['idUtente'] as String,
      slot: map['slot'] != null ? Slot.fromFirestore(map['slot']) : null,
    );
  }

  // Aggiungi questa funzione per ottenere la data formattata
  String get formattedDataPrenotazione {
    final DateTime date = DateTime.parse(dataPrenotazione);
    final DateFormat formatter =
        DateFormat('dd MMMM yyyy'); // Modifica il formato come desiderato
    return formatter.format(date);
  }

  factory Prenotazione.fromFirestore(DocumentSnapshot doc) {
    return Prenotazione(
      id: doc.id, // Questo è l'ID del documento
      idUtente: doc['idUtente'],
      idCampo: doc['idCampo'],
      dataPrenotazione: doc['dataPrenotazione'],
      stato: Stato.values[doc['stato']],
    );
  }

  Map<String, dynamic> toMap() {
    final DateTime date = DateTime.parse(dataPrenotazione);
    final DateFormat formatter =
        DateFormat('dd MMMM yyyy'); // Il formato che preferisci
    String formattedDate = formatter.format(date);

    return {
      'id': id,
      'dataPrenotazione': formattedDate, // Usa la data formattata
      'stato': stato.toString().split('.').last,
      'idCampo': idCampo,
      'idUtente': idUtente,
      'slot': slot?.toMap(),
    };
  }
}
