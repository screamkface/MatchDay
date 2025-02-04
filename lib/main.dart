// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:match_day/Providers/authDaoProvider.dart';
import 'package:match_day/Providers/prenotazioniProvider.dart';
import 'package:match_day/Providers/slotProvider.dart';
import 'package:match_day/Screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Assicurati di avere il file firebase_options.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  // Assicurati che Flutter sia pronto per l'esecuzione di codice asincrono
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Inizializza Firebase con le opzioni specifiche per la piattaforma
  );
  initializeDateFormatting('it_IT', null).then((_) {
    runApp(const MyApp());
  }); // Avvia l'app Flutter dopo l'inizializzazione di Firebase
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthDaoProvider()),
        ChangeNotifierProvider(create: (_) => FirebaseSlotProvider()),
        ChangeNotifierProvider(create: (_) => PrenotazioneProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Match Day',
        theme: ThemeData(
          textTheme: TextTheme(
            headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(fontSize: 16),
            titleSmall: TextStyle(fontSize: 14),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 34, 40, 49),
            primary: const Color.fromARGB(255, 34, 40, 49),
            secondary: Colors.white,
            onPrimary: Colors.white, // Colore del testo su sfondi primari
            onSecondary: const Color.fromARGB(
                255, 34, 40, 49), // Colore del testo su sfondi secondari
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 34, 40, 49),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 34, 40, 49),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 34, 40, 49),
              side: const BorderSide(color: Color.fromARGB(255, 34, 40, 49)),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromARGB(255, 34, 40, 49),
            foregroundColor: Colors.white,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          useMaterial3: true,
        ),
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const Login(),
      ),
    );
  }
}

void showMySnackBar(String message) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message)),
  );
}
