import 'dart:convert';

import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/services/parking_lot.dart';

class ParkingLotRepository {
  final ParkingLotService _service = ParkingLotService();

  Future<List<ParkingLot>> getParkingLots() async {
    final response = await _service.fetchParkingLots();

    if (response.statusCode == 200) {
      return List<ParkingLot>.from(
          json.decode(response.body).map((x) => ParkingLot.fromJson(x)));
    } else {
      throw Exception('Failed to load superheroes');
    }
  }
}