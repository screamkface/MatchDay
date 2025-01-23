import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/Providers/slotProvider.dart';
import 'package:match_day/DAO/slotDao.dart';
import 'package:firebase_core/firebase_core.dart'; // Aggiungi questa importazione

// Crea una classe mock per SlotDao
class MockSlotDao extends Mock implements SlotDao {}

void main() async {
  // Inizializza Firebase per i test
  TestWidgetsFlutterBinding
      .ensureInitialized(); // Inizializza il binding di test
  await Firebase.initializeApp(); // Inizializza Firebase per il testing

  late MockSlotDao mockSlotDao;
  late FirebaseSlotProvider slotProvider;

  setUp(() {
    mockSlotDao = MockSlotDao();
    slotProvider = FirebaseSlotProvider();
  });

  test('Verifica che fetchSlotsStream ritorni la lista corretta di slot',
      () async {
    final String campoId = "campo123";
    final DateTime selectedDay = DateTime(2025, 01, 20);

    // Simula i dati che vorresti che fossero restituiti dal metodo di fetching
    final List<Slot> mockSlots = [
      Slot(id: 'slot123', orario: "10:00 - 11:00"),
      Slot(id: 'slot124', orario: "11:00 - 12:00"),
    ];

    // Simula il comportamento di fetchSlotsStream, in modo che ritorni i mockSlots
    when(mockSlotDao.fetchSlotsStream(campoId, selectedDay))
        .thenAnswer((_) => Stream.value(mockSlots));

    // Chiamata al metodo del provider
    final slotsStream = slotProvider.fetchSlotsStream(campoId, selectedDay);

    // Verifica che il provider restituisca la lista corretta di slot
    await expectLater(
      slotsStream,
      emitsInOrder([mockSlots]), // Verifica che il flusso contenga i mockSlots
    );

    // Verifica che fetchSlotsStream sia stato chiamato correttamente
    verify(mockSlotDao.fetchSlotsStream(campoId, selectedDay)).called(1);
  });

  //addslot
  test('Verifica che addSlot chiami SlotDao con i dati corretti', () async {
    final String campoId = "campo123";
    final DateTime selectedDay = DateTime(2025, 01, 20);
    final Slot slot = Slot(id: 'slot123', orario: "10:00 - 11:00");

    // Simula l'interazione con SlotDao
    when(mockSlotDao.addSlot(campoId, selectedDay, slot))
        .thenAnswer((_) async => Future.value());

    // Chiama addSlot dal provider
    await slotProvider.addSlot(campoId, selectedDay, slot);

    // Verifica che addSlot sia stato chiamato correttamente
    verify(mockSlotDao.addSlot(campoId, selectedDay, slot)).called(1);
  });

//remove slot
  test('Verifica che removeSlot chiami SlotDao con i dati corretti', () async {
    final String campoId = "campo123";
    final DateTime selectedDay = DateTime(2025, 01, 20);
    final Slot slot = Slot(id: 'slot123', orario: "10:00 - 11:00");

    // Simula l'interazione con SlotDao
    when(mockSlotDao.removeSlot(campoId, selectedDay, slot))
        .thenAnswer((_) async => Future.value());

    // Chiama removeSlot dal provider
    await slotProvider.removeSlot(campoId, selectedDay, slot);

    // Verifica che removeSlot sia stato chiamato correttamente
    verify(mockSlotDao.removeSlot(campoId, selectedDay, slot)).called(1);
  });

//updateSlot
  test('Verifica che updateSlot chiami SlotDao con i dati corretti', () async {
    final String campoId = "campo123";
    final DateTime selectedDay = DateTime(2025, 01, 20);
    final Slot slot = Slot(id: 'slot123', orario: "10:00 - 11:00");

    // Simula l'interazione con SlotDao
    when(mockSlotDao.updateSlot(campoId, selectedDay, slot))
        .thenAnswer((_) async => Future.value());

    // Chiama updateSlot dal provider
    await slotProvider.updateSlot(campoId, selectedDay, slot);

    // Verifica che updateSlot sia stato chiamato correttamente
    verify(mockSlotDao.updateSlot(campoId, selectedDay, slot)).called(1);
  });

//updateSlotAvailability
  test('Verifica che updateSlotAvailability chiami SlotDao con i dati corretti',
      () async {
    final String campoId = "campo123";
    final DateTime selectedDay = DateTime(2025, 01, 20);
    final Slot slot = Slot(id: 'slot123', orario: "10:00 - 11:00");

    // Simula l'interazione con SlotDao
    when(mockSlotDao.updateSlotAvailability(campoId, selectedDay, slot))
        .thenAnswer((_) async => Future.value());

    // Chiama updateSlotAvailability dal provider
    await slotProvider.updateSlotAvailability(campoId, selectedDay, slot);

    // Verifica che updateSlotAvailability sia stato chiamato correttamente
    verify(mockSlotDao.updateSlotAvailability(campoId, selectedDay, slot))
        .called(1);
  });

//removePastSlots

  test('Verifica che removePastSlots chiami SlotDao con i dati corretti',
      () async {
    final String campoId = "campo123";

    // Simula l'interazione con SlotDao
    when(mockSlotDao.removePastSlots(campoId))
        .thenAnswer((_) async => Future.value());

    // Chiama removePastSlots dal provider
    await slotProvider.removePastSlots(campoId);

    // Verifica che removePastSlots sia stato chiamato correttamente
    verify(mockSlotDao.removePastSlots(campoId)).called(1);
  });

  //generateHourlySlots
  test('Verifica che generateHourlySlots chiami SlotDao con i dati corretti',
      () async {
    final DateTime startHour = DateTime(2025, 01, 20, 10, 00);
    final DateTime endHour = DateTime(2025, 01, 20, 18, 00);
    final String campoId = "campo123";
    final DateTime selectedDay = DateTime(2025, 01, 20);

    // Simula l'interazione con SlotDao
    when(mockSlotDao.generateHourlySlots(
            startHour, endHour, campoId, selectedDay))
        .thenAnswer((_) async => Future.value());

    // Chiama generateHourlySlots dal provider
    await slotProvider.generateHourlySlots(
        startHour, endHour, campoId, selectedDay);

    // Verifica che generateHourlySlots sia stato chiamato correttamente
    verify(mockSlotDao.generateHourlySlots(
            startHour, endHour, campoId, selectedDay))
        .called(1);
  });
}
