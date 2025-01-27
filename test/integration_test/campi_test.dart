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

  group('Test di integrazione della Pagina SelezionaCampo', () {
    testWidgets('Test caricamento campi e selezione',
        (WidgetTester tester) async {
      debugPrint('Inizio test: Test caricamento campi e selezione');
      await tester.pumpWidget(MyApp());
      debugPrint('MyApp caricato');

      //Login
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

      // Verifica che la schermata "SelezionaCampo" sia visibile
      expect(find.text('Seleziona il campo'), findsOneWidget,
          reason: 'Pagina SelezionaCampo non trovata');
      debugPrint('Pagina SelezionaCampo trovata');

      // Attendi il caricamento dei campi (se asincrono)
      await tester.pumpAndSettle();
      debugPrint('Caricamento dei campi completato');

      // Verifica la presenza di almeno un campo nella lista (modificato per gestire il caso in cui non ci sono campi)
      expect(find.byType(ListTile), findsWidgets,
          reason: 'Nessun campo trovato');
      debugPrint('Trovati i campi');

      if (find.byType(ListTile).evaluate().isNotEmpty) {
        // Simula la selezione del primo campo
        await tester.tap(find.byType(ListTile).first);
        debugPrint('Campo selezionato');

        await tester.pumpAndSettle();
        await Future.delayed(Duration(milliseconds: 100));
        // Verifica che l'utente sia stato reindirizzato alla pagina dei dettagli del campo
        expect(find.text('Campo di calcio a 5 (inferiore)'), findsOneWidget,
            reason: 'Pagina dettagli campo non trovata');
        debugPrint('Pagina dettaglio campo trovata');
      }
      debugPrint('Test "Test caricamento campi e selezione" completato');
    });
  });
}
