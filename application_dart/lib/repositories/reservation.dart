import 'package:application_dart/models/reservation.dart';
import 'package:application_dart/services/reservation.dart';

class ReservationRepository {
  final ReservationService _service = ReservationService();

  Stream<List<Reservation>> getReservations() {
    return  _service.listenToReservations();

  }

  Future<Reservation?> getReservationsByUserId() async {
    final reservation = await _service.fetchReservationByUserID();
      return reservation;
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

  Future<bool> updateReservation(Reservation reservation, Reservation reservationChanged) async {
    bool response = await _service.updateReservation(reservation, reservationChanged);
    if(response){
      return response;
    }
    else{
      return false;
    }
  }
}

