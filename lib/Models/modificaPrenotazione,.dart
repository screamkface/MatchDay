import 'prenotazione.dart';

class ModificaPrenotazione {
  final Prenotazione prenotazioneOriginale;
  final Prenotazione nuovaPrenotazione;
  final DateTime timestampModifica;
  String statoModifica; // es. 'inAttesa', 'approvata', 'rifiutata'
  String? motivoModifica;

  ModificaPrenotazione({
    required this.prenotazioneOriginale,
    required this.nuovaPrenotazione,
    required this.timestampModifica,
    this.statoModifica = 'inAttesa',
    this.motivoModifica,
  });

  void approvaModifica() {
    statoModifica = 'approvata';
    // Aggiorna lo stato nel database o nel sistema
  }

  void rifiutaModifica(String motivo) {
    statoModifica = 'rifiutata';
    motivoModifica = motivo;
    // Aggiorna lo stato nel database o nel sistema
  }
}
