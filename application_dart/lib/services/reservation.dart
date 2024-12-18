import 'package:application_dart/models/reservation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Reservation?> fetchReservationByUserID() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userUid = prefs.getString('user_uid');
      QuerySnapshot snapshot = await _firestore
          .collection('Reservations')
          .where('userID', isEqualTo: userUid)
          .where('status', isEqualTo: 'created')
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return Reservation.fromJson(
            snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error fetching reservation: $e");
      return null;
    }
  }

  Future<bool> addReservation(Reservation reservation) async {
    try {
      await _firestore.collection('Reservations').add(reservation.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelReservationByUserID() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userUid = prefs.getString('user_uid');
      QuerySnapshot snapshot = await _firestore
          .collection('Reservations')
          .where('userID', isEqualTo: userUid)
          .where('status', isEqualTo: 'created')
          .limit(1)
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.update({'status': 'cancelled'});
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateReservation(Reservation reservation, Reservation reservationChanged) async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userUid = prefs.getString('user_uid');
      QuerySnapshot snapshot = await _firestore
          .collection('Reservations')
          .where('userID', isEqualTo: userUid)
          .where('status', isEqualTo: 'created')
          .where('arrivalTime', isEqualTo: reservation.arrivalTime)
          .where('departureTime', isEqualTo: reservation.departureTime)
          .where('licensePlate', isEqualTo: reservation.licensePlate)
          .where('parkingID', isEqualTo: reservation.parkingId)
          .limit(1)
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.update({
          'arrivalTime': reservationChanged.arrivalTime,
          'licensePlate': reservationChanged.licensePlate
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Reservation>> listenToReservations() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userUid = prefs.getString('user_uid');
    yield* _firestore
        .collection('Reservations')
        .where('userID', isEqualTo: userUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reservation.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
