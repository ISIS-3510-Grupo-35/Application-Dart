import 'package:application_dart/models/parking_lot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingLotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all parking lot documents from the 'parking lots' collection
  Future<List<ParkingLot>> fetchParkingLots() async {
    try {
      // Get all documents in the 'parking lots' collection
      QuerySnapshot snapshot = await _firestore.collection('Parking lots').get();

      // Convert each document into a ParkingLot instance and return as a list
      return snapshot.docs.map((doc) {
        return ParkingLot.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching parking lots: $e");
      return [];
    }
  }
}
