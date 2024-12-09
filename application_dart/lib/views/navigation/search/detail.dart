// ignore_for_file: library_private_types_in_public_api

import 'package:application_dart/services/connectivity.dart';
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:application_dart/view_models/reservation.dart';
import 'package:application_dart/view_models/review.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class ParkingLotDetailScreen extends StatefulWidget {
  final String parkingLotId;

  // ignore: use_super_parameters
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
    _loadReviews();
  }

  Future<void> _checkActiveReservation() async {
    final reservationVM = Provider.of<ReservationViewModel>(context, listen: false);
    await reservationVM.fetchReservations();
    if (mounted) {
      setState(() {
        isReserved = reservationVM.isReserved();
      });
    }
  }

  Future<void> _loadReviews() async {
    final reviewVM = Provider.of<ReviewViewModel>(context, listen: false);
    await reviewVM.loadReviews(widget.parkingLotId);
  }

  Future<void> _handleReservation(ReservationViewModel reservationVM, bool isConnected) async {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
                insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                    builder: (BuildContext context, StateSetter setDialogState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey, width: 0.5),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                                      prefixIcon: const Icon(Icons.directions_car),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Colors.blue, width: 2),
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
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                            final TimeOfDay? pickedTime = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    timePickerTheme: TimePickerThemeData(
                                                      backgroundColor: Colors.white,
                                                      hourMinuteShape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
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
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  color: selectedTime == null ? Colors.grey : Colors.blue,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  selectedTime?.format(context) ?? 'Select Time',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: selectedTime == null ? Colors.grey : Colors.black87,
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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please select a reservation time'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (formKey.currentState!.validate()) {
                                      Navigator.pop(dialogContext, {
                                        'time': selectedTime,
                                        'licensePlate': _licensePlateController.text,
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  void _showAddReviewDialog(ReviewViewModel reviewVM) {
    final reviewController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    double rating = 0.0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add a Review',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Star Rating Widget
                  const Text(
                    'Your Rating',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (value) {
                        rating = value;
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Comments Box
                  const Text(
                    'Your Review',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Write your comments here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your review text';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate() && rating > 0) {
                            // Replace YOUR_USER_ID with actual logic
                            String userId = 'YOUR_USER_ID';
                            await reviewVM.addReview(
                              widget.parkingLotId,
                              rating.toString(),
                              reviewController.text.trim(),
                              userId,
                            );
                            Navigator.pop(dialogContext);
                          } else if (rating == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a star rating.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final parkingLotVM = Provider.of<ParkingLotViewModel>(context);
    final reservationVM = Provider.of<ReservationViewModel>(context);
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    final reviewVM = Provider.of<ReviewViewModel>(context); 
    final parkingLot = parkingLotVM.getParkingLotById(widget.parkingLotId);

    if (parkingLot == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Parking Lot Details")),
        body: const Center(child: Text("Parking lot not found")),
      );
    }

    return StreamBuilder<bool>(
      stream: connectivityService.statusStream,
      initialData: connectivityService.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        return Scaffold(
          appBar: AppBar(
            title: Text(parkingLot.name),
            backgroundColor: const Color(0xFFF4B324),
          ),
          body: reservationVM.fetchingData
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: parkingLot.image ?? '',
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              height: 250,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
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
                        const SizedBox(height: 16.0),
                        Text(
                          parkingLot.address ?? 'No Address Provided',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10.0),
                        Center(
                          child: Chip(
                            label: Text(
                              isConnected
                                  ? (parkingLot.capacity != null
                                      ? 'Capacity: ${parkingLot.capacity!.toInt()}'
                                      : 'Capacity: N/A')
                                  : 'Capacity: No live data',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: isConnected
                                ? (parkingLot.capacity != null && parkingLot.capacity! > 0 ? Colors.green : Colors.red)
                                : Colors.grey,
                          ),
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
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        if (parkingLot.durationFullRate != null)
                          Text(
                            'Duration Full Rate: ${parkingLot.durationFullRate!.toInt()} Hours',
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        if (parkingLot.priceMinute != null)
                          Text(
                            'Price per Minute: ${parkingLot.priceMinute!.toStringAsFixed(2)} COP',
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        const SizedBox(height: 24.0),
                        if (isConnected)
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
                        if (isConnected) const SizedBox(height: 16.0),
                        if (isConnected)
                          Center(
                            child: ElevatedButton(
                              onPressed: reservationVM.fetchingData ||
                                      !isConnected ||
                                      (parkingLot.capacity != null && parkingLot.capacity! <= 0)
                                  ? null
                                  : () => _handleReservation(reservationVM, isConnected),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                backgroundColor: isReserved
                                    ? Colors.red
                                    : (parkingLot.capacity != null && parkingLot.capacity! > 0
                                        ? Colors.blue
                                        : Colors.grey),
                              ),
                              child: Text(isReserved
                                  ? 'Cancel Reservation'
                                  : (parkingLot.capacity != null && parkingLot.capacity! > 0
                                      ? 'Reserve'
                                      : 'Full')),
                            ),
                          ),
                        if (isConnected) const SizedBox(height: 24.0),

                        // Display Existing Reviews
                        const Text(
                          'Reviews',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        if (reviewVM.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (reviewVM.reviews.isEmpty)
                          const Center(child: Text('No reviews yet.'))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviewVM.reviews.length,
                            itemBuilder: (context, index) {
                              final rev = reviewVM.reviews[index];
                              return ListTile(
                                title: Text('Rating: ${rev.rate}'),
                                subtitle: Text(rev.review),
                              );
                            },
                          ),

                        const SizedBox(height: 16.0),
                        if (isConnected)
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: !isConnected
                                  ? null
                                  : () {
                                      _showAddReviewDialog(reviewVM);
                                    },
                              icon: const Icon(Icons.rate_review),
                              label: const Text('Review Parking Lot'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                backgroundColor: Colors.orangeAccent,
                              ),
                            ),
                          ),
                        if (!isConnected)
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Center(
                              child: Text(
                                'No internet connection. Review and reservation features are disabled.',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
