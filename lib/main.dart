import 'package:flutter/material.dart';
import 'package:match_day/Screens/login.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Match Day',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(),
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
      home: const Login(),
    );
  }
}
