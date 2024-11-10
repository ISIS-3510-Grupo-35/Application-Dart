import 'package:application_dart/models/parked.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParkedService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all parking lot documents from the 'parking lots' collection
  Future<Parked?> fetchParked() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userUid = prefs.getString('user_uid');

      QuerySnapshot snapshot = await _firestore.collection('parking').where('user', isEqualTo: userUid).where('exit', isEqualTo: false).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return Parked.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Add a new parked record to Firestore
  Future<bool> addParked(Parked parked) async {
    try {
      await _firestore.collection('parking').add(parked.toJson());
      return true;
    } catch (e) {
      print('Error adding parked: $e');
      return false;
    }
  }

  // Update exit status when the user leaves the parking lot
  Future<bool> leaveParked() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userUid = prefs.getString('user_uid');
      QuerySnapshot snapshot = await _firestore.collection('parking')
          .where('user', isEqualTo: userUid)
          .where('exit', isEqualTo: false)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await _firestore.collection('parking')
            .doc(snapshot.docs.first.id)
            .update({
              'exit': true,
              'exitTime': DateTime.now()
            });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error leaving parked: $e');
      return false;
    }
  }
}

