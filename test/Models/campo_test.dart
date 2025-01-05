// ignore_for_file: subtype_of_sealed_class

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:match_day/Models/campo.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group('Campo class test', () {
    test('Campo viene creato correttamente da Firestore con calendario', () {
      // 1. Crea un'istanza di MockDocumentSnapshot
      var mockSnapshot = MockDocumentSnapshot();

      // 2. Configura il mock per restituire un ID e dei dati fittizi
      when(mockSnapshot.id).thenReturn('123'); // Assicurati che non sia nullo

      // 3. Definisci una struttura del calendario con slot mockati
      var calendarioMock = {
        '2024-12-01': [
          {
            'disponibile': true,
            'id': 'slot1',
            'orario': '10:00 - 11:00',
          },
          {
            'disponibile': false,
            'id': 'slot2',
            'orario': '11:00 - 12:00',
          },
        ]
      };

      // 4. Configura il mock per restituire anche il calendario
      when(mockSnapshot.data()).thenReturn({
        'nome': 'Campo di calcio a 8',
        'calendario': calendarioMock, // Restituisci il calendario mockato
      });

      // 5. Crea l'oggetto Campo usando il mockSnapshot
      var campo = Campo.fromFirestore(mockSnapshot);

      // 6. Effettua le verifiche sull'oggetto Campo creato
      expect(campo.id, '123');
      expect(campo.nome, 'Campo di calcio a 8');

      // Verifica che il calendario sia stato popolato correttamente
      expect(campo.calendario.containsKey('2024-12-01'), true);
      expect(campo.calendario['2024-12-01']!.length, 2);

      // Verifica gli attributi del primo slot
      var primoSlot = campo.calendario['2024-12-01']![0];
      expect(primoSlot.id, 'slot1');
      expect(primoSlot.orario, '10:00 - 11:00');
      expect(primoSlot.disponibile, true);

      // Verifica gli attributi del secondo slot
      var secondoSlot = campo.calendario['2024-12-01']![1];
      expect(secondoSlot.id, 'slot2');
      expect(secondoSlot.orario, '11:00 - 12:00');
      expect(secondoSlot.disponibile, false);
    });
  });
}
