import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:match_day/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Crea una mock class per SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {
  @override
  Future<bool> setString(String key, String value) async => true;

  @override
  String? getString(String key) => null;

  @override
  Future<bool> setBool(String key, bool value) async => true;

  @override
  bool? getBool(String key) => null;

  @override
  Future<bool> setInt(String key, int value) async => true;

  @override
  int? getInt(String key) => null;

  @override
  Future<bool> remove(String key) async => true;

  @override
  Future<bool> clear() async => true;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences all'inizio, prima di Firebase
  registerFallbackValue(MockSharedPreferences());
  when(() => SharedPreferences.getInstance())
      .thenAnswer((_) async => MockSharedPreferences());

  // Inizializzazione di Firebase (prima dell'uso di `MyApp()`)
  if (!kIsWeb && !Platform.isWindows) {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp();
  }

  group('Test di integrazione del flusso di prenotazione', () {
    testWidgets('Test prenotazione di uno slot specifico',
        (WidgetTester tester) async {
      debugPrint('Inizio test: Test prenotazione di uno slot specifico');

      await tester.pumpWidget(MyApp());
      debugPrint('MyApp caricato');

      // 1. Login
      final emailField = find.byKey(Key('email_input'));
      final passwordField = find.byKey(Key('password_input'));
      final loginButton = find.byKey(Key('submit_button'));

      expect(emailField, findsOneWidget, reason: 'Email field non trovato');
      expect(passwordField, findsOneWidget,
          reason: 'Password field non trovato');
      expect(loginButton, findsOneWidget, reason: 'Login button non trovato');
      debugPrint('Widget di login trovati');

      await tester.enterText(emailField, 'nicolamoscufo7@gmail.com');
      await tester.enterText(passwordField, 'prova123!');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      debugPrint('Login effettuato');

      // 2. Selezione del Campo SPECIFICO
      expect(find.text('Seleziona il campo'), findsOneWidget,
          reason: 'Pagina SelezionaCampo non trovata');
      debugPrint('Pagina SelezionaCampo trovata');

      await tester.pumpAndSettle();

      // Individua il campo di test
      final campoItem = find.widgetWithText(ListTile,
          "Campo di calcio a 5 (inferiore)"); // Sostituisci "Campo di test" col nome del tuo campo test
      expect(campoItem, findsOneWidget, reason: 'Campo di test non trovato');

      await tester.tap(campoItem); // Seleziona il campo di test
      debugPrint('Campo di test selezionato');
      await tester.pumpAndSettle();

      expect(find.text('Dettagli campo'), findsOneWidget,
          reason: 'Pagina dettagli campo non trovata');
      debugPrint('Pagina dettaglio campo trovata');

      // Simula la navigazione alla pagina di prenotazione (adattalo alla tua UI)
      await tester.tap(find.byKey(Key('prenota_button')));
      await tester.pumpAndSettle();
      debugPrint('Navigazione alla schermata di prenotazione');

      // 3. Selezione della Data e dell'Orario SPECIFICO

      // Trova e seleziona il calendario con la key
      await tester.tap(find.byKey(Key('calendar_button')));
      await tester.pumpAndSettle();
      // Trova e seleziona il giorno 28
      await tester.tap(find.text('28'));
      await tester.pumpAndSettle();
      debugPrint('Data 28 selezionata');

      await tester.pumpAndSettle();
      // Trova lo slot specifico "10:30 - 11:30"
      final slotItem = find.widgetWithText(ListTile, "10:30 - 11:30");
      expect(slotItem, findsOneWidget,
          reason: "Slot 10:30 - 11:30 non trovato");
      final slot = tester.widget<ListTile>(slotItem);
      expect(slot.tileColor, Colors.green,
          reason: "Lo slot 10:30 - 11:30 non è disponibile");
      await tester.tap(slotItem);

      debugPrint('Slot 10:30 - 11:30 Selezionato');

      await tester.pumpAndSettle();
      // 4. Conferma della Prenotazione
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      debugPrint('Conferma Prenotazione effettuata');

      // 5. Verifica della Prenotazione
      expect(find.text('Slot prenotato con successo!'), findsOneWidget,
          reason: 'Snackbar di successo non trovato');

      debugPrint(
          'Test prenotazione di uno slot specifico completato con successo');
    });
  });
}
