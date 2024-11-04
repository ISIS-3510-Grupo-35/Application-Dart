import 'package:application_dart/view_models/parking_lot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ParkingLotDetailScreen extends StatefulWidget {
  final String parkingLotId;

  const ParkingLotDetailScreen({Key? key, required this.parkingLotId}) : super(key: key);

  @override
  _ParkingLotDetailScreenState createState() => _ParkingLotDetailScreenState();
}

class _ParkingLotDetailScreenState extends State<ParkingLotDetailScreen> {
  bool isReserved = false;

  void _toggleReservation(ParkingLotViewModel parkingLotVM) {
    setState(() {
      isReserved = !isReserved;
    });
    // Update the reservation status in the provider if necessary
    parkingLotVM.updateReservationStatus(widget.parkingLotId, isReserved);
  }

  @override
  Widget build(BuildContext context) {
    final parkingLotVM = Provider.of<ParkingLotViewModel>(context);
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
        backgroundColor: const Color(0xFFF4B324), // Updated color scheme
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section with gradient overlay
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address and capacity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          parkingLot.address ?? 'No Address Provided',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Chip(
                        label: Text(
                          parkingLot.capacity != null
                              ? 'Capacity: ${parkingLot.capacity!.toInt()}'
                              : 'Capacity: N/A',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: parkingLot.capacity != null && parkingLot.capacity! > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Opening and closing time
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

                  // Pricing information
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

                  // Reservation status
                  Center(
                    child: Text(
                      isReserved ? 'Reserved' : 'Available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isReserved ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Reservation button
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _toggleReservation(parkingLotVM),
                      child: Text(isReserved ? 'Cancel Reservation' : 'Reserve'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: isReserved ? Colors.red : Colors.blue,
                      ),
                    ),
                  ),

                  // Review button
                  const SizedBox(height: 24.0),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Add logic for navigating to the review page
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Leave a Review'),
                              content: const Text('Feature coming soon!'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
