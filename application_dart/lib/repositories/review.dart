import 'package:application_dart/models/review.dart';
import 'package:application_dart/services/review.dart';

class ReviewRepository {
  // Service created internally, no parameters required
  final ReviewService _service = ReviewService();

  Future<void> addReview(Review review) async {
    await _service.addReview(review);
  }

  Future<List<Review>> getReviewsForParkingLot(String parkingId) async {
    return await _service.fetchReviewsForParkingLot(parkingId);
  }
}
