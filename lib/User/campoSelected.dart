import 'package:flutter/material.dart';
import 'package:booking_calendar/booking_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:match_day/Models/campo.dart';
import 'package:match_day/Models/field_booking.dart';

class SelectedCampo extends StatefulWidget {
  final Campo campoSelezionato; // Campo passed as a parameter

  const SelectedCampo({Key? key, required this.campoSelezionato})
      : super(key: key);

  @override
  State<SelectedCampo> createState() => _SelectedCampoState();
}

class _SelectedCampoState extends State<SelectedCampo> {
  late BookingService bookingService;
  bool isLoading = false;
  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _setupBookingService();
  }

  void _setupBookingService() {
    final currentUser = FirebaseAuth.instance.currentUser;
    bookingService = BookingService(
      serviceName: widget.campoSelezionato.nome,
      serviceDuration: 60,
      bookingStart: DateTime(now.year, now.month, now.day, 8, 0),
      bookingEnd: DateTime(now.year, now.month, now.day, 23, 0),
      userId: currentUser?.uid ?? '',
      userName: currentUser?.displayName ?? 'Anonimo',
    );
  }

  Stream<List<FieldBooking>> getBookingStream({
    required DateTime start,
    required DateTime end,
  }) {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('campoId',
            isEqualTo: widget.campoSelezionato.id) // Use the campo ID to filter
        .where('start', isGreaterThanOrEqualTo: start)
        .where('end', isLessThanOrEqualTo: end)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FieldBooking.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> uploadBooking({
    required BookingService newBooking,
  }) async {
    setState(() {
      isLoading = true;
    });
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      FieldBooking booking = FieldBooking(
        userId: currentUser?.uid ?? 'N/A',
        email: currentUser?.email ?? 'N/A',
        start: newBooking.bookingStart,
        end: newBooking.bookingEnd,
        phoneNumber: currentUser?.phoneNumber ?? 'N/A',
        fieldId: widget.campoSelezionato.id, // Store campo ID with the booking
      );

      await FirebaseFirestore.instance
          .collection('bookings')
          .add(booking.toMap());

      // Log the success message
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prenotazioni ${widget.campoSelezionato.nome}'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            BookingCalendar(
              bookingService: bookingService,
              convertStreamResultToDateTimeRanges:
                  convertFirestoreToDateTimeRanges,
              getBookingStream: getBookingStream,
              uploadBooking: uploadBooking,
              loadingWidget:
                  isLoading ? const CircularProgressIndicator() : null,
              errorWidget: const Icon(Icons.error),
              uploadingWidget: const Center(child: CircularProgressIndicator()),
              locale: 'it_IT',
            ),
            if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  List<DateTimeRange> convertFirestoreToDateTimeRanges(
      {required dynamic streamResult}) {
    List<DateTimeRange> allSlots = generateTimeSlots(DateTime.now());
    List<DateTimeRange> bookedSlots = [];
    for (var item in streamResult) {
      DateTime start = item.start;
      DateTime end = item.end;
      bookedSlots.add(DateTimeRange(start: start, end: end));
    }

    List<DateTimeRange> availableSlots = allSlots.where((slot) {
      return !bookedSlots.any((booked) {
        return (booked.start.isBefore(slot.end) &&
            booked.end.isAfter(slot.start));
      });
    }).toList();

    return availableSlots;
  }

  List<DateTimeRange> generateTimeSlots(DateTime day) {
    List<DateTimeRange> slots = [];
    DateTime startTime = DateTime(day.year, day.month, day.day, 8);
    DateTime endTime = DateTime(day.year, day.month, day.day, 23);

    while (startTime.isBefore(endTime)) {
      slots.add(DateTimeRange(
        start: startTime,
        end: startTime.add(const Duration(hours: 1)),
      ));
      startTime = startTime.add(const Duration(hours: 1));
    }

    return slots;
  }
}
