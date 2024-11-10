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

  Future<void> _checkActiveReservation() async {
    final reservationVM =
        Provider.of<ReservationViewModel>(context, listen: false);

    await reservationVM.fetchReservations();
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
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            TimeOfDay? selectedTime;
            final formKey = GlobalKey<FormState>();

            return SingleChildScrollView(
              child: Dialog(
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  child: StatefulBuilder(
                    builder:
                        (BuildContext context, StateSetter setDialogState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 0.5),
                              ),
                            ),
                            child: const Text(
                              'Reserve Parking Spot',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _licensePlateController,
                                    autofocus: true,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'License Plate',
                                      hintText: 'Enter your license plate',
                                      prefixIcon:
                                          const Icon(Icons.directions_car),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.blue, width: 2),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your license plate number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Reservation Time',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        InkWell(
                                          onTap: () async {
                                            final TimeOfDay? pickedTime =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                    timePickerTheme:
                                                        TimePickerThemeData(
                                                      backgroundColor:
                                                          Colors.white,
                                                      hourMinuteShape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (pickedTime != null) {
                                              setDialogState(() {
                                                selectedTime = pickedTime;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  color: selectedTime == null
                                                      ? Colors.grey
                                                      : Colors.blue,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  selectedTime
                                                          ?.format(context) ??
                                                      'Select Time',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: selectedTime == null
                                                        ? Colors.grey
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Actions
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey, width: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    if (selectedTime == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please select a reservation time'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (formKey.currentState!.validate()) {
                                      Navigator.pop(dialogContext, {
                                        'time': selectedTime,
                                        'licensePlate':
                                            _licensePlateController.text,
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );

        if (result != null) {
          final timeToUse = result['time'] as TimeOfDay;
          final licensePlate = result['licensePlate'] as String;

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
            licensePlate,
          );

          if (mounted) {
            setState(() {
              isReserved = true;
            });
          }
        }
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
          SnackBar(
            content: Text('Failed to update reservation: $e'),
            backgroundColor: Colors.red,
          ),
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
                                : (parkingLot.capacity != null &&
                                        parkingLot.capacity! > 0
                                    ? 'Available for reservation'
                                    : 'Parking lot is full'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isReserved
                                  ? Colors.red
                                  : (parkingLot.capacity != null &&
                                          parkingLot.capacity! > 0
                                      ? Colors.green
                                      : Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Center(
                          child: ElevatedButton(
                            onPressed: reservationVM.fetchingData ||
                                    (parkingLot.capacity != null &&
                                        parkingLot.capacity! <= 0)
                                ? null
                                : () => _handleReservation(reservationVM),
                            child: Text(isReserved
                                ? 'Cancel Reservation'
                                : (parkingLot.capacity != null &&
                                        parkingLot.capacity! > 0
                                    ? 'Reserve'
                                    : 'Full')),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              backgroundColor: isReserved
                                  ? Colors.red
                                  : (parkingLot.capacity != null &&
                                          parkingLot.capacity! > 0
                                      ? Colors.blue
                                      : Colors.grey),
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
