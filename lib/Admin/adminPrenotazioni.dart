import 'package:flutter/material.dart';

class AdminPrenotazioni extends StatefulWidget {
  const AdminPrenotazioni({super.key});

  @override
  State<AdminPrenotazioni> createState() => _AdminPrenotazioniState();
}

class _AdminPrenotazioniState extends State<AdminPrenotazioni> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prenotazioni"),
      ),
    );
  }
}
