class Slot {
  final String orario;
  bool disponibile;

  Slot({required this.orario, this.disponibile = true});

  // Metodo per convertire il Slot in una mappa
  Map<String, dynamic> toMap() {
    return {
      'orario': orario,
      'disponibile': disponibile,
    };
  }

  // Metodo per creare un Slot da una mappa
  factory Slot.fromMap(Map<String, dynamic> map) {
    return Slot(
      orario: map['orario'] ?? '',
      disponibile: map['disponibile'] ?? true,
    );
  }
}
