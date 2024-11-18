import 'package:firebase_data_connect/firebase_data_connect.dart';

enum Stato {
  confermata,
  inAttesa,
  annullata,
}

class Prenotazione {
  final String id;
  final DateTime dataPrenotazione;
  final Stato stato;
  final String idCampo;
  final String? idUtente;

  Prenotazione({
    required this.id,
    required this.dataPrenotazione,
    required this.stato,
    required this.idCampo,
    required this.idUtente,
  });

  // Factory method to convert a map into a Prenotazione object
  factory Prenotazione.fromMap(Map<String, dynamic> map) {
    return Prenotazione(
      id: map['id'],
      dataPrenotazione: (map['dataPrenotazione'] as Timestamp).toDateTime(),
      stato: Stato.values.firstWhere((e) =>
          e.toString().split('.').last ==
          map['stato']), // Converte la stringa di nuovo in enum
      idCampo: map['idCampo'],
      idUtente: map['idUtente'],
    );
  }

  // Method to convert Prenotazione to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dataPrenotazione': dataPrenotazione,
      'stato': stato.toString().split('.').last,
      'idCampo': idCampo,
      'idUtente': idUtente,
    };
  }
}
