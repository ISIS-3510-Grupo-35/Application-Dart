import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:application_dart/models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview(Review review) async {
    await _firestore
        .collection('ParkingLots')
        .doc(review.parkingId)
        .collection('Reviews')
        .add(review.toMap());
  }

  Future<List<Review>> fetchReviewsForParkingLot(String parkingId) async {
    final querySnapshot = await _firestore
        .collection('ParkingLots')
        .doc(parkingId)
        .collection('Reviews')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Review.fromMap({
        'parkingId': parkingId,
        'rate': data['rate'],
        'review': data['review'],
        'userId': data['userId'],
      });
    }).toList();
  }
}
