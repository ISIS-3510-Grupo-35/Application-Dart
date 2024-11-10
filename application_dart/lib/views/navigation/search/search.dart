import 'dart:async';
import 'dart:typed_data';
import 'package:application_dart/views/navigation/search/detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:application_dart/view_models/localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:application_dart/services/connectivity.dart';
import 'package:application_dart/services/image_cache_service.dart';

class ParkingLotList extends StatefulWidget {
  const ParkingLotList({super.key});

  @override
  _ParkingLotListState createState() => _ParkingLotListState();
}

class _ParkingLotListState extends State<ParkingLotList> {
  String _searchQuery = "";
  double _searchRadius = 500;
  bool _filterByProximity = false;
  int _minRatingFilter = 0;

  late LocationViewModel locationVM;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService = ConnectivityService();
  final ImageCacheService _imageCacheService = ImageCacheService();
  Uint8List? _cachedImage;
  bool _isConnected = true;

  final List<double> _radiusOptions = [500, 1000, 2000];
  final List<int> _ratingOptions = [1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    locationVM = Provider.of<LocationViewModel>(context, listen: false);
    _initializeConnectivity();
  }

  void _initializeConnectivity() async {
    // Listen to connectivity changes
    _connectivityService.statusStream.listen((status) {
      setState(() {
        _isConnected = status;
      });
    });

    // Load cached image for "No Internet" display
    await _imageCacheService.downloadAndCacheImage();
    _cachedImage = await _imageCacheService.getCachedImage();
  }

  @override
  Widget build(BuildContext context) {
    final parkingLotVM = Provider.of<ParkingLotViewModel>(context);
    final parkingLots = parkingLotVM.parkingLots;

    return FutureBuilder<List<ParkingLot>>(
      future: _applyFilters(parkingLots),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final filteredParkingLots = snapshot.data ?? [];

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              if (!_isConnected && _cachedImage != null) _buildNoInternetWidget(),
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
              // Proximity and Rating Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Proximity Filter Toggle
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
                        _filterByProximity ? "Proximity Filter: ON" : "Proximity Filter: OFF",
                        style: const TextStyle(fontSize: 10, color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _filterByProximity ? const Color(0xFFF4B324) : Colors.grey,
                      ),
                    ),
                    // Distance Dropdown for Proximity
                    if (_filterByProximity)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4B324),
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
                                    style: const TextStyle(color: Colors.black, fontSize: 10),
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
                    // Rating Filter Dropdown
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _minRatingFilter,
                            icon: const Icon(Icons.star, color: Colors.white),
                            isExpanded: true,
                            items: _ratingOptions.map((rating) {
                              return DropdownMenuItem<int>(
                                value: rating,
                                child: Text(
                                  '${rating} Stars & Up',
                                  style: const TextStyle(color: Colors.black, fontSize: 10),
                                ),
                              );
                            }).toList()
                              ..insert(0, DropdownMenuItem<int>(
                                  value: 0,
                                  child: const Text(
                                    'All Ratings',
                                    style: TextStyle(color: Colors.black, fontSize: 10),
                                  ))),
                            onChanged: (newRating) {
                              setState(() {
                                _minRatingFilter = newRating!;
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
      },
    );
  }

  Future<List<ParkingLot>> _applyFilters(List<ParkingLot> parkingLots) async {
    List<ParkingLot> filteredParkingLots = [];

    for (var parkingLot in parkingLots) {
      bool matchesSearchQuery = parkingLot.name.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesProximity = true;
      if (_filterByProximity && locationVM.currentPosition != null) {
        double distance = Geolocator.distanceBetween(
          locationVM.currentPosition!.latitude,
          locationVM.currentPosition!.longitude,
          parkingLot.latitude ?? 0.0,
          parkingLot.longitude ?? 0.0,
        );
        matchesProximity = distance <= _searchRadius;
      }

      bool matchesRating = _minRatingFilter == 0 || (parkingLot.review ?? 0.0) >= _minRatingFilter;

      if (matchesSearchQuery && matchesProximity && matchesRating) {
        filteredParkingLots.add(parkingLot);
      }
    }

    // Sort by review in descending order
    filteredParkingLots.sort((a, b) => (b.review ?? 0.0).compareTo(a.review ?? 0.0));

    return filteredParkingLots;
  }

  Widget _buildNoInternetWidget() {
    return Container(
      color: Colors.redAccent,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          if (_cachedImage != null)
            Image.memory(_cachedImage!, height: 50, fit: BoxFit.contain),
          const SizedBox(height: 10),
          const Text(
            "No Internet Connection",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingLotTile(ParkingLot parkingLot, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double? distance;
    if (locationVM.currentPosition != null) {
      distance = Geolocator.distanceBetween(
        locationVM.currentPosition!.latitude,
        locationVM.currentPosition!.longitude,
        parkingLot.latitude ?? 0.0,
        parkingLot.longitude ?? 0.0,
      );
    }

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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

    return Row(children: stars);
  }
}
