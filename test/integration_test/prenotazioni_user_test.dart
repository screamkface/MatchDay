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

  // Inizializzazione di Firebase
  if (!kIsWeb && !Platform.isWindows) {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp();
  }

  group('Test di integrazione della lista delle prenotazioni utente', () {
    testWidgets('Test visualizzazione lista prenotazioni',
        (WidgetTester tester) async {
      debugPrint('Inizio test: Test visualizzazione lista prenotazioni');

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

      // 2. Navigazione alla Lista Prenotazioni
      await tester.tap(find.byKey(Key('lista_prenotazioni_button')));
      await tester.pumpAndSettle();
      debugPrint('Navigazione alla schermata delle prenotazioni');

      expect(find.text('Le mie Prenotazioni'), findsOneWidget,
          reason: 'Pagina prenotazioni non trovata');
      debugPrint('Pagina prenotazioni trovata');

      // 3. Verifica della Lista Prenotazioni
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsWidgets,
          reason: 'Nessuna prenotazione trovata');
      debugPrint('Trovate le prenotazioni');

      if (find.byType(ListTile).evaluate().isNotEmpty) {
        final primaPrenotazione = find.byType(ListTile).first;
        await tester.tap(primaPrenotazione);
        await tester.pumpAndSettle();

        expect(find.text('Dettagli Prenotazione'), findsOneWidget,
            reason: 'Pagina dettagli prenotazione non trovata');
        debugPrint('Pagina dettagli prenotazione trovata');

        await tester.tap(find.byKey(Key('back_button')));
        await tester.pumpAndSettle();
      }

      debugPrint(
          'Test visualizzazione lista prenotazioni completato con successo');
    });
  });
}
