import 'package:application_dart/models/reservation.dart';
import 'package:application_dart/repositories/reservation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationViewModel extends ChangeNotifier {
  final ReservationRepository _repository = GetIt.instance<ReservationRepository>();

  Reservation? _reservation;
  bool fetchingData = false;


  Future<Reservation?> fetchReservations() async {
    fetchingData = true;
    try {
      _reservation = await _repository.getReservationsByUserId();
      notifyListeners();
      fetchingData = false;

      return _reservation;
    } catch (e) {
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
        _reservation =  newReservation;
      }else{
        throw Exception('Failed to add reservation');
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add reservation: $e');
    }
  }

  Future<void> cancelReservation() async {
    try {
      bool success = await _repository.cancelReservation();
      if (success) {
        _reservation = null;
      } else {
        throw Exception('Failed to cancel reservation');
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to cancel reservation: $e');
    }
  }
}
