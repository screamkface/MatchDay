import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:match_day/main.dart' as app;
import 'package:match_day/Models/prenotazione.dart';
import 'package:match_day/Models/slot.dart';
import 'package:match_day/Providers/prenotazioniProvider.dart';
import 'package:match_day/Providers/slotProvider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'Provider Test/test_prenotazioni_provider.dart';
import 'Provider Test/test_slot_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Modifica Prenotazione Flow', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;
    late String userId;

    setUp(() async {
      // Setup Firebase mocks
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
      await Firebase.initializeApp();
      userId = (await mockAuth.createUserWithEmailAndPassword(
              email: 'test@example.com', password: 'password'))
          .user!
          .uid;
      mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com', password: 'password');

      userId = mockAuth.currentUser!.uid;

      // Inserisci dati di test nel Firestore (simula prenotazione accettata e slot disponibili)
      final now = DateTime.now();
      final todayString = DateFormat("d MMMM yyyy").format(now);
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowString = DateFormat("d MMMM yyyy").format(tomorrow);
      final slot1 = Slot(id: 'slot1', orario: '10:00', disponibile: false);
      final slot2 = Slot(id: 'slot2', orario: '11:00', disponibile: true);
      final slot3 = Slot(id: 'slot3', orario: '12:00', disponibile: true);
      final prenotazioneAccettata = Prenotazione(
        id: 'prenotazione1',
        idUtente: userId,
        dataPrenotazione: todayString,
        stato: Stato.confermata,
        idCampo: 'campo1',
        slot: slot1,
      );

      await fakeFirestore
          .collection('fields')
          .doc('Campo di calcio a 5 (inferiore)')
          .collection('slots')
          .doc(DateFormat('yyyy-MM-dd').format(tomorrow))
          .set({
        'slots': [
          {
            'id': slot2.id,
            'orario': slot2.orario,
            'disponibile': slot2.disponibile
          },
          {
            'id': slot3.id,
            'orario': slot3.orario,
            'disponibile': slot3.disponibile
          },
        ]
      });
      await fakeFirestore
          .collection('fields')
          .doc('campo1')
          .collection('slots')
          .doc(DateFormat('yyyy-MM-dd').format(now))
          .set({
        'slots': [
          {
            'id': slot1.id,
            'orario': slot1.orario,
            'disponibile': slot1.disponibile
          },
        ]
      });
      await fakeFirestore
          .collection('prenotazioni')
          .doc('prenotazione1')
          .set(prenotazioneAccettata.toJson());
    });

    testWidgets(
      'Test modifica prenotazione completa',
      (WidgetTester tester) async {
        await Firebase.initializeApp();
        // Build our app and trigger a frame.
        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => TestPrenotazioneProvider(
                  auth: mockAuth, firestore: fakeFirestore),
            ),
            ChangeNotifierProvider(
              create: (_) => TestFirebaseSlotProvider(firestore: fakeFirestore),
            ),
          ],
          child: const app.MyApp(),
        ));

        await tester.pumpAndSettle();

        // 0. Simula il Login
        await tester.enterText(
            find.byType(TextFormField).at(0), 'nicolamoscufo7@gmail.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'prova123!');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        // 1. Naviga alla pagina delle prenotazioni
        await tester.tap(find.byIcon(Icons.calendar_month));
        await tester.pumpAndSettle();

        // Verifica che la prenotazione sia presente e il pulsante modifica
        expect(find.text('Modifica Prenotazione'), findsOneWidget);
        // 2. Clicca sul pulsante modifica
        await tester.tap(find.text('Modifica Prenotazione'));
        await tester.pumpAndSettle();

        //  3. Seleziona un nuovo giorno dal calendario (il giorno dopo)
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        await tester.tap(find.text(tomorrow.day.toString()));
        await tester.pumpAndSettle();

        //  4. Seleziona un nuovo slot disponibile
        expect(find.text('11:00'), findsOneWidget);
        await tester.tap(find.ancestor(
            of: find.text('11:00'), matching: find.byType(ListTile)));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Modifica'));
        await tester.pumpAndSettle();

        expect(
            find.text("Prenotazione modificata con successo!"), findsOneWidget);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        // 5. Verifica che la nuova prenotazione sia stata creata e la vecchia annullata

        final prenotazioni = await fakeFirestore
            .collection('prenotazioni')
            .where('idUtente', isEqualTo: userId)
            .get();

        // Verifica che ci sia una nuova prenotazione
        expect(prenotazioni.docs.length, 1);
        final nuovaPrenotazione = Prenotazione.fromJson(
            prenotazioni.docs.first.data(), prenotazioni.docs.first.id);
        expect(nuovaPrenotazione.stato, Stato.richiestaModifica);
        expect(nuovaPrenotazione.dataPrenotazione,
            DateFormat("yyyy-MM-dd 00:00:00.000").format(tomorrow));

        //  Verifica che lo slot originale sia di nuovo disponibile

        final slotOriginale = await fakeFirestore
            .collection('campi')
            .doc('campo1')
            .collection('slots')
            .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
            .get();

        expect(slotOriginale.data()?['slots'][0]['disponibile'], true);

        // Verifica che il nuovo slot non sia disponibile
        final newSlot = await fakeFirestore
            .collection('campi')
            .doc('campo1')
            .collection('slots')
            .doc(DateFormat('yyyy-MM-dd').format(tomorrow))
            .get();
        expect(newSlot.data()?['slots'][0]['disponibile'], false);
      },
    );
  });
}
