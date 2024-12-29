import 'package:flutter/material.dart';
import 'package:match_day/Providers/authDaoProvider.dart';
import 'package:match_day/Screens/login.dart';
import 'package:match_day/components/custom_snackbar.dart';
import 'package:provider/provider.dart';

class Usersettings extends StatelessWidget {
  const Usersettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Provider.of<AuthDaoProvider>(context, listen: false)
                .authDao
                .logoutSP(context);
            CustomSnackbar.show(context, "Logout Effettuato");
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Login(),
            ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
