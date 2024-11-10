import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/repositories/parking_lot.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class ParkingLotViewModel extends ChangeNotifier {
  final ParkingLotRepository _repository =
      GetIt.instance<ParkingLotRepository>();

  List<ParkingLot> _parkingLots = [];
  bool _fetchingData = false;
  String? _errorMessage;
  Set<Marker> _markers = {};
  Marker? _parkedMarker; // Marker for the parked location
  ParkingLot? _nearestParkingLot;
  ParkingLot? _parkedParkingLot;

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

  final double _proximityThreshold =
      500; // Define proximity threshold in meters
  final double _parkedProximityThreshold =
      50; // Proximity threshold to detect return to parked location
  final Duration _leaveTriggerDuration =
      const Duration(minutes: 15); // 15-minute timer duration

  // Fetch parking lots and generate markers
  Future<void> fetchParkingLots() async {
    _fetchingData = true;
    _errorMessage = null;
    final Completer<void> completer = Completer<void>();

    _repository.listenToParkingLots().listen((parkingLots) {
      _parkingLots = parkingLots;
      _generateMarkers(); // Update markers with new data
      _fetchingData = false;

      // Complete the completer on the first data load
      if (!completer.isCompleted) {
        completer.complete();
      }

      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Failed to load ParkingLots: $error';
      _fetchingData = false;

      // Complete the completer in case of an error
      if (!completer.isCompleted) {
        completer.completeError(error);
      }

      notifyListeners();
    });

    return completer.future; // Return the Future to await
  }

  ParkingLot? getParkingLotById(String address) {
    return parkingLots.firstWhere((lot) => lot.address == address);
  }

  // Generate markers from the parking lots
  void _generateMarkers() {
    _markers = _parkingLots.map((ParkingLot parkingLot) {
      final bool isFull = (parkingLot.capacity ?? 0) <= 0;

      return Marker(
        markerId: MarkerId(parkingLot.name),
        position:
            LatLng(parkingLot.latitude ?? 0.0, parkingLot.longitude ?? 0.0),
        icon: isFull
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: parkingLot.name,
          snippet: isFull
              ? "Parking Full - Requires Key"
              : "Current capacity: ${parkingLot.capacity}, Rate: ${parkingLot.fullRate}",
        ),
      );
    }).toSet();

    if (_isParked && _parkedLocation != null) {
      _markers.add(_parkedMarker!);
    }

    if (_parkedParkingLot != null) {
      _markers.removeWhere(
          (marker) => marker.markerId.value == _parkedParkingLot!.name);
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

  List<ParkingLot> getParkingLotsInProximity(
      Position? userPosition, double proximityRange) {
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
  Future<void> setParkedLocation(ParkingLot parkingLot,
      {bool state = false}) async {
    _isParked = true;
    _parkedLocation =
        LatLng(parkingLot.latitude ?? 0.0, parkingLot.longitude ?? 0.0);
    _parkedTime = DateTime.now();

    // Set the parked parking lot to the nearest parking lot
    _parkedParkingLot = parkingLot;

    // Create a blue marker with an onTap event to show the "Pay/Leave" dialog
    _parkedMarker = Marker(
      markerId: const MarkerId('parked_marker'),
      position: _parkedLocation!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
          title: "Parked Car",
          snippet: "${parkingLot.name} is where you parked."),
      onTap: () {
        notifyListeners();
      },
    );

    _markers.add(_parkedMarker!); 

    //remove the marker of the parking lot
    _markers.removeWhere((marker) => marker.markerId.value == parkingLot.name);

    // Decrement the parking lot capacity in Firestore
    if (_fetchingData == false) {
      if (_nearestParkingLot != null) {
        try {
          var i = 0;
          var currentCapacity = _nearestParkingLot!.capacity ?? 0;
          while (i < _parkingLots.length) {
            if (_parkingLots[i].name == _nearestParkingLot!.name) {
              currentCapacity = _parkingLots[i].capacity ?? 0;
              break;
            }
            i++;
          }

          if (currentCapacity > 0) {
            final newCapacity = currentCapacity - 1;
            await _repository.updateParkingLotCapacity(
                _nearestParkingLot!.name, newCapacity);
          }
        } catch (e) {
          print("Failed to update capacity: $e");
        }
      }
    }

    _startLeaveTimer(); // Start the leave timer
    notifyListeners();
  }

  // Remove parked status when the user leaves the parking
  Future<void> leaveParking() async {
    if (_isParked && _parkedParkingLot != null) {
      // Use _parkedParkingLot instead of _nearestParkingLot
      try {
        var i = 0;
        var newCapacity = _parkedParkingLot!.capacity ?? 0;
        while (i < _parkingLots.length) {
          if (_parkingLots[i].name == _parkedParkingLot!.name) {
            newCapacity = _parkingLots[i].capacity ?? 0;
            break;
          }
          i++;
        }

        newCapacity = newCapacity + 1;
        await _repository.updateParkingLotCapacity(
            _parkedParkingLot!.name, newCapacity);
      } catch (e) {
        print("Failed to update capacity when leaving: $e");
      }
    }

    // Reset the parked state and remove markers
    _isParked = false;
    _parkedLocation = null;
    _parkedTime = null;
    _parkedMarker = null; // Remove parked marker
    _parkedParkingLot = null; // Reset the parked parking lot reference
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
  double _calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }
}
