import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class AdminNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const AdminNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

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
        tabActiveBorder: Border.all(
            color: const Color.fromARGB(255, 34, 40, 49), width: 1.5),
        selectedIndex: selectedIndex, // L'indice selezionato
        onTabChange:
            onTabChange, // Funzione di callback per aggiornare la pagina
        tabs: const [
          GButton(
            icon: LineIcons.home,
            text: 'Home',
          ),
          GButton(
            icon: LineIcons.calendar,
            text: 'Orari',
          ),
          GButton(
            icon: LineIcons.bookmark,
            text: 'Prenotazioni',
          ),
          GButton(
            icon: LineIcons.user,
            text: 'Profilo',
          ),
        ],
      ),
    );
  }
}
