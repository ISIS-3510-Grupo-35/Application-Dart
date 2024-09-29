import 'package:application_dart/models/reservation.dart';
import 'package:application_dart/repositories/reservation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReservationsViewModel extends ChangeNotifier {
  final ReservationRepository _repository = GetIt.instance<ReservationRepository>();
  
  List<Reservation> _reservations = [];
  bool fetchingData = false;
  List<Reservation> get reservations => _reservations;

  Future<void> fetchReservations() async {
    fetchingData = true;
    try {
      _reservations = await _repository.getReservations();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load Reservationss: $e');
    }
    fetchingData = false;
  }
}