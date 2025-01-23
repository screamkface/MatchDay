import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:match_day/Providers/prenotazioniProvider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:match_day/DAO/prenotazioniDao.dart';
import 'package:match_day/Models/slot.dart';

// Genera un mock per il PrenotazioniDao
import 'prenotazione_test.mocks.dart';

@GenerateMocks([PrenotazioniDao])
Future<void> main() async {
  // Inizializza Firebase per i test
  TestWidgetsFlutterBinding
      .ensureInitialized(); // Inizializza il binding di test
  await Firebase.initializeApp();
  late MockPrenotazioniDao mockPrenotazioniDao;
  late PrenotazioneProvider prenotazioneProvider;

  setUp(() {
    // Crea il mock e il provider prima di ogni test
    mockPrenotazioniDao = MockPrenotazioniDao();
    prenotazioneProvider = PrenotazioneProvider();
    // Inject mock PrenotazioniDao in the provider if needed
    prenotazioneProvider = PrenotazioneProvider();
  });

  group('PrenotazioneProvider Test', () {
    test('fetchPrenotazioni should call fetchPrenotazioni from DAO', () async {
      when(mockPrenotazioniDao.fetchPrenotazioni()).thenAnswer((_) async {});

      await prenotazioneProvider.fetchPrenotazioni();

      verify(mockPrenotazioniDao.fetchPrenotazioni()).called(1);
    });

    test('rifiutaPrenotazione should call rifiutaPrenotazione from DAO',
        () async {
      const prenotazioneId = 'testPrenotazioneId';
      const campoId = 'campoId';
      const slotId = 'slotId';
      const dataPrenotazione = '2024-01-01';

      when(mockPrenotazioniDao.rifiutaPrenotazione(any, any, any, any))
          .thenAnswer((_) async {});

      await prenotazioneProvider.rifiutaPrenotazione(
          prenotazioneId, campoId, slotId, dataPrenotazione);

      verify(mockPrenotazioniDao.rifiutaPrenotazione(
              prenotazioneId, campoId, slotId, dataPrenotazione))
          .called(1);
    });

    test(
        'modificaPrenotazione should call modificaPrenotazioneConSlot from DAO',
        () async {
      // Arrange: mocking del metodo
      const id = 'testPrenotazioneId';
      const dataPrenotazioneString = '2024-01-01';
      const idCampoPrecedente = 'campoPrecedenteId';
      const slotPrecedenteId = 'slotPrecedenteId';
      final selectedSlot = Slot(
          orario: '10:00 - 11:00', id: slotPrecedenteId, disponibile: true);

      when(mockPrenotazioniDao.modificaPrenotazioneConSlot(
              any, any, any, any, any))
          .thenAnswer((_) async {});

      // Act: chiama il metodo
      await prenotazioneProvider.modificaPrenotazione(
          id,
          dataPrenotazioneString,
          selectedSlot,
          idCampoPrecedente,
          slotPrecedenteId);

      verify(mockPrenotazioniDao.modificaPrenotazioneConSlot(
              id,
              dataPrenotazioneString,
              selectedSlot,
              idCampoPrecedente,
              slotPrecedenteId))
          .called(1);
    });

    test('rifiutaPrenotazione should call rifiutaPrenotazione from DAO',
        () async {
      const prenotazioneId = 'testPrenotazioneId';
      const campoId = 'campoId';
      const slotId = 'slotId';
      const dataPrenotazione = '2024-01-01';

      when(mockPrenotazioniDao.rifiutaPrenotazione(any, any, any, any))
          .thenAnswer((_) async {});

      await prenotazioneProvider.rifiutaPrenotazione(
          prenotazioneId, campoId, slotId, dataPrenotazione);

      verify(mockPrenotazioniDao.rifiutaPrenotazione(
              prenotazioneId, campoId, slotId, dataPrenotazione))
          .called(1);
    });

    test(
        'modificaPrenotazione should call modificaPrenotazioneConSlot from DAO',
        () async {
      const id = 'testPrenotazioneId';
      const dataPrenotazioneString = '2024-01-01';
      const idCampoPrecedente = 'campoPrecedenteId';
      const slotPrecedenteId = 'slotPrecedenteId';
      final selectedSlot = Slot(
          orario: '10:00 - 11:00', id: slotPrecedenteId, disponibile: true);

      when(mockPrenotazioniDao.modificaPrenotazioneConSlot(
              any, any, any, any, any))
          .thenAnswer((_) async {});

      await prenotazioneProvider.modificaPrenotazione(
          id,
          dataPrenotazioneString,
          selectedSlot,
          idCampoPrecedente,
          slotPrecedenteId);

      verify(mockPrenotazioniDao.modificaPrenotazioneConSlot(
              id,
              dataPrenotazioneString,
              selectedSlot,
              idCampoPrecedente,
              slotPrecedenteId))
          .called(1);
    });

    // Aggiungi il test per eliminaPrenotazione
    test('eliminaPrenotazione should call eliminaPrenotazione from DAO',
        () async {
      const prenotazioneId = 'testPrenotazioneId';

      when(mockPrenotazioniDao.eliminaPrenotazione(prenotazioneId))
          .thenAnswer((_) async {});

      await prenotazioneProvider.eliminaPrenotazione(prenotazioneId);

      verify(mockPrenotazioniDao.eliminaPrenotazione(prenotazioneId)).called(1);
    });

    // Aggiungi il test per accettaPrenotazione
    test('accettaPrenotazione should call accettaPrenotazione from DAO',
        () async {
      const prenotazioneId = 'testPrenotazioneId';

      when(mockPrenotazioniDao.accettaPrenotazione(prenotazioneId))
          .thenAnswer((_) async {});

      await prenotazioneProvider.accettaPrenotazione(prenotazioneId);

      verify(mockPrenotazioniDao.accettaPrenotazione(prenotazioneId)).called(1);
    });
  });
}
