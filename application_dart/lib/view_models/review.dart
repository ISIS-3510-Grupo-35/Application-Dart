import 'package:flutter/material.dart';
import 'package:application_dart/models/review.dart';
import 'package:application_dart/repositories/review.dart';

class ReviewViewModel extends ChangeNotifier {
  // Repository created internally, no parameters required
  final ReviewRepository _repository = ReviewRepository();

  bool isLoading = false;
  List<Review> _reviews = [];

  List<Review> get reviews => _reviews;

  Future<void> loadReviews(String parkingId) async {
    isLoading = true;
    notifyListeners();
    _reviews = await _repository.getReviewsForParkingLot(parkingId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> addReview(String parkingId, String rate, String reviewText, String userId) async {
    isLoading = true;
    notifyListeners();
    final review = Review(
      parkingId: parkingId,
      rate: rate,
      review: reviewText,
      userId: userId,
    );
    await _repository.addReview(review);
    _reviews.add(review);
    isLoading = false;
    notifyListeners();
  }
}
