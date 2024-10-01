import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:application_dart/repositories/localization.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  String? errorMessage;
  StreamSubscription<Position>? _positionStreamSubscription;

  Position? get currentPosition => _currentPosition;

  LocationViewModel() {
    _initLocationTracking();
  }

  Future<void> _initLocationTracking() async {
    try {
      final permission = await _locationService.requestLocationPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        await _startLocationUpdates();
      } else {
        errorMessage = 'Location permission not granted';
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _startLocationUpdates() async {
    _positionStreamSubscription?.cancel();
    
    _positionStreamSubscription = _locationService.getPositionStream().listen(
      (Position position) {
        _currentPosition = position;
        errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        errorMessage = e.toString();
        notifyListeners();
      },
    );

    // Get the initial position
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to get initial position: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> fetchUserLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      _currentPosition = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}