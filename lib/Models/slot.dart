class Slot {
  final String id; // Aggiungi l'ID dello slot
  final String orario;
  bool disponibile;

  Slot({
    required this.id, // Rendi obbligatorio l'ID
    required this.orario,
    this.disponibile = true,
  });

  // Metodo per convertire il Slot in una mappa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orario': orario,
      'disponibile': disponibile,
    };
  }

  // Metodo per creare un Slot da una mappa
  factory Slot.fromMap(Map<String, dynamic> map) {
    return Slot(
      id: map['id'] ?? '', // Assicurati che l'ID sia presente
      orario: map['orario'] ?? '',
      disponibile: map['disponibile'] ?? true,
    );
  }
}
