import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/repositories/parking_lot.dart';
import 'package:get_it/get_it.dart';

class ParkingLotViewModel extends ChangeNotifier {
  // Access the registered ParkingLotRepository from GetIt
  final ParkingLotRepository _repository = GetIt.instance<ParkingLotRepository>();

  List<ParkingLot> _parkingLots = [];
  bool _fetchingData = false;
  String? _errorMessage;
  Set<Marker> _markers = {};

  List<ParkingLot> get parkingLots => _parkingLots;

  bool get fetchingData => _fetchingData;

  String? get errorMessage => _errorMessage;

  Set<Marker> get markers => _markers;

  // Fetch parking lots and generate markers
  Future<void> fetchParkingLots() async {
    _fetchingData = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _parkingLots = await _repository.getParkingLots();

      // Generate markers from the fetched parking lots
      _generateMarkers();
    } catch (e) {
      _errorMessage = 'Failed to load ParkingLots: $e';
      print(_errorMessage);  // Print the error for debugging purposes
    } finally {
      _fetchingData = false;
      notifyListeners();
    }
  }

  // Generate markers from the parking lots
  void _generateMarkers() {
    _markers = _parkingLots.map((ParkingLot parkingLot) {
      return Marker(
        markerId: MarkerId(parkingLot.name ?? 'unknown'),
        position: LatLng(parkingLot.latitude ?? 0.0, parkingLot.longitude ?? 0.0),
        infoWindow: InfoWindow(
          title: parkingLot.name,
          snippet: "Capacity: ${parkingLot.capacity}, Rate: ${parkingLot.fullRate}",
        ),
      );
    }).toSet();
  }
}
