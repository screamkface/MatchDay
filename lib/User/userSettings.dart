import 'package:flutter/material.dart';
import 'package:match_day/Providers/authDaoProvider.dart';
import 'package:provider/provider.dart';

class Usersettings extends StatelessWidget {
  const Usersettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Impostazioni"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                Provider.of<AuthDaoProvider>(context, listen: false)
                    .logout(context);
              },
              child: const Text("Logout"))
        ],
      ),
    );
  }
}
