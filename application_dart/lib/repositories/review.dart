import 'dart:convert';

import 'package:application_dart/models/review.dart';
import 'package:application_dart/services/review.dart';

class ReviewRepository {
  final ReviewService _service = ReviewService();

  Future<List<Review>> getReviews() async {
    final response = await _service.fetchReviews();

    if (response.statusCode == 200) {
      return List<Review>.from(
          json.decode(response.body).map((x) => Review.fromJson(x)));
    } else {
      throw Exception('Failed to load superheroes');
    }
  }
}