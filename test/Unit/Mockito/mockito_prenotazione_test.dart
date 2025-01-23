import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase
import 'package:match_day/Models/slot.dart';
import 'package:match_day/Providers/slotProvider.dart';
import 'package:match_day/DAO/slotDao.dart';

class MockSlotDao extends Mock implements SlotDao {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Inizializza il binding

  setUpAll(() {
    // Simula l'inizializzazione di Firebase
    when(Firebase.initializeApp()).thenAnswer((_) async => Future.value());
  });

  late MockSlotDao mockSlotDao;
  late FirebaseSlotProvider slotProvider;

  setUp(() {
    mockSlotDao = MockSlotDao();
    slotProvider = FirebaseSlotProvider();
  });

  //ADDSLOT
  test('Verifica che addSlot chiami SlotDao con i dati corretti', () async {
    final String id = "campo123";
    final DateTime selectedDay = DateTime(2025, 01, 20);
    final Slot slot = Slot(id: 'slot123', orario: "10:00 - 11:00");

    // Simula l'interazione con SlotDao
    when(mockSlotDao.addSlot(id, selectedDay, slot))
        .thenAnswer((_) async => Future.value());

    // Chiama addSlot dal provider
    await slotProvider.addSlot(id, selectedDay, slot);

    // Verifica che addSlot sia stato chiamato correttamente con gli argomenti corretti
    verify(mockSlotDao.addSlot(id, selectedDay, slot)).called(1);
  });
}
