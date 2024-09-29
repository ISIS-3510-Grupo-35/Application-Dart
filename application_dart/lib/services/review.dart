// ignore_for_file: depend_on_referenced_packages

import 'package:http/http.dart' as http;

class ReviewService {

  Future<http.Response> fetchReviews() async {
    return await http.get(Uri.parse('apiUrl'));
  }

  Future<http.Response> fetchReviewById(int id) async {
    return await http.get(Uri.parse('apiUrl/$id'));
  }

  Future<http.Response> createReview(Map<String, dynamic> review) async {
    return await http.post(
      Uri.parse('apiUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: review,
    );
  }

  Future<http.Response> updateReview(int id, Map<String, dynamic> review) async {
    return await http.put(
      Uri.parse('apiUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: review,
    );
  }

  Future<http.Response> deleteReview(int id) async {
    return await http.delete(Uri.parse('apiUrl/$id'));
  }
}