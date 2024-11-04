import 'package:application_dart/models/reservation.dart';
import 'package:application_dart/services/reservation.dart';

class ReservationRepository {
  final ReservationService _service = ReservationService();

  Future<Reservation> getReservationsByUserId() async {
    final reservation = await _service.fetchReservationByUserID();

    if (reservation != null) {
      return reservation;
    } else {
      throw Exception('Failed to load superheroes');
    }
  }

  Future<bool> addReservation(Reservation reservation) async {
    bool response = await _service.addReservation(reservation);

    if (response) {
      return response;
    } else {
      return false;
    }
  }

  Future<bool> cancelReservation() async {
    bool response = await _service.cancelReservationByUserID();
    if (response) {
      return response;
    } else {
      return false;
    }
  }
}