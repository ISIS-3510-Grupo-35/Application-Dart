import 'package:application_dart/models/parking_lot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingLotService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all parking lot documents from the 'parking lots' collection
  Future<List<ParkingLot>> fetchParkingLots() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Parking lots').get();
      return snapshot.docs.map((doc) {
        return ParkingLot.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching parking lots: $e");
      return [];
    }
  }

  // Update the capacity of a specific parking lot
  Future<void> updateParkingLotCapacity(String parkingLotId, int newCapacity) async {
    try {
      await _firestore
          .collection('Parking lots')
          .where('name', isEqualTo: parkingLotId)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.update({'capacity': newCapacity});
        }
          });
    } catch (e) {
      print("Error updating parking lot capacity: $e");
      throw Exception("Failed to update parking lot capacity");
    }
  }

  // Real-time listener for parking lots collection
  Stream<List<ParkingLot>> listenToParkingLots() {
    return _firestore.collection('Parking lots').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ParkingLot.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}

