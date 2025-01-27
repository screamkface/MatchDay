import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomTableCalendar extends StatefulWidget {
  final Function(DateTime) onDaySelected;

  const CustomTableCalendar({super.key, required this.onDaySelected});

  @override
  _CustomTableCalendarState createState() => _CustomTableCalendarState();
}

class _CustomTableCalendarState extends State<CustomTableCalendar> {
  DateTime _selectedDay = DateTime.now();

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });

    widget.onDaySelected(
        selectedDay); // Chiama la callback per aggiornare il giorno selezionato
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      key: Key('calendar_button'),
      calendarFormat: CalendarFormat.twoWeeks,
      calendarStyle: const CalendarStyle(isTodayHighlighted: true),
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 1, 1),
      focusedDay: _selectedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      headerStyle: const HeaderStyle(
        formatButtonVisible:
            false, // Nasconde il pulsante del formato del calendario
        titleCentered: true, // Centra il titolo del mese
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Colors.black, // Imposta il colore della freccia sinistra
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Colors.black, // Imposta il colore della freccia destra
        ),
      ),
    );
  }
}
