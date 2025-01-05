class Slot {
  final String id;
  final String orario;
  bool disponibile;

  Slot({
    required this.id,
    required this.orario,
    this.disponibile = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orario': orario,
      'disponibile': disponibile,
    };
  }

  factory Slot.fromMap(Map<String, dynamic> map) {
    return Slot(
      id: map['id'] ?? '',
      orario: map['orario'] ?? '',
      disponibile: map['disponibile'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'orario': orario,
      'disponibile': disponibile,
    };
  }

  factory Slot.fromFirestore(Map<String, dynamic> firestoreData) {
    return Slot(
      id: firestoreData['id'] ?? '',
      orario: firestoreData['orario'] ?? '',
      disponibile: firestoreData['disponibile'] ?? true,
    );
  }
}
