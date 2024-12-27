// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:match_day/Screens/login.dart';
import 'package:match_day/User/selezionaCampo.dart';
import 'package:match_day/components/custom_snackbar.dart';
import 'package:match_day/Admin/admin_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthDao {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Creazione di un nuovo account
  void createAccount(
    String email,
    String password,
    String phone,
    String nome,
    String cognome,
    String ruolo,
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    try {
      // Creare un nuovo utente con email e password
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

      // Reset del form e reindirizzamento al login
      debugPrint("Utente creato e salvato in Firestore.");
      formKey.currentState!.reset();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          ));
    } on FirebaseAuthException catch (e) {
      // Gestire eccezioni specifiche di FirebaseAuth
      if (e.code == 'weak-password') {
        CustomSnackbar.show(
            context, "La password è troppo debole. Scegline una più sicura.");
      } else if (e.code == 'email-already-in-use') {
        CustomSnackbar.show(context, "L'email inserita è già in uso.");
      } else {
        debugPrint("Errore durante la creazione dell'account: ${e.message}");
        CustomSnackbar.show(
            context, "Errore durante la creazione dell'account. Riprova.");
      }
    } catch (error) {
      // Gestire altri errori generici
      debugPrint("Errore generico durante la creazione dell'account: $error");
      CustomSnackbar.show(
          context, "Errore sconosciuto durante la registrazione.");
    }
  }

  Future<void> logoutSP(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Rimuove l'ID utente
    await prefs.setBool('isLoggedIn', false); // Imposta isLoggedIn su false

    // Naviga alla schermata di login
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Login
  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      // Effettua il login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Recupera il ruolo dell'utente dal Firestore
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
          MaterialPageRoute(builder: (context) => const CampoSelectionPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        CustomSnackbar.show(context, "Nessun utente trovato con questa email.");
      } else if (e.code == 'wrong-password') {
        CustomSnackbar.show(context, "Password errata. Riprova.");
      } else {
        debugPrint("Errore durante il login: ${e.message}");
        CustomSnackbar.show(context, "Errore durante il login.");
      }
    } catch (error) {
      debugPrint("Errore generico durante il login: $error");
      CustomSnackbar.show(context, "Errore durante il login.");
    }
  }

  Future<UserCredential?> loginAndReturnUserCredential(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      // Effettua il login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Recupera il ruolo dell'utente dal Firestore
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
          MaterialPageRoute(builder: (context) => const CampoSelectionPage()),
        );
      }

      // Restituisce l'oggetto UserCredential
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        CustomSnackbar.show(context, "Nessun utente trovato con questa email.");
      } else if (e.code == 'wrong-password') {
        CustomSnackbar.show(context, "Password errata. Riprova.");
      } else {
        debugPrint("Errore durante il login: ${e.message}");
        CustomSnackbar.show(context, "Errore durante il login.");
      }
    } catch (error) {
      debugPrint("Errore generico durante il login: $error");
      CustomSnackbar.show(context, "Errore durante il login.");
    }

    // Se il login fallisce, restituisce null
    return null;
  }

  Future<void> resetPassword(
    String email,
    BuildContext context,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      CustomSnackbar.show(context, "Email di reset inviata a $email.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        CustomSnackbar.show(context, "Nessun utente trovato con questa email.");
      } else {
        debugPrint("Errore durante il reset della password: ${e.message}");
        CustomSnackbar.show(
            context, "Errore durante il reset della password. Riprova.");
      }
    } catch (error) {
      debugPrint("Errore generico durante il reset della password: $error");
      CustomSnackbar.show(
          context, "Errore sconosciuto durante il reset della password.");
    }
  }
}
