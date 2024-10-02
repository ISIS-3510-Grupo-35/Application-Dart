import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/services/parking_lot.dart';

class ParkingLotRepository {
  final ParkingLotService _service = ParkingLotService();

  Future<List<ParkingLot>> getParkingLots() async {
    // Call the Firestore service to fetch the parking lots
    final List<ParkingLot> parkingLots = await _service.fetchParkingLots();

    // If the list is not empty, return it. Otherwise, throw an exception.
    if (parkingLots.isNotEmpty) {
      return parkingLots;
    } else {
      throw Exception('Failed to load parking lots');
    }
  }
}
