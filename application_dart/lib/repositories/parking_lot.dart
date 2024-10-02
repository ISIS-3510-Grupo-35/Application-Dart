import 'package:application_dart/models/parking_lot.dart';
import 'package:application_dart/services/parking_lot.dart';

class ParkingLotRepository {
  final ParkingLotService _service = ParkingLotService();

  Future<List<ParkingLot>> getParkingLots() async {
    final List<ParkingLot> parkingLots = await _service.fetchParkingLots();
    if (parkingLots.isNotEmpty) {
      return parkingLots;
    } else {
      throw Exception('Failed to load parking lots');
    }
  }

  // Update parking lot capacity through the service
  Future<void> updateParkingLotCapacity(String parkingLotId, int newCapacity) async {
    await _service.updateParkingLotCapacity(parkingLotId, newCapacity);
  }

  // Listen to parking lot updates in real-time
  Stream<List<ParkingLot>> listenToParkingLots() {
    return _service.listenToParkingLots();
  }
}
