// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_dart/models/reservation.dart';
import 'package:application_dart/view_models/reservation.dart';
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:application_dart/services/connectivity.dart';

class ReservationDetailScreen extends StatefulWidget {
  const ReservationDetailScreen({super.key});

  @override
  _ReservationDetailScreenState createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  Reservation? _reservation;
  bool _isLoading = true;
  String _parkingName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchReservation();
  }

  Future<void> _fetchReservation() async {
    final reservationVM = Provider.of<ReservationViewModel>(context, listen: false);
    final parkingLotVM = Provider.of<ParkingLotViewModel>(context, listen: false);

    try {
      final reservation = reservationVM.reservation;
      setState(() {
        _reservation = reservation;
      });

      final parkingLot = parkingLotVM.getParkingLotById(reservation.parkingId);
      setState(() {
        _parkingName = parkingLot?.name ?? 'Unknown Parking';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error as needed
    }
  }

  void _showModifySheet() {
    if (_reservation == null) return;

    final originalReservation = _reservation!;
    final licensePlateController = TextEditingController(text: originalReservation.licensePlate);

    final DateTime originalDateTime = originalReservation.arrivalTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(originalDateTime);
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickNewTime() async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: selectedTime,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  selectedTime = picked;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Modify Reservation',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    // Arrival Time Picker
                    InkWell(
                      onTap: pickNewTime,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'New Arrival Time',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          selectedTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // License Plate Field
                    TextField(
                      controller: licensePlateController,
                      decoration: InputDecoration(
                        labelText: 'New License Plate',
                        prefixIcon: const Icon(Icons.directions_car),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'e.g. ABC123',
                      ),
                    ),

                    if (errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    ],

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final newLicensePlate = licensePlateController.text.trim();

                        if (newLicensePlate.isEmpty) {
                          setState(() {
                            errorMessage = 'Please provide a license plate.';
                          });
                          return;
                        }

                        final newArrivalDateTime = DateTime(
                          originalDateTime.year,
                          originalDateTime.month,
                          originalDateTime.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        final newReservation = Reservation(
                          arrivalTime: newArrivalDateTime,
                          departureTime: originalReservation.departureTime,
                          licensePlate: newLicensePlate,
                          parkingId: originalReservation.parkingId,
                          userId: originalReservation.userId,
                          status: originalReservation.status,
                        );

                        final reservationVM = Provider.of<ReservationViewModel>(context, listen: false);

                        try {
                          await reservationVM.updateReservation(newReservation);

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reservation updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Refresh data
                          _fetchReservation();
                        } catch (e) {
                          setState(() {
                            errorMessage = 'Failed to update reservation.';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);

    return StreamBuilder<bool>(
      stream: connectivityService.statusStream,
      initialData: connectivityService.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_reservation == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Reservation Detail')),
            body: const Center(child: Text('No reservation found.')),
          );
        }

        final reservation = _reservation!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reservation Detail'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Parking: $_parkingName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Arrival Time: ${reservation.arrivalTime}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text('Departure Time: ${reservation.departureTime}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(
                      'License Plate: ${reservation.licensePlate.isEmpty ? 'N/A' : reservation.licensePlate}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    if (!isConnected)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "You can't cancel or modify reservations without internet connection",
                          style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: !isConnected ? null : _showModifySheet,
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text('Modify', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
