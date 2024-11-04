import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:application_dart/view_models/localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:application_dart/views/navigation/search/detail.dart'; // Adjust the path as necessary

class ParkingLotList extends StatefulWidget {
  const ParkingLotList({super.key});

  @override
  _ParkingLotListState createState() => _ParkingLotListState();
}

class _ParkingLotListState extends State<ParkingLotList> {
  String _searchQuery = "";
  double _searchRadius = 500;
  bool _filterByProximity = false;

  late LocationViewModel locationVM;

  final List<double> _radiusOptions = [
    500,
    1000,
    2000
  ]; // Available distance options

  @override
  void initState() {
    super.initState();
    locationVM = Provider.of<LocationViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final parkingLotVM = Provider.of<ParkingLotViewModel>(context);
    final parkingLots = parkingLotVM.parkingLots;

    // Filter parking lots based on search query and proximity
    final filteredParkingLots = parkingLots.where((parkingLot) {
      // Filter by search query
      final matchesSearchQuery =
          parkingLot.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by proximity if enabled
      if (_filterByProximity && locationVM.currentPosition != null) {
        final distance = Geolocator.distanceBetween(
          locationVM.currentPosition!.latitude,
          locationVM.currentPosition!.longitude,
          parkingLot.latitude ?? 0.0,
          parkingLot.longitude ?? 0.0,
        );
        return matchesSearchQuery && distance <= _searchRadius;
      }

      return matchesSearchQuery;
    }).toList();

    return Container(
      color: Colors.white, // White background for the entire component
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search Parking Lots",
                hintText: "Enter parking lot name",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          // Filter by Proximity Button with Distance Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _filterByProximity = !_filterByProximity;
                    });
                  },
                    icon: Icon(
                    _filterByProximity ? Icons.location_on : Icons.location_off,
                    color: Colors.black,
                    ),
                    label: Text(
                    _filterByProximity
                      ? "Proximity Filter: ON"
                      : "Proximity Filter: OFF",
                    style: const TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _filterByProximity ? const Color(0xFFF4B324) : Colors.grey,
                  ),
                ),
                // Responsive Dropdown Button for Radius Selection
                if (_filterByProximity) Flexible(
                  child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: _filterByProximity ? const Color(0xFFF4B324) : Colors.grey,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                    value: _searchRadius,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    isExpanded: true,
                    items: _radiusOptions.map((radius) {
                      return DropdownMenuItem<double>(
                      value: radius,
                      child: Text(
                        'Distance: ${radius.toStringAsFixed(0)}m',
                        style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        ),
                      ),
                      );
                    }).toList(),
                    onChanged: (newRadius) {
                      setState(() {
                      _searchRadius = newRadius!;
                      });
                    },
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  ),
                ),
              ],
            ),
          ),

          // Parking Lot List
          Expanded(
            child: filteredParkingLots.isEmpty
                ? const Center(child: Text("No parking lots found"))
                : ListView.builder(
                    itemCount: filteredParkingLots.length,
                    itemBuilder: (context, index) {
                      final parkingLot = filteredParkingLots[index];
                      return _buildParkingLotTile(parkingLot, context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingLotTile(ParkingLot parkingLot, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate distance to user's location if available
    double? distance;
    if (locationVM.currentPosition != null) {
      distance = Geolocator.distanceBetween(
        locationVM.currentPosition!.latitude,
        locationVM.currentPosition!.longitude,
        parkingLot.latitude ?? 0.0,
        parkingLot.longitude ?? 0.0,
      );
    }
  // Add GestureDetector to handle tap and navigate to detail screen
  return GestureDetector(
    onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) => ParkingLotDetailScreen(parkingLotId: parkingLot.address ?? ''),
      ),
    );
    },
    child: Card(
    margin: EdgeInsets.symmetric(
      vertical: screenHeight * 0.01,
      horizontal: screenWidth * 0.05,
    ),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Stack(
      children: [
        // Background Image
        Positioned.fill(
        child: CachedNetworkImage(
          imageUrl: parkingLot.image ?? '',
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.3),
          colorBlendMode: BlendMode.darken,
          placeholder: (context, url) => Container(
          color: Colors.grey.shade400,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade400,
          alignment: Alignment.center,
          child: Icon(
            Icons.image,
            size: screenWidth * 0.2,
            color: Colors.grey.shade700,
          ),
          ),
        ),
        ),
        // Content Overlay
        Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            parkingLot.name,
            style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            parkingLot.address ?? 'No Address Provided',
            style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.white70,
            ),
          ),
          if (distance != null) SizedBox(height: screenHeight * 0.005),
          if (distance != null)
            Text(
            'Distance: ${distance.toStringAsFixed(1)} meters',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.white70,
            ),
            ),
          SizedBox(height: screenHeight * 0.005),
          _buildStarRating(parkingLot.review ?? 0.0),
          SizedBox(height: screenHeight * 0.005),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Text(
              '${parkingLot.fullRate?.toStringAsFixed(0)} COP',
              style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              ),
            ),
            Text(
              (parkingLot.capacity?.toInt() ?? 0) > 0
                ? 'Available'
                : 'Full',
              style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: (parkingLot.capacity?.toInt() ?? 0) > 0
                ? Colors.greenAccent
                : Colors.redAccent,
              ),
            ),
            ],
          ),
          ],
        ),
        ),
      ],
      ),
    ),
    ),
  );
  }

  // Helper method to build star rating
  Widget _buildStarRating(double rating) {
    const int totalStars = 5;
    final int filledStars = rating.floor();
    final double partialStar = rating - filledStars;

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
}
