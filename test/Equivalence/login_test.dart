import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:match_day/main.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding
      .ensureInitialized(); // Inizializza il binding di test
  await Firebase.initializeApp();
  testWidgets('Equivalence Class Testing per form di login',
      (WidgetTester tester) async {
    // Costruisci l'app
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Ora siamo sulla pagina di login, trova i widget di input
    final Finder emailInput = find.byKey(Key('email_input'));
    final Finder passwordInput = find.byKey(Key('password_input'));
    final Finder submitButton = find.byKey(Key('submit_button'));

    // Verifica che i widget siano trovati
    expect(emailInput, findsOneWidget);
    expect(passwordInput, findsOneWidget);
    expect(submitButton, findsOneWidget);

    // **Caso 1: Entrambi i campi validi**
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, 'Password123!');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // **Caso 2: Email vuota (classe invalida)**
    await tester.enterText(emailInput, '');
    await tester.enterText(passwordInput, 'Password123!');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Inserisci la tua email'), findsOneWidget);

    // **Caso 3: Email non valida (classe invalida)**
    await tester.enterText(emailInput, 'invalid-email');
    await tester.enterText(passwordInput, 'Password123!');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Inserisci un\'email valida'), findsOneWidget);

    // **Caso 4: Password vuota (classe invalida)**
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, '');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Inserisci la tua password'), findsOneWidget);

    // **Caso 5: Password troppo corta (classe invalida)**
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, '123');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('La password è troppo corta'), findsOneWidget);

    // **Caso 6: Password senza lettere e numeri (classe invalida)**
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, 'password');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(
        find.text('La password deve contenere almeno una lettera e un numero'),
        findsOneWidget);

    // **Caso 7: Credenziali corrette (login riuscito)**
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, 'Password123!');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
  });
}
