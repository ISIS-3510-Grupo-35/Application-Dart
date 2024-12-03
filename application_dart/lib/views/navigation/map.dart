import 'dart:async';
import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/view_models/parked.dart';
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
  bool _loading = true; // Loading state
  ParkingLot? _nearestParkingLot;
  final Map<String, Timer> _declinedParkingLots = {}; // Track declined parking lots
  Timer? _leaveTimer; // Timer to track 15 minutes after parking

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final parkingLotVM = Provider.of<ParkingLotViewModel>(context, listen: false);
      final parkedVM = Provider.of<ParkedViewModel>(context, listen: false);

      // Indicate loading started
      setState(() {
        _loading = true;
      });

      try {
        await parkingLotVM.fetchParkingLots();
        await parkedVM.fetchParkedCar();

        if (parkedVM.parked != null) {
          final parkingLot = parkingLotVM.parkingLots.firstWhere(
            (lot) => lot.address == parkedVM.parked!.parking,
            orElse: () => ParkingLot(name: 'Unknown'),
          );

          if (parkingLot.name != 'Unknown') {
            parkingLotVM.setParkedLocation(parkingLot, state: true);
          }
        }
      } catch (error) {
        print('Error loading parking lots or parked car data: $error');
      } finally {
        // Indicate loading is done
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<ParkingLotViewModel, LocationViewModel>(
        builder: (context, parkingLotVM, locationVM, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_loading) {
              _checkProximity(parkingLotVM, locationVM);
            }
          });

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: locationVM.currentPosition != null
                      ? LatLng(locationVM.currentPosition!.latitude,
                          locationVM.currentPosition!.longitude)
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
              if (parkingLotVM.fetchingData || _loading)
                const Center(child: CircularProgressIndicator()), // Show loading indicator
              Positioned(
                left: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: _centerOnUserLocation,
                  mini: true,
                  child: const Icon(Icons.my_location),
                ),
              ),
              if (_showDialog && _nearestParkingLot != null)
                _buildParkingBanner(_nearestParkingLot!), // Parking banner
              if (_showDialog && parkingLotVM.isParked)
                _buildPayOrLeaveBanner(parkingLotVM), // Pay/Leave banner
            ],
          );
        },
      ),
    );
  }

  void _checkProximity(
      ParkingLotViewModel parkingLotVM, LocationViewModel locationVM) {
    if (locationVM.currentPosition != null) {
      parkingLotVM.checkProximityToMarkers(locationVM.currentPosition);

      if (!_loading && parkingLotVM.nearestParkingLot != null &&
          !_declinedParkingLots.containsKey(parkingLotVM.nearestParkingLot!.name)) {
        setState(() {
          _nearestParkingLot = parkingLotVM.nearestParkingLot;
          _showDialog = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          parkingLotVM.nearestParkingLot = null;
        });
      } else if (parkingLotVM.isParked && parkingLotVM.parkedLocation != null &&
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
          LatLng(locationVM.currentPosition!.latitude,
              locationVM.currentPosition!.longitude),
        ),
      );
    }
  }

  // Dialog to ask if user wants to park near a parking lot
  // Parking banner when user is near a parking lot
Widget _buildParkingBanner(ParkingLot parkingLot) {
  return Positioned(
    top: 16,
    left: 16,
    right: 16,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_parking, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Flexible(
                  child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    "You're near ${parkingLot.name}!",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (parkingLot.capacity != null && parkingLot.capacity! > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rate: ${parkingLot.fullRate}. Do you want to park?",
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showDialog = false;
                            _declinedParkingLots[parkingLot.name] =
                                Timer(const Duration(minutes: 15), () {
                              setState(() {
                                _declinedParkingLots.remove(parkingLot.name);
                              });
                            });
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text("No"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showDialog = false;
                          });
                          final parkedVM = Provider.of<ParkedViewModel>(context, listen: false);
                          if (parkingLot.address != null) {
                            parkedVM.addParked(parkingLot.address!);
                          }
                          final parkingLotVM = Provider.of<ParkingLotViewModel>(context, listen: false);
                          parkingLotVM.setParkedLocation(parkingLot);
                          _leaveTimer = Timer(const Duration(minutes: 15), () {
                            setState(() {});
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                        ),
                        child: const Text("Yes"),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Parking lot is full. Please look for another location.",
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showDialog = false;
                          _declinedParkingLots[parkingLot.name] = Timer(
                            const Duration(minutes: 15),
                            () {
                              setState(() {
                                _declinedParkingLots.remove(parkingLot.name);
                              });
                            },
                          );
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.grey),
                      label: const Text("Close"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

// Pay/Leave banner near parked car
Widget _buildPayOrLeaveBanner(ParkingLotViewModel parkingLotVM) {
  return Positioned(
    top: 16,
    left: 16,
    right: 16,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.directions_car, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Leaving?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showDialog = false;
                    });
                    _leaveTimer?.cancel();
                    _leaveTimer = Timer(const Duration(minutes: 15), () {
                      setState(() {});
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child:const  Text("Close"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showDialog = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text("Pay"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final parkedVM = Provider.of<ParkedViewModel>(context, listen: false);
                      parkedVM.leaveParked();
                      parkingLotVM.leaveParking();
                      _showDialog = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text("Leave"),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

}
