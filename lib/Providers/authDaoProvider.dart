import 'package:flutter/material.dart';
import 'package:match_day/DAO/auth_dao.dart';

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

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    await authDao.login(email, password, context);
  }

  Future<void> sendPasswordResetEmail(
      BuildContext context, String email) async {
    await authDao.resetPassword(email, context);
  }
}
