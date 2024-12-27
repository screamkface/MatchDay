import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:match_day/DAO/auth_dao.dart';
import 'package:match_day/Screens/login.dart';

class AuthDaoProvider with ChangeNotifier {
  final AuthDao authDao = AuthDao();

  void createAccount(
      String email,
      String password,
      String ruolo,
      String phone,
      String nome,
      String cognome,
      BuildContext context,
      GlobalKey<FormState> formKey) async {
    authDao.createAccount(
        email, password, phone, nome, cognome, ruolo, context, formKey);
  }

  Future<void> _logout(BuildContext context) async {
    await authDao.logoutSP(context);
  }

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    await authDao.login(email, password, context);
  }

  Future<UserCredential?> signInCred(
      String email, String password, BuildContext context) {
    return authDao.loginAndReturnUserCredential(email, password, context);
  }

  Future<void> sendPasswordResetEmail(
      BuildContext context, String email) async {
    await authDao.resetPassword(email, context);
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const Login(),
      ));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Logout Effettuato!"),
      ));
    } catch (e) {
      print('Errore durante il logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il logout: $e')),
      );
    }
  }
}
