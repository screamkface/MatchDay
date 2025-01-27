import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:match_day/main.dart'; // Assicurati che il percorso sia corretto

void main() async {
  // Inizializzazione di Firebase per piattaforme non web e non Windows
  if (!kIsWeb && !Platform.isWindows) {
    await Firebase.initializeApp();
  }

  group('Test di integrazione del login', () {
    testWidgets('Login con credenziali valide e verifica pagina SelezionaCampo',
        (WidgetTester tester) async {
      await Firebase.initializeApp();
      await tester.pumpWidget(MyApp()); // Usa la tua widget app principale

      final emailField = find.byKey(Key('email_input'));
      final passwordField = find.byKey(Key('password_input'));
      final loginButton = find.byKey(Key('submit_button'));

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      await tester.enterText(
          emailField, 'nicolamoscufo7@gmail.com'); // Usa credenziali di test
      await tester.enterText(
          passwordField, 'prova123!'); // Usa credenziali di test
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verifica che l'utente sia stato reindirizzato alla pagina SelezionaCampo
      expect(find.text('Seleziona il campo'), findsOneWidget);
      // Verifica un elemento specifico della pagina
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.widgetWithIcon(IconButton, Icons.home), findsOneWidget);
    });

    testWidgets('Login con credenziali non valide',
        (WidgetTester tester) async {
      await Firebase.initializeApp();
      await tester.pumpWidget(MyApp()); // Usa la tua widget app principale

      final emailField = find.byKey(Key('email_input'));
      final passwordField = find.byKey(Key('password_input'));
      final loginButton = find.byKey(Key('submit_button'));

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      await tester.enterText(emailField, 'wrong@example.com');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verifica la presenza di un messaggio di errore nel UI
      expect(find.text('Credenziali errate'), findsOneWidget);
    });
  });
}
