// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:match_day/Screens/login.dart';
import 'package:match_day/User/user_home.dart';
import 'package:match_day/components/custom_snackbar.dart';
import 'package:match_day/Admin/admin_home.dart';

class AuthDao {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createAccount({
    required String email,
    required String password,
    required String phone,
    required String nome,
    required String cognome,
    required String ruolo,
    required BuildContext context,
    required GlobalKey<FormState> formKey,
  }) async {
    try {
      // Creare un nuovo utente
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Aggiungere i dettagli dell'utente al Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'phone': phone,
        'Ruolo': ruolo,
        'nome': nome,
        'cognome': cognome,
        'user-id': userCredential.user!.uid,
      });

      // Se l'aggiunta al Firestore è completata con successo
      debugPrint("Utente creato in FIRESTORE");
      formKey.currentState!.reset();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          ));
    } on FirebaseAuthException catch (e) {
      // Gestire eventuali eccezioni durante la creazione dell'account
      if (e.code == 'weak-password') {
        CustomSnackbar.show(
            context, "La password è debole. Provane una più forte.");
      } else if (e.code == 'email-already-in-use') {
        CustomSnackbar.show(context, "L'email è già in uso.");
      } else {
        debugPrint("Errore durante la creazione dell'account: ${e.message}");
        CustomSnackbar.show(
            context, "Errore durante la creazione dell'account.");
      }
    } catch (error) {
      // Gestire altri errori generali
      debugPrint("Errore generico: $error");
      CustomSnackbar.show(context, "Errore durante la creazione dell'account.");
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Effettua il login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Recupera il ruolo dell'utente da Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      String ruolo = userDoc['Ruolo'] ?? '';

      // Naviga alla homepage appropriata in base al ruolo
      if (ruolo == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Gestire eventuali eccezioni durante il login
      if (e.code == 'user-not-found') {
        CustomSnackbar.show(context, "Nessun utente trovato con questa email.");
      } else if (e.code == 'wrong-password') {
        CustomSnackbar.show(context, "Password errata. Riprova.");
      } else {
        debugPrint("Errore durante il login: ${e.message}");
        CustomSnackbar.show(context, "Errore durante il login.");
      }
    } catch (error) {
      // Gestire altri errori generali
      debugPrint("Errore generico: $error");
      CustomSnackbar.show(context, "Errore durante il login.");
    }
  }
}
