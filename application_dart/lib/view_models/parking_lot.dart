import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/repositories/parking_lot.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class ParkingLotViewModel extends ChangeNotifier {
  final ParkingLotRepository _repository = GetIt.instance<ParkingLotRepository>();

  List<ParkingLot> _parkingLots = [];
  bool _fetchingData = false;
  String? _errorMessage;
  Set<Marker> _markers = {};
  Marker? _parkedMarker; // Marker for the parked location
  ParkingLot? _nearestParkingLot;

  // New properties for parked location and parked status
  bool _isParked = false;
  LatLng? _parkedLocation;
  DateTime? _parkedTime; // Store the time when the user parked
  Timer? _leaveTimer; // Timer for checking the parked time

  // Getter to access parked status
  bool get isParked => _isParked;

  // Getter to access the parked location
  LatLng? get parkedLocation => _parkedLocation;

  // Getter to access the parked marker
  Marker? get parkedMarker => _parkedMarker;

  // Getter to access the parked time
  DateTime? get parkedTime => _parkedTime;

  // Getter to access the parking lots
  List<ParkingLot> get parkingLots => _parkingLots;

  // Getter to check if data is being fetched
  bool get fetchingData => _fetchingData;

  // Getter to access the error message (if any)
  String? get errorMessage => _errorMessage;

  // Getter to access the markers set
  Set<Marker> get markers => _markers;

  // Getter to access the nearest parking lot
  ParkingLot? get nearestParkingLot => _nearestParkingLot;

  // Setter for the nearest parking lot
  set nearestParkingLot(ParkingLot? value) {
    _nearestParkingLot = value;
    notifyListeners(); // Notify listeners whenever the nearest parking lot changes
  }

  final double _proximityThreshold = 500; // Define proximity threshold in meters
  final double _parkedProximityThreshold = 50; // Proximity threshold to detect return to parked location
  final Duration _leaveTriggerDuration = const Duration(minutes: 15); // 15-minute timer duration

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
      if (kDebugMode) {
        print(_errorMessage);
      } // Print the error for debugging purposes
    } finally {
      _fetchingData = false;
      notifyListeners();
    }
  }

  // Generate markers from the parking lots
  void _generateMarkers() {
    _markers = _parkingLots.map((ParkingLot parkingLot) {
      return Marker(
        markerId: MarkerId(parkingLot.name),
        position: LatLng(parkingLot.latitude ?? 0.0, parkingLot.longitude ?? 0.0),
        infoWindow: InfoWindow(
          title: parkingLot.name,
          snippet: "Capacity: ${parkingLot.capacity}, Rate: ${parkingLot.fullRate}",
        ),
      );
    }).toSet();

    // Add the parked location marker if the user is parked
    if (_isParked && _parkedLocation != null) {
      _markers.add(_parkedMarker!);
    }
  }

  // Check if the user is near any parking lot and update state if necessary
  void checkProximityToMarkers(Position? userPosition) {
    if (userPosition == null || _parkingLots.isEmpty) return;

    if (_isParked) {
      // Check proximity to parked location
      final distanceToParkedCar = _calculateDistance(
        userPosition.latitude,
        userPosition.longitude,
        _parkedLocation!.latitude,
        _parkedLocation!.longitude,
      );

      if (distanceToParkedCar <= _parkedProximityThreshold) {
        notifyListeners(); // Notify to show the "Pay/Leave" dialog
      }
    } else {
      // Check proximity to parking lots
      for (var parkingLot in _parkingLots) {
        final distance = _calculateDistance(
          userPosition.latitude,
          userPosition.longitude,
          parkingLot.latitude ?? 0.0,
          parkingLot.longitude ?? 0.0,
        );

        // If the user is within the proximity threshold, set nearestParkingLot
        if (distance <= _proximityThreshold) {
          nearestParkingLot = parkingLot;
          break;
        }
      }
    }
  }

  List<ParkingLot> getParkingLotsInProximity(Position? userPosition, double proximityRange) {
  // Return an empty list if no position is provided or there are no parking lots to check
  if (userPosition == null || _parkingLots.isEmpty) return [];

  List<ParkingLot> nearbyParkingLots = [];

  for (var parkingLot in _parkingLots) {
    final distance = _calculateDistance(
      userPosition.latitude,
      userPosition.longitude,
      parkingLot.latitude ?? 0.0,
      parkingLot.longitude ?? 0.0,
    );

    // If the parking lot is within the specified proximity range, add it to the list
    if (distance <= proximityRange) {
      nearbyParkingLots.add(parkingLot);
    }
  }

  return nearbyParkingLots; // Return the list of nearby parking lots
}


  // Set the parked location and add a blue marker to the map
  void setParkedLocation(LatLng location) {
    _isParked = true;
    _parkedLocation = location;
    _parkedTime = DateTime.now();

    // Create a blue marker with an onTap event to show the "Pay/Leave" dialog
    _parkedMarker = Marker(
      markerId: const MarkerId('parked_marker'),
      position: location,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Blue marker for parked location
      infoWindow: const InfoWindow(title: "Parked Car", snippet: "This is where you parked."),
      onTap: () {
        notifyListeners(); // Trigger the dialog to open
      },
    );
    _generateMarkers(); // Update markers
    _startLeaveTimer(); // Start the leave timer
    notifyListeners();
  }

  // Remove parked status when the user leaves the parking
  void leaveParking() {
    _isParked = false;
    _parkedLocation = null;
    _parkedTime = null;
    _parkedMarker = null; // Remove parked marker
    _leaveTimer?.cancel(); // Cancel the leave timer
    _leaveTimer = null;
    _generateMarkers(); // Update markers to remove the parked marker
    notifyListeners();
  }

  // Reset the timer without showing the dialog immediately
  void resetLeaveTimer() {
    _startLeaveTimer(); // Restart the timer
    notifyListeners(); // Trigger state update to dismiss dialog
  }

  // Start a timer to show the "Leave" dialog after 15 minutes
  void _startLeaveTimer() {
    _leaveTimer?.cancel(); // Cancel any existing timer
    _leaveTimer = Timer(_leaveTriggerDuration, () {
      notifyListeners(); // Trigger the "Leave" dialog after 15 minutes
    });
  }

  // Calculate the distance between two geographic points (Haversine formula)
  double _calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
  }
}
