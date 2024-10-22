import 'package:flutter/material.dart';
import 'package:match_day/components/adminNavbar.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Center(child: Text("Home")),
        ),
        bottomNavigationBar: const AdminNavbar(),
        body: const Column(),
      ),
    );
  }
}
