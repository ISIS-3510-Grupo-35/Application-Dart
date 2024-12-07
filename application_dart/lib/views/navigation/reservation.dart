import 'package:application_dart/models/reservation.dart';
import 'package:application_dart/view_models/reservation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({Key? key}) : super(key: key);

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  bool isReserved = false;

  @override
  void initState() {
    super.initState();
    _checkActiveReservation();
  }

  Future<void> _checkActiveReservation() async {
    final reservationVM = Provider.of<ReservationViewModel>(context, listen: false);
    reservationVM.startListeningToAllReservations();
    await reservationVM.fetchReservations();
    setState(() {
      isReserved = reservationVM.isReserved();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservationVM = Provider.of<ReservationViewModel>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Show the active reservation section if there is a reservation
            if (isReserved) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Active Reservation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 5,
                  color: Colors.blue[100], // Highlight the active reservation
                  child: ListTile(
                    title: Text(
                      'Parking: ${reservationVM.reservation?.parkingId ?? 'Unknown'}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Status: ${reservationVM.reservation?.status ?? 'Unknown'}\n'
                      'License Plate: ${reservationVM.reservation?.licensePlate ?? 'Unknown'}\n'
                      'Arrival Time: ${reservationVM.reservation?.arrivalTime ?? 'Unknown'}',
                    ),
                  ),
                ),
              ),
            ],

            // Reservation list section for previous reservations
            if (reservationVM.reservations != null && reservationVM.reservations!.isNotEmpty)
              _buildReservationList(reservationVM.reservations!),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationList(List<Reservation> reservations) {
    return ListView.builder(
      shrinkWrap: true, // Important when using ListView in a Column
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final res = reservations[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 2,
          child: ListTile(
            title: Text('Parking: ${res.parkingId}'),
            subtitle: Text(
              'Status: ${res.status}\n'
              'License Plate: ${res.licensePlate}\n'
              'Arrival Time: ${res.arrivalTime}',
            ),
          ),
        );
      },
    );
  }
}
