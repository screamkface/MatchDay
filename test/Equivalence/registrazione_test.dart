import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:match_day/main.dart';

void main() {
  testWidgets('Equivalence Class Testing per form di registrazione',
      (WidgetTester tester) async {
    // Costruisci l'app
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Trova il pulsante per andare alla pagina di registrazione
    final Finder registrazioneButton = find.byKey(Key('registrazione_button'));
    expect(registrazioneButton, findsOneWidget);

    // Simula il tap sul pulsante per andare alla pagina di registrazione
    await tester.tap(registrazioneButton);
    await tester.pumpAndSettle(); // Aspetta che la navigazione sia completata

    // Ora siamo sulla pagina di registrazione, trova i widget di input
    final Finder nomeInput = find.byKey(Key('nome_input'));
    final Finder cognomeInput = find.byKey(Key('cognome_input'));
    final Finder emailInput = find.byKey(Key('email_input'));
    final Finder passwordInput = find.byKey(Key('password_input'));
    final Finder telefonoInput = find.byKey(Key('telefono_input'));
    final Finder submitButton = find.byKey(Key('submit_button'));

    // Verifica che i widget siano trovati
    expect(nomeInput, findsOneWidget);
    expect(cognomeInput, findsOneWidget);
    expect(emailInput, findsOneWidget);
    expect(passwordInput, findsOneWidget);
    expect(telefonoInput, findsOneWidget);
    expect(submitButton, findsOneWidget);

    // **Caso 1: Tutti i campi validi**
    await tester.enterText(nomeInput, 'Nicol');
    await tester.enterText(cognomeInput, 'Rossi');
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, 'Password123!');
    await tester.enterText(telefonoInput, '1234567890');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // **Caso 2: Nome vuoto (classe invalida)**
    await tester.enterText(nomeInput, '');
    await tester.enterText(cognomeInput, 'Rossi');
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, 'Password123!');
    await tester.enterText(telefonoInput, '1234567890');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Inserisci il tuo nome'), findsOneWidget);

    // **Caso 3: Cognome vuoto (classe invalida)**
    await tester.enterText(nomeInput, 'Nicol');
    await tester.enterText(cognomeInput, '');
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, 'Password123!');
    await tester.enterText(telefonoInput, '1234567890');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Inserisci il tuo cognome'), findsOneWidget);

    // **Caso 4: Email vuota (classe invalida)**
    await tester.enterText(nomeInput, 'Nicol');
    await tester.enterText(cognomeInput, 'Rossi');
    await tester.enterText(emailInput, '');
    await tester.enterText(passwordInput, 'Password123!');
    await tester.enterText(telefonoInput, '1234567890');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Inserisci la tua email'), findsOneWidget);

    // **Caso 5: Email non valida (classe invalida)**
    await tester.enterText(nomeInput, 'Nicol');
    await tester.enterText(cognomeInput, 'Rossi');
    await tester.enterText(emailInput, 'invalid-email');
    await tester.enterText(passwordInput, 'Password123!');
    await tester.enterText(telefonoInput, '1234567890');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Inserisci un\'email valida'), findsOneWidget);

    // **Caso 6: Password troppo corta (classe invalida)**
    await tester.enterText(nomeInput, 'Nicol');
    await tester.enterText(cognomeInput, 'Rossi');
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, '123');
    await tester.enterText(telefonoInput, '1234567890');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('La password è troppo corta'), findsOneWidget);

    // **Caso 7: Password senza lettere e numeri (classe invalida)**
    await tester.enterText(nomeInput, 'Nicol');
    await tester.enterText(cognomeInput, 'Rossi');
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, 'password');
    await tester.enterText(telefonoInput, '1234567890');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(
        find.text('La password deve contenere almeno una lettera e un numero'),
        findsOneWidget);

    // **Caso 8: Numero di telefono vuoto (classe invalida)**
    await tester.enterText(nomeInput, 'Nicol');
    await tester.enterText(cognomeInput, 'Rossi');
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, 'Password123!');
    await tester.enterText(telefonoInput, '');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Inserisci il tuo numero di telefono'), findsOneWidget);

    // **Caso 9: Numero di telefono non valido (classe invalida)**
    await tester.enterText(nomeInput, 'Nicol');
    await tester.enterText(cognomeInput, 'Rossi');
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, 'Password123!');
    await tester.enterText(telefonoInput, '1234');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Il numero di telefono deve avere esattamente 10 cifre'),
        findsOneWidget);

    // **Caso 10: Numero di telefono valido**
    await tester.enterText(nomeInput, 'Nicol');
    await tester.enterText(cognomeInput, 'Rossi');
    await tester.enterText(emailInput, 'test@example.com');
    await tester.enterText(passwordInput, 'Password123!');
    await tester.enterText(telefonoInput, '1234567890');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
  });
}
