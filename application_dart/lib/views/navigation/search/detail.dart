import 'package:application_dart/view_models/parking_lot.dart';
import 'package:application_dart/view_models/reservation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ParkingLotDetailScreen extends StatefulWidget {
  final String parkingLotId;

  const ParkingLotDetailScreen({Key? key, required this.parkingLotId})
      : super(key: key);

  @override
  _ParkingLotDetailScreenState createState() => _ParkingLotDetailScreenState();
}

class _ParkingLotDetailScreenState extends State<ParkingLotDetailScreen> {
  bool isReserved = false;
  final TextEditingController _licensePlateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkActiveReservation();
  }

  void _checkActiveReservation() {
    final reservationVM =
        Provider.of<ReservationViewModel>(context, listen: false);
    setState(() {
      isReserved = reservationVM.isReserved();
    });
  }

  Future<void> _handleReservation(ReservationViewModel reservationVM) async {
    try {
      setState(() {
        reservationVM.fetchingData = true;
      });

      if (!isReserved) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            TimeOfDay? dialogSelectedTime;
            return Theme(
              // Wrap dialog in Theme
              data: Theme.of(context).copyWith(
                // Add dialog theme
                dialogTheme: DialogTheme(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
                // Add text theme
                textTheme: const TextTheme(
                  titleLarge: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  bodyMedium: TextStyle(color: Colors.black),
                ),
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setDialogState) {
                  return AlertDialog(
                    title: const Text('Enter Reservation Details'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _licensePlateController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'License Plate',
                              labelStyle:
                                  const TextStyle(color: Colors.black54),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                              ),
                              prefixIcon: const Icon(Icons.car_repair),
                              prefixIconColor: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null &&
                                  pickedTime != dialogSelectedTime) {
                                setDialogState(() {
                                  dialogSelectedTime = pickedTime;
                                });
                              }
                            },
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              dialogSelectedTime == null
                                  ? 'Pick Reservation Time'
                                  : 'Selected Time: ${dialogSelectedTime!.format(context)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 20.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text(
                          'Cancel',
                          style:
                              TextStyle(fontSize: 16, color: Colors.redAccent),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (dialogSelectedTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please select a reservation time.'),
                              ),
                            );
                            return;
                          }

                          final timeToUse = dialogSelectedTime;
                          Navigator.of(dialogContext).pop();

                          if (timeToUse != null && mounted) {
                            final DateTime reservationDateTime = DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              timeToUse.hour,
                              timeToUse.minute,
                            );

                            await reservationVM.addReservation(
                              widget.parkingLotId,
                              reservationDateTime,
                              _licensePlateController.text,
                            );

                            if (mounted) {
                              setState(() {
                                isReserved = true;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      } else {
        await reservationVM.cancelReservation();
        if (mounted) {
          setState(() {
            isReserved = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update reservation: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          reservationVM.fetchingData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final parkingLotVM = Provider.of<ParkingLotViewModel>(context);
    final reservationVM = Provider.of<ReservationViewModel>(context);
    final parkingLot = parkingLotVM.getParkingLotById(widget.parkingLotId);

    if (parkingLot == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Parking Lot Details")),
        body: const Center(child: Text("Parking lot not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(parkingLot.name),
        backgroundColor: const Color(0xFFF4B324),
      ),
      body: reservationVM.fetchingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: parkingLot.image ?? '',
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Center(child: Icon(Icons.error)),
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            parkingLot.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                parkingLot.address ?? 'No Address Provided',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Chip(
                              label: Text(
                                parkingLot.capacity != null
                                    ? 'Capacity: ${parkingLot.capacity!.toInt()}'
                                    : 'Capacity: N/A',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: parkingLot.capacity != null &&
                                      parkingLot.capacity! > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                parkingLot.openingTime != null
                                    ? 'Opening Time: ${parkingLot.openingTime!.format(context)} AM'
                                    : 'No Opening Time Provided',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                parkingLot.closingTime != null
                                    ? 'Closing Time: ${parkingLot.closingTime!.format(context)} PM'
                                    : 'No Closing Time Provided',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        if (parkingLot.fullRate != null)
                          Text(
                            'Full Rate: ${parkingLot.fullRate!.toStringAsFixed(2)} COP',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        if (parkingLot.durationFullRate != null)
                          Text(
                            'Duration Full Rate: ${parkingLot.durationFullRate!.toInt()} Hours',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                        if (parkingLot.priceMinute != null)
                          Text(
                            'Price per Minute: ${parkingLot.priceMinute!.toStringAsFixed(2)} COP',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                        const SizedBox(height: 24.0),
                        Center(
                          child: Text(
                          isReserved
                            ? 'You have an active reservation'
                            : (parkingLot.capacity != null && parkingLot.capacity! > 0
                              ? 'Available for reservation'
                              : 'Parking lot is full'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isReserved
                              ? Colors.red
                              : (parkingLot.capacity != null && parkingLot.capacity! > 0
                                ? Colors.green
                                : Colors.red),
                          ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Center(
                          child: ElevatedButton(
                            onPressed: reservationVM.fetchingData || (parkingLot.capacity != null && parkingLot.capacity! <= 0)
                              ? null
                              : () => _handleReservation(reservationVM),
                            child: Text(
                                isReserved ? 'Cancel Reservation' : (parkingLot.capacity != null && parkingLot.capacity! > 0 ? 'Reserve' : 'Full')),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              backgroundColor:
                                    isReserved ? Colors.red : (parkingLot.capacity != null && parkingLot.capacity! > 0 ? Colors.blue : Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Leave a Review'),
                                    content: const Text('Feature coming soon!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.rate_review),
                            label: const Text('Review Parking Lot'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
