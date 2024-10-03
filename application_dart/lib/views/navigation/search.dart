import 'dart:async';
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/view_models/localization.dart';

class ParkingLotSearchNearbyWidget extends StatefulWidget {
  const ParkingLotSearchNearbyWidget({super.key});

  @override
  _ParkingLotSearchNearbyWidgetState createState() =>
      _ParkingLotSearchNearbyWidgetState();
}

class _ParkingLotSearchNearbyWidgetState
    extends State<ParkingLotSearchNearbyWidget> {
  double _searchRadius = 500; // Set default search radius to 500 meters
  List<ParkingLot> _availableParkingLots = []; // Store filtered parking lots
  bool _loading = false; // Show loading indicator while fetching data
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    locationVM = Provider.of<LocationViewModel>(context, listen: false);
    _fetchNearbyParkingLots(_searchRadius); // Fetch parking lots when the widget is rendered
  }

  late LocationViewModel locationVM;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Parking Lots'),
      ),
      body: Column(
        children: [
          // Button Group to Select Radius
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRadiusButton('500m', 500),
                _buildRadiusButton('1km', 1000),
                _buildRadiusButton('2km', 2000),
              ],
            ),
          ),
          // Display List of Parking Lots or Loading/Error Message
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator()) // Show loading indicator
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!)) // Show error message if any
                    : ListView.builder(
                        itemCount: _availableParkingLots.length,
                        itemBuilder: (context, index) {
                          final parkingLot = _availableParkingLots[index];
                          return _buildParkingLotTile(parkingLot, locationVM.currentPosition!);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Widget to build a pretty parking lot tile
  Widget _buildParkingLotTile(ParkingLot parkingLot, Position userPosition) {
    final distance = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      parkingLot.latitude ?? 0.0,
      parkingLot.longitude ?? 0.0,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0), // Rounded corners for image
          child: Image.network(
            parkingLot.image ?? '',
            width: 80,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.image,
              size: 80,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        title: Text(
          parkingLot.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(parkingLot.address ?? 'No Address Provided'),
            const SizedBox(height: 4.0), // Space between address and rating
            _buildStarRating(parkingLot.review ?? 0.0),
            const SizedBox(height: 4.0), // Space between rating and distance
            Text(
              'Distance: ${distance.toStringAsFixed(1)} meters',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${parkingLot.fullRate?.toStringAsFixed(0)} COP',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          // Implement navigation or additional actions here
        },
      ),
    );
  }

  // Build the star rating widget based on the review score
  Widget _buildStarRating(double rating) {
    const int totalStars = 5;
    final int filledStars = rating.floor(); // Number of filled stars
    final double partialStar = rating - filledStars; // Remainder for partial star

    List<Widget> stars = [];

    for (int i = 0; i < filledStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 20));
    }

    if (partialStar > 0) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 20));
    }

    while (stars.length < totalStars) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 20));
    }

    return Row(
      children: stars,
    );
  }

  // Build a button for selecting a radius value
  Widget _buildRadiusButton(String label, double radius) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _searchRadius = radius;
          _fetchNearbyParkingLots(_searchRadius);
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _searchRadius == radius ? Colors.blue : Colors.grey,
      ),
      child: Text(label),
    );
  }

  // Fetch nearby parking lots within a dynamic radius based on button selection
  Future<void> _fetchNearbyParkingLots(double radius) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final locationVM = Provider.of<LocationViewModel>(context, listen: false);

    // Ensure we have the user's current position
    if (locationVM.currentPosition == null) {
      setState(() {
        _errorMessage = 'User location is not available. Please try again.';
        _loading = false;
      });
      return;
    }

    try {
      final parkingLotVM = Provider.of<ParkingLotViewModel>(context, listen: false);
      List<ParkingLot> parkingLots = parkingLotVM.getParkingLotsInProximity(locationVM.currentPosition, radius);

      setState(() {
        _availableParkingLots = parkingLots;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load parking lots: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
