import 'package:application_dart/models/review.dart';
import 'package:application_dart/repositories/review.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReviewsViewModel extends ChangeNotifier {
  final ReviewRepository _repository = GetIt.instance<ReviewRepository>();
  
  List<Review> _reviews = [];
  bool fetchingData = false;
  List<Review> get reviews => _reviews;

  Future<void> fetchReviews() async {
    fetchingData = true;
    try {
      _reviews = await _repository.getReviews();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load Reviewss: $e');
    }
    fetchingData = false;
  }
}