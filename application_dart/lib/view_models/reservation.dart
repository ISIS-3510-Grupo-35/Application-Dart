import 'dart:async';

import 'package:application_dart/models/reservation.dart';
import 'package:application_dart/repositories/reservation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationViewModel extends ChangeNotifier {
  final ReservationRepository _repository = GetIt.instance<ReservationRepository>();

  Reservation? _reservation;
  List<Reservation>? _reservations = [];
  bool fetchingData = false;

  List<Reservation>? get reservations => _reservations;

  Reservation get reservation => _reservation!;

  StreamSubscription<List<Reservation>>? _reservationsSubscription;

  // Call this once (e.g., in the constructor or from an init method) 
  // to start listening to the stream of all reservations.
  void startListeningToAllReservations() {
    // If we already have a subscription, cancel it before starting a new one
    _reservationsSubscription?.cancel();
    
    _reservationsSubscription = _repository.getReservations().listen((reservations) {
      _reservations = reservations;
      notifyListeners();
    }, onError: (error) {
      print('Error listening to reservations stream: $error');
    });
  }

  Future<Reservation?> fetchReservations() async {
    fetchingData = true;
    notifyListeners();
    try {
      _reservation = await _repository.getReservationsByUserId();
      fetchingData = false;
      notifyListeners();
      return _reservation;
    } catch (e) {
      fetchingData = false;
      notifyListeners();
      throw Exception('Failed to load reservations: $e');
    }
  }

  bool isReserved() {
    return _reservation != null;
  }

  Future<void> addReservation(String parkingLotId, DateTime reservationTime, String licensePlate) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userUid = prefs.getString('user_uid');

      final newReservation = Reservation(
        parkingId: parkingLotId,
        userId: userUid ?? '',
        arrivalTime: reservationTime,
        licensePlate: licensePlate,
        status: 'created',
      );

      bool success = await _repository.addReservation(newReservation);
      if (success) {
        _reservation = newReservation;
        notifyListeners();
      } else {
        throw Exception('Failed to add reservation');
      }
    } catch (e) {
      throw Exception('Failed to add reservation: $e');
    }
  }

  Future<void> cancelReservation() async {
    try {
      bool success = await _repository.cancelReservation();
      if (success) {
        _reservation = null;
        notifyListeners();
      } else {
        throw Exception('Failed to cancel reservation');
      }
    } catch (e) {
      throw Exception('Failed to cancel reservation: $e');
    }
  }

  @override
  void dispose() {
    // Cancel the stream subscription when disposing of the ViewModel
    _reservationsSubscription?.cancel();
    super.dispose();
  }
}
