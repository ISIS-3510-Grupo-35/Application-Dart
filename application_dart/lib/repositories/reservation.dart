import 'dart:convert';

import 'package:application_dart/models/reservation.dart';
import 'package:application_dart/services/reservation.dart';

class ReservationRepository {
  final ReservationService _service = ReservationService();

  Future<List<Reservation>> getReservations() async {
    final response = await _service.fetchReservations();

    if (response.statusCode == 200) {
      return List<Reservation>.from(
          json.decode(response.body).map((x) => Reservation.fromJson(x)));
    } else {
      throw Exception('Failed to load superheroes');
    }
  }
}