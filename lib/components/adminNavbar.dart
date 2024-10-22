import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:match_day/Admin/admin_home.dart';

class AdminNavbar extends StatelessWidget {
  const AdminNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      color: Colors.white,
      child: GNav(
        haptic: true,
        tabBorderRadius: 12,
        gap: 6,
        color: Colors.grey[600]!,
        activeColor: const Color.fromARGB(255, 34, 40, 49),
        iconSize: 20,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        tabBackgroundColor: Colors.grey[200]!,
        // Aggiunta del bordo grigio al passaggio del mouse (hover) o tab attivo
        tabActiveBorder: Border.all(
            color: const Color.fromARGB(255, 34, 40, 49), width: 1.5),
        tabs: [
          GButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminHomePage(),
                  ));
            },
            icon: LineIcons.home,
            text: 'Home',
          ),
          GButton(
            onPressed: () {},
            icon: LineIcons.calendar,
            text: 'Orari',
          ),
          GButton(
            onPressed: () {},
            icon: LineIcons.bookmark,
            text: 'Prenotazioni',
          ),
          GButton(
            onPressed: () {},
            icon: LineIcons.user,
            text: 'Profile',
          ),
        ],
      ),
    );
  }
}
