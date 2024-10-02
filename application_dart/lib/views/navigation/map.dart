import 'dart:async';
import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/view_models/parking_lot.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:application_dart/view_models/localization.dart';

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
  final Map<String, Timer> _declinedParkingLots = {}; // Track declined parking lots
  Timer? _leaveTimer; // Timer to track 15 minutes after parking

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch parking lots when the component initializes
      final parkingLotVM = Provider.of<ParkingLotViewModel>(context, listen: false);
      parkingLotVM.fetchParkingLots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<ParkingLotViewModel, LocationViewModel>(
        builder: (context, parkingLotVM, locationVM, child) {
          // Schedule the checkProximity call to occur after the build is completed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkProximity(parkingLotVM, locationVM);
          });

          return Stack(
            children: [
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
              ),
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

  void _checkProximity(ParkingLotViewModel parkingLotVM, LocationViewModel locationVM) {
    if (locationVM.currentPosition != null) {
      parkingLotVM.checkProximityToMarkers(locationVM.currentPosition);

      // Show "Do you want to park?" dialog if near a parking lot
      if (parkingLotVM.nearestParkingLot != null &&
          !_declinedParkingLots.containsKey(parkingLotVM.nearestParkingLot!.name)) {
        setState(() {
          _nearestParkingLot = parkingLotVM.nearestParkingLot;
          _showDialog = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          parkingLotVM.nearestParkingLot = null; // Reset after showing dialog to prevent duplicate dialogs
        });
      } 
      // Show "Pay/Leave" dialog if near parked location and 15 minutes have passed
      else if (parkingLotVM.isParked && parkingLotVM.parkedLocation != null && (_leaveTimer == null || !_leaveTimer!.isActive)) {
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

  // Dialog to ask if user wants to park near a parking lot
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
            Text("You're near ${parkingLot.name}!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      // Reset timer to prevent the dialog from showing up again for 15 minutes if user declines
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
                    // Save the parked location
                    final locationVM = Provider.of<LocationViewModel>(context, listen: false);
                    final parkingLotVM = Provider.of<ParkingLotViewModel>(context, listen: false);
                    if (locationVM.currentPosition != null) {
                      parkingLotVM.setParkedLocation(
                        LatLng(locationVM.currentPosition!.latitude, locationVM.currentPosition!.longitude),
                      );
                      // Start the 15-minute timer after parking
                      _leaveTimer = Timer(const Duration(minutes: 15), () {
                        setState(() {
                          // Timer completed, allow the "Leave" dialog to appear
                        });
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

  // Build the "Pay/Leave" dialog with the new "Close" button
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
                    // Restart the 15-minute timer when the dialog is closed
                    _leaveTimer?.cancel();
                    _leaveTimer = Timer(const Duration(minutes: 15), () {
                      setState(() {
                        // Timer completed, allow the "Leave" dialog to appear
                      });
                    });
                    print("User closed the dialog and reset the timer.");
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
                     // Reset the parked state
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
