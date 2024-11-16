import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:match_day/Models/slot.dart';

class Campo {
  final String id;
  final String nome;
  final Map<String, List<Slot>>
      calendario; // Chiave: Data, Valore: Lista di Slot

  Campo({
    required this.id,
    required this.nome,
    required this.calendario,
  });

  void aggiungiSlot(String data, Slot slot) {
    if (calendario.containsKey(data)) {
      calendario[data]!.add(slot);
    } else {
      calendario[data] = [slot];
    }
  }

  factory Campo.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Campo(
      nome: data['nome'] ?? '',
      id: doc.id,
      calendario: {}, // Usa l'ID del documento come identificatore del campo
    );
  }
}
