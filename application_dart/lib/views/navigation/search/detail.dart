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
    // Example: Update the reservation status in the provider if necessary
    parkingLotVM.updateReservationStatus(widget.parkingLotId, isReserved);
  }

  @override
  Widget build(BuildContext context) {
    final parkingLotVM = Provider.of<ParkingLotViewModel>(context);
    final parkingLot = parkingLotVM.getParkingLotById(widget.parkingLotId as String);

    if (parkingLot == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Parking Lot Details")),
        body: const Center(child: Text("Parking lot not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(parkingLot.name),
      ),
      body: Column(
        children: [
          CachedNetworkImage(
            imageUrl: parkingLot.image ?? '',
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              parkingLot.address ?? 'No Address Provided',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              isReserved ? 'Reserved' : 'Available',
              style: TextStyle(
                fontSize: 18,
                color: isReserved ? Colors.green : Colors.red,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _toggleReservation(parkingLotVM),
            child: Text(isReserved ? 'Cancel Reservation' : 'Reserve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isReserved ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
