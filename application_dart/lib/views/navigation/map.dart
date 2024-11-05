import 'dart:async';
import 'dart:typed_data';
import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:application_dart/view_models/localization.dart';
import 'package:application_dart/services/connectivity.dart';
import 'package:application_dart/services/image_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapComponent extends StatefulWidget {
  const MapComponent({Key? key}) : super(key: key);

  @override
  _MapComponentState createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  GoogleMapController? _mapController;
  final LatLng _defaultLocation = const LatLng(4.7110, -74.0721);
  bool _showDialog = false;
  ParkingLot? _nearestParkingLot;
  final Map<String, Timer> _declinedParkingLots = {};
  Timer? _leaveTimer;
  Timer? _connectivityTimer;

  late final ConnectivityService _connectivityService;
  late final ImageCacheService _imageCacheService;
  bool _isConnected = true;
  Uint8List? _noInternetImage;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    _imageCacheService = ImageCacheService();
    _initializeConnectivityListener();
    _downloadImageIfNeeded();
    _startPeriodicConnectivityCheck();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parkingLotVM = Provider.of<ParkingLotViewModel>(context, listen: false);
      parkingLotVM.fetchParkingLots();
    });
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    _connectivityTimer?.cancel();
    super.dispose();
  }

  // Continuously check connectivity every few seconds
  void _startPeriodicConnectivityCheck() {
    _connectivityTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkConnectivity();
    });
  }

  // Initial setup for connectivity listener and immediate check
  Future<void> _initializeConnectivityListener() async {
    _connectivityService.statusStream.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    });
    _checkConnectivity();
  }

  // Function to check connectivity on build or timer
  Future<void> _checkConnectivity() async {
    final isConnected = await _connectivityService.statusStream.first;
    setState(() {
      _isConnected = isConnected;
    });
  }

  // Download and cache the "No Internet" image
  Future<void> _downloadImageIfNeeded() async {
    await _imageCacheService.downloadAndCacheImage();
    final imageBytes = await _imageCacheService.getCachedImage();
    setState(() {
      _noInternetImage = imageBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    _checkConnectivity();

    return Scaffold(
      body: Consumer2<ParkingLotViewModel, LocationViewModel>(
        builder: (context, parkingLotVM, locationVM, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkProximity(parkingLotVM, locationVM);
          });

          return Stack(
            children: [
              if (_isConnected)
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: locationVM.currentPosition != null
                        ? LatLng(locationVM.currentPosition!.latitude, locationVM.currentPosition!.longitude)
                        : _defaultLocation,
                    zoom: 11.0,
                  ),
                  markers: parkingLotVM.markers.map((marker) {
                    return marker.copyWith(
                      onTapParam: () {
                        _onMarkerTapped(marker, parkingLotVM);
                      },
                    );
                  }).toSet(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                )
              else if (_noInternetImage != null)
                _buildNoInternetWidget(),
              if (parkingLotVM.fetchingData)
                const Center(child: CircularProgressIndicator()),
              Positioned(
                left: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: _centerOnUserLocation,
                  child: const Icon(Icons.my_location),
                  mini: true,
                ),
              ),
              if (_showDialog && _nearestParkingLot != null)
                _buildParkingDialog(_nearestParkingLot!), // Parking dialog
              if (_showDialog && parkingLotVM.isParked)
                _buildPayOrLeaveDialog(parkingLotVM), // Pay/Leave dialog
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoInternetWidget() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_noInternetImage != null)
                Image.memory(
                  _noInternetImage!,
                  width: 100,
                  height: 100,
                ),
              const SizedBox(height: 10),
              const Text(
                'No Internet Connection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkProximity(ParkingLotViewModel parkingLotVM, LocationViewModel locationVM) {
    if (locationVM.currentPosition != null) {
      parkingLotVM.checkProximityToMarkers(locationVM.currentPosition);

      if (parkingLotVM.nearestParkingLot != null &&
          !_declinedParkingLots.containsKey(parkingLotVM.nearestParkingLot!.name)) {
        setState(() {
          _nearestParkingLot = parkingLotVM.nearestParkingLot;
          _showDialog = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          parkingLotVM.nearestParkingLot = null;
        });
      } else if (parkingLotVM.isParked &&
          parkingLotVM.parkedLocation != null &&
          (_leaveTimer == null || !_leaveTimer!.isActive)) {
        setState(() {
          _showDialog = true;
        });
      }
    }
  }

  void _onMarkerTapped(Marker marker, ParkingLotViewModel parkingLotVM) {
    if (marker.markerId.value == 'parked_marker') {
      setState(() {
        _showDialog = true;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _centerOnUserLocation() {
    final locationVM = Provider.of<LocationViewModel>(context, listen: false);
    if (locationVM.currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(locationVM.currentPosition!.latitude, locationVM.currentPosition!.longitude),
        ),
      );
    }
  }

  Widget _buildParkingDialog(ParkingLot parkingLot) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You're near ${parkingLot.name}!", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Do you want to park here? Capacity: ${parkingLot.capacity}, Rate: ${parkingLot.fullRate}"),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showDialog = false;
                      _declinedParkingLots[parkingLot.name] = Timer(const Duration(minutes: 15), () {
                        setState(() {
                          _declinedParkingLots.remove(parkingLot.name);
                        });
                      });
                    });
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showDialog = false;
                    });
                    final locationVM = Provider.of<LocationViewModel>(context, listen: false);
                    final parkingLotVM = Provider.of<ParkingLotViewModel>(context, listen: false);
                    if (locationVM.currentPosition != null) {
                      parkingLotVM.setParkedLocation(
                        LatLng(locationVM.currentPosition!.latitude, locationVM.currentPosition!.longitude),
                      );
                      _leaveTimer = Timer(const Duration(minutes: 15), () {
                        setState(() {});
                      });
                    }
                  },
                  child: const Text("Yes"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayOrLeaveDialog(ParkingLotViewModel parkingLotVM) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("You are near your parked car!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Would you like to close the dialog, pay, or leave?"),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showDialog = false;
                    });
                    _leaveTimer?.cancel();
                    _leaveTimer = Timer(const Duration(minutes: 15), () {
                      setState(() {});
                    });
                  },
                  child: const Text("Close"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showDialog = false;
                    });
                    print("User wants to pay for the parking.");
                  },
                  child: const Text("Pay"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      parkingLotVM.leaveParking();
                      _showDialog = false;
                    });
                    print("User left the parking.");
                  },
                  child: const Text("Leave"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
