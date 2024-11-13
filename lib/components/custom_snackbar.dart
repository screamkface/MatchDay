import 'package:flutter/material.dart';

class CustomSnackbar {
  CustomSnackbar(String s);

  static void show(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3), // Durata della Snackbar
      action: SnackBarAction(
        label: 'Chiudi',
        onPressed: () {
          // Qui puoi aggiungere l'azione da eseguire quando l'utente preme "Chiudi"
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
